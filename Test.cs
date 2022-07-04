using System;

namespace StartupClass
{
    public interface ITest
    {
        void Invoke();
    }

    public class Test : ITest
    {
        public Guid Id { get; set; }

        public Test()
        {
            Id = Guid.NewGuid();
        }
    
        public void Invoke()
        {
        
        }
    }
}