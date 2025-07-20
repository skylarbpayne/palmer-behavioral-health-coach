export class Logger {
  private static logs: string[] = [];
  
  static log(...args: any[]) {
    const message = args.map(arg => 
      typeof arg === 'object' ? JSON.stringify(arg) : String(arg)
    ).join(' ');
    
    const timestamp = new Date().toLocaleTimeString();
    const logEntry = `[${timestamp}] ${message}`;
    
    this.logs.push(logEntry);
    console.log(...args); // Still try console.log
    
    // Keep only last 100 logs
    if (this.logs.length > 100) {
      this.logs = this.logs.slice(-100);
    }
  }
  
  static error(...args: any[]) {
    const message = args.map(arg => 
      typeof arg === 'object' ? JSON.stringify(arg) : String(arg)
    ).join(' ');
    
    const timestamp = new Date().toLocaleTimeString();
    const logEntry = `[${timestamp}] ERROR: ${message}`;
    
    this.logs.push(logEntry);
    console.error(...args); // Still try console.error
  }
  
  static getLogs(): string[] {
    return [...this.logs];
  }
  
  static clearLogs() {
    this.logs = [];
  }
}