package eu.extremexp.dsl.validation

import org.eclipse.xtext.validation.Check
import eu.extremexp.dsl.xDSL.XDSLPackage
import eu.extremexp.dsl.xDSL.WorkflowInterface
import eu.extremexp.dsl.xDSL.Workflow
import eu.extremexp.dsl.xDSL.Namespace
import eu.extremexp.dsl.xDSL.NamedElement

// import eu.extremexp.dsl.language.LanguagePackage 

class NameValidator extends AbstractXDSLValidator{
	public static val INVALID_NAME = 'invalidName'
	 
	/*
	 * Names of actual workflows (assembled or full) should be exactly as the filename
	 */
	
	@Check
	def checkWorkflowNameSameAsFile(WorkflowInterface wf) {
		val resource = wf.eResource
		if (wf.name + "." + resource.URI.fileExtension != 
			resource.URI.segment(resource.URI.segmentCount -1)){
				error("Workflow should be named as the filename ", 
						XDSLPackage.Literals.WORKFLOW_INTERFACE__NAME,
						INVALID_NAME)				
			}
	}
	/*
	 * Within same namespace, workflows (assembled or new) names should be unique
	 */
	
	@Check
	def checkWorkflowBeingUnique(WorkflowInterface wf) {
		val namespace = (wf.eContainer) as Namespace
		for (_wf : namespace.workflows){
			if (_wf !== wf && _wf.name == wf.name){
				error("Another Worfklow with name " + wf.name + " exists in "+ namespace.name, 
						XDSLPackage.Literals.WORKFLOW_INTERFACE__NAME,
						INVALID_NAME)				
			}
		}
	}
	
	/*
	 * Within same workflow, names of tasks, params, data should be unique
	 * TODO, in case of params for assembled workflow, should it override?
	*/
	@Check
	def checkElementsWithinSameWorkflow(NamedElement ne) {
		val workflow = ne.eContainer
		if (workflow instanceof Workflow){
			val elements = workflow.params + workflow.data + workflow.tasks
			
			for (element : elements){
				if (element !== ne && element.name == ne.name){
					error("Another " + element.eClass.name + " with name " + element.name + " exists in "+ workflow.name, 
							XDSLPackage.Literals.NAMED_ELEMENT__NAME,
							INVALID_NAME)				
				}
			}
		}
	}
}