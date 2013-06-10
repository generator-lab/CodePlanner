1. Create you DomainModel in the Model folder of the CORE project, at the end of this file is a simple example of two classes realting to each other.

2. Compile

3. Open the Package Manager Console.

4. Scaffold your backend by using the command "CodePlanner.ScaffoldBackend" in the PackageManagerConsole

5. You might also wanna scaffold viewmodels for javascript, ninject examples etc. Write Scaffold CodePlanner. + Tab to see options.

	//EXAMPLE DOMAIN MODEL
    public partial class Factory : PersistentEntity
    {
        public string Name { get; set; }

        public string Location { get; set; }

        public virtual IList<Product> Products { get; set; }
    }

    public partial class Product : PersistentEntity
    {
        public string Name { get; set; }

        public string Information { get; set; }
     
        public int ProductNumber { get; set; }

        public int Price { get; set; }

        public bool Active { get; set; }

        public virtual Factory Factory { get; set; }
    }