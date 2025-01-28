package eu.extremexp.dsl.scoping

import org.eclipse.xtext.scoping.impl.DefaultGlobalScopeProvider
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.scoping.IScope
import org.eclipse.emf.ecore.EReference

class XDSLGlobalScopeProvider extends DefaultGlobalScopeProvider {
	override getScope(Resource resource, EReference reference){
		println ("global scope")
		return super.getScope(resource, reference)
	}
}