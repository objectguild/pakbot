as yet unclassified
dependencies
	"(package addDependency: 'Seaside-Tools-Web')
		addFixedVersionConstraint: package version;
		yourself.
	(package addDependency: 'Seaside-Core')
		addFixedVersionConstraint: package version;
		yourself.
	(package addDependency: 'Seaside-Canvas')
		addFixedVersionConstraint: package version;
		yourself.
"
	^ #()