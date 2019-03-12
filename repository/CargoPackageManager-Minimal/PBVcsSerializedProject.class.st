"
I represent a Cargo project ready to be serialized on a Version Control System (e.g. git).
I map some instance variables  to an easily serialized form.
"
Class {
	#name : #PBVcsSerializedProject,
	#superclass : #PBSerializedArtefact,
	#category : #'CargoPackageManager-Minimal-Model-Serialization'
}

{ #category : #converting }
PBVcsSerializedProject >> asOngoingPackage [
	^ PBProject fromVcsSerializedProject: self
]

{ #category : #converting }
PBVcsSerializedProject >> asOngoingProject [
	"Flush information from this VcsSerializedProject into the provided CGOProject.
	All instance variables will be set with values from the SerializableProject"
	| project |
	
	dict 
		at: #name
		ifAbsent: [ PBError new 
						signal: 'Cannot deserialize a Project with no name defined!' ].
					
	project := PBProject named: (dict at: #name).
	dict at: #description ifPresent: [ :description | project description: description ].
	dict at: #units ifPresent: [ :units | 
		project packages: (self ongoingPackageUnitsFrom: units) ].
	dict at: #assemblies ifPresent: [ :assemblies | 
		project assemblies: (self ongoingPackageAssembliesFrom: assemblies) ].
	dict at: #virtualPackages ifPresent: [ :virtualPackages | 
		project virtualPackages: (self ongoingVirtualPackagesFrom: virtualPackages) ].
	dict at: #dependencies ifPresent: [ :projectDependencies | 
		project dependencies: (self projectDependenciesFrom: projectDependencies) ].
		
	project packages do: [:package | package project: project ].
	
	^ project 
]

{ #category : #deserialization }
PBVcsSerializedProject >> baselineProjectDependencyFrom: aDictionary [
	^ PBMetacelloBaselineProjectDependency 
		name: (aDictionary at: #baseline) 
		repositoryUrl: (aDictionary at: #url)
		version: (aDictionary at: #version)
		
]

{ #category : #deserialization }
PBVcsSerializedProject >> configurationProjectDependencyFrom: aDictionary [
	^ PBMetacelloConfigurationProjectDependency 
		name: (aDictionary at: #configuration) 
		repositoryUrl: (aDictionary at: #url)
		version: (aDictionary at: #version)
		
]

{ #category : #deserialization }
PBVcsSerializedProject >> gitRepositoryFrom: aDictionnary [ 
	^ CGOGitRepositoryCreator new
		url: (aDictionnary at: #repositoryUrl);
		version: (aDictionnary at: #version);
		create.
]

{ #category : #initialization }
PBVcsSerializedProject >> initializeWithPackage: aCGOOngoingProject [
	super initializeWithPackage: aCGOOngoingProject.
	self
		addPropertyNamed: #externalProjects 
		ifNotEmptyOrNil: (aCGOOngoingProject externalProjects).
	self 
		addPropertyNamed: #units
		ifNotEmptyOrNil: (self sort: aCGOOngoingProject packageUnits andCollect: #asVcsSerializedPackageUnit).
	self
		addPropertyNamed: #assemblies 
		ifNotEmptyOrNil: (self sort: aCGOOngoingProject assemblies andCollect: #asVcsSerializedPackageAssembly).
	self 
		addPropertyNamed: #virtualPackages 
		ifNotEmptyOrNil: (self sort: aCGOOngoingProject virtualPackages andCollect: #asVcsSerializablePackageVersion).
]

{ #category : #deserialization }
PBVcsSerializedProject >> ongoingPackageAssembliesFrom: aCollection [ 
	^ aCollection collect: [ :each | (PBVcsSerializedPackageAssembly fromDictionary: each) asOngoingPackage ]	
]

{ #category : #deserialization }
PBVcsSerializedProject >> ongoingPackageUnitsFrom: aCollection [
	^ aCollection collect: [ :each | (PBVcsSerializedPackageUnit fromDictionary: each) asOngoingPackage ]	
]

{ #category : #deserialization }
PBVcsSerializedProject >> pakbotProjectDependencyFrom: aDictionary [ 
	| repository |
	repository := self gitRepositoryFrom: (aDictionary at: #repository).
	^ PBPakbotProjectDependency 
		named: (aDictionary at: #name) 
		repositoryUrl: repository repositoryUrl
		version: (aDictionary at: #version)
		
]

{ #category : #deserialization }
PBVcsSerializedProject >> projectDependenciesFrom: aCollection [ 
	^ aCollection collect: [ :projectDependencyDict | 
		(projectDependencyDict includesKey: #configuration)
			ifTrue: [ self configurationProjectDependencyFrom: projectDependencyDict ]
			ifFalse: [ (projectDependencyDict includesKey: #baseline)
				ifTrue: [ self baselineProjectDependencyFrom: projectDependencyDict ]
				ifFalse: [ self pakbotProjectDependencyFrom: projectDependencyDict ] ]	]
]