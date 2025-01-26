package eu.extremexp.dsl.ide;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.nio.channels.AsynchronousServerSocketChannel;
import java.nio.channels.AsynchronousSocketChannel;
import java.nio.channels.Channels;
import java.nio.channels.CompletionHandler;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.function.Function;

import org.eclipse.lsp4j.jsonrpc.Launcher;
import org.eclipse.lsp4j.jsonrpc.MessageConsumer;
import org.eclipse.lsp4j.services.LanguageClient;
import org.eclipse.xtext.ide.server.LanguageServerImpl;
import org.eclipse.xtext.ide.server.ILanguageServerShutdownAndExitHandler;
import org.eclipse.xtext.ide.server.ServerModule;

import com.google.inject.Guice;
import com.google.inject.Injector;

/**
 * Runner for the ExtremeXP DSL language server.
 */
public class RunServer {

    private static class DSLServerModule extends ServerModule {

        @Override
        protected void configure() {
            super.configure();
            // Remove automated termination of the whole VM when the LangServer object losses a connection.
            bind(ILanguageServerShutdownAndExitHandler.class).to(ILanguageServerShutdownAndExitHandler.NullImpl.class);
        }
    }

    private static int port = 5007;

    public static void main(String[] args) {
        
        Injector injector = Guice.createInjector(new DSLServerModule());

        ExecutorService executorService = Executors.newCachedThreadPool();
        Function<MessageConsumer, MessageConsumer> wrapper = consumer -> {
            MessageConsumer result = consumer;
            return result;
        };
        
        if (args.length > 0) {
        	try {
        		RunServer.port = Integer.parseInt(args[0]);
        	}
        	catch (NumberFormatException e){
        		e.printStackTrace();
        		System.out.println("Port should be a number between 1024–49151");
        		System.exit(1);
        	}
        	if (RunServer.port< 1024 || RunServer.port > 49151 ) {
        		System.out.println("Port should be a number between 1024–49151");
        		System.exit(1);
        	}
        }
        System.out.println("LSP Activated on port: " + RunServer.port);
        System.out.println("DSL Language Version: 5.0");
        
        try (final AsynchronousServerSocketChannel server = AsynchronousServerSocketChannel.open().bind(new InetSocketAddress(port))) {
            System.out.println("LSP listening on " + port);
            server.accept(null, new CompletionHandler<AsynchronousSocketChannel, Object>() {
                public void completed(AsynchronousSocketChannel socketChannel, Object att) {
                    System.out.println("LSP has accepted a connection");
                    server.accept(null, this);

                    LanguageServerImpl languageServer = injector.getInstance(LanguageServerImpl.class);
                    Launcher<LanguageClient> launcher = Launcher.createIoLauncher(languageServer, LanguageClient.class, Channels.newInputStream(socketChannel), Channels.newOutputStream(socketChannel), executorService, wrapper);
                    languageServer.connect(launcher.getRemoteProxy());

                    Future<?> future = launcher.startListening();
                    while (!future.isDone()) {
                        try {
                            Thread.sleep(10_000L);
                        } catch (InterruptedException ex) {
                            System.out.println("InterruptedException");
                        }
                    }
                    System.out.println("LSP connection termiated");
                }

                public void failed(Throwable exc, Object att) {
                    System.out.println("LSP failed to accept a connection");
                    exc.printStackTrace();
                }
            });

            try {
                Thread.sleep(Integer.MAX_VALUE); // main running forever
            } catch (InterruptedException ignored) {
            }
        } catch (IOException ex) {
            ex.printStackTrace();
        }

    }

}