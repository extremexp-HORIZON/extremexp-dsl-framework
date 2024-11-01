package eu.extremexp.dsl.resource

import org.eclipse.xtext.resource.impl.DefaultResourceDescriptionManager
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.scoping.Scopes
import java.util.List
import java.util.Map
import java.util.stream.Collectors
import eu.extremexp.dsl.xDSL.Root
import eu.extremexp.dsl.xDSL.XDSLFactory
import org.eclipse.xtext.EcoreUtil2
import com.google.inject.Inject
import org.eclipse.xtext.resource.IResourceDescriptions

class XDSLeDescriptionManager extends DefaultResourceDescriptionManager {
	@Inject
    IResourceDescriptions resourceDescriptions
    
    override getResourceDescription(Resource resource) {
    	val roots = newArrayList()
    	resourceDescriptions.allResourceDescriptions.forEach[r |
    		r.exportedObjects.forEach[exportedObject|
    			if (exportedObject.EClass.name == "Root"){
    				roots.add(EcoreUtil2.resolve(exportedObject.EObjectOrProxy, resource.resourceSet) as Root)
    			}
    		]
    	]
    	     
        // Group Roots by name and merge those with the same name
        	val rootsByName = roots.groupBy[name]
        	rootsByName.forEach[name, rootGroup |
        		println (name + " " + " " + rootGroup.size)
        	]

        // For each group of roots with the same name, merge them
        rootsByName.forEach[name, rootGroup |
            if (rootGroup.size > 1) {
                val mergedRoot = mergeRoots(rootGroup)
                // Replace individual roots in the model with the merged root
                resource.contents.removeAll(rootGroup)
                resource.contents.add(mergedRoot)
            }
        ]

        super.getResourceDescription(resource)
    }


    private def Root mergeRoots(List<Root> roots) {
        val mergedRoot = XDSLFactory.eINSTANCE.createRoot
        mergedRoot.name = roots.head.name

        roots.forEach[ root |
            mergedRoot.workflows.addAll(root.workflows)
            mergedRoot.groups.addAll(root.groups)
            mergedRoot.parameterTypes.addAll(root.parameterTypes)
            // Add other elements as needed
        ]
        
        mergedRoot
    }
}
