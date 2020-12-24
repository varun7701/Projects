package apps;

import java.io.*;
import java.util.*;
import java.util.regex.*;

import structures.Stack;

public class Expression {

	/**
	 * Expression to be evaluated
	 */
	String expr;                
    
	/**
	 * Scalar symbols in the expression 
	 */
	ArrayList<ScalarSymbol> scalars;   
	
	/**
	 * Array symbols in the expression
	 */
	ArrayList<ArraySymbol> arrays;
    
    /**
     * String containing all delimiters (characters other than variables and constants), 
     * to be used with StringTokenizer
     */
    public static final String delims = " \t*+-/()[]";
    
    /**
     * Initializes this Expression object with an input expression. Sets all other
     * fields to null.
     * 
     * @param expr Expression
     */
    public Expression(String expr) {
        this.expr = expr;
    }

    /**
     * Populates the scalars and arrays lists with symbols for scalar and array
     * variables in the expression. For every variable, a SINGLE symbol is created and stored,
     * even if it appears more than once in the expression.
     * At this time, values for all variables are set to
     * zero - they will be loaded from a file in the loadSymbolValues method.
     */
    public void buildSymbols() {
    		/** COMPLETE THIS METHOD **/
		scalars = new ArrayList<ScalarSymbol>();
		arrays = new ArrayList<ArraySymbol>();
		StringTokenizer tokenized = new StringTokenizer(expr, delims);
		String str = "";
		while(tokenized.hasMoreTokens()) {
			str = tokenized.nextToken();
			int nextCharIndex = expr.indexOf(str) + str.length(); //index of character directly after token ends
			if(nextCharIndex >= expr.length()) { //if token = entire expr
				ScalarSymbol toAdd = new ScalarSymbol(str);
				scalars.add(toAdd);
				break;
			}
			
			else if(str.matches("\\d+")) { //if token is an integer constant, don't add to either ArrayList
				;
			}
			
			else if(expr.charAt(nextCharIndex) == '[') { //if nextChar is open bracket, then it represents an array value
				ArraySymbol toAdd = new ArraySymbol(str);
				if(!(arrays.contains(toAdd))) { //add if not already in arrays
					arrays.add(toAdd);
				}
			}
			
			else {         //not an integer, not an array, so must be a scalar value
				ScalarSymbol toAdd = new ScalarSymbol(str); 
				if(!(scalars.contains(toAdd))) {
					scalars.add(toAdd);
				}
			}
			
		}
		System.out.println(arrays);
    	System.out.println(scalars);
	}

    	
    	
    	
    
    /**
     * Loads values for symbols in the expression
     * 
     * @param sc Scanner for values input
     * @throws IOException If there is a problem with the input 
     */
    public void loadSymbolValues(Scanner sc) 
    throws IOException {
        while (sc.hasNextLine()) {
            StringTokenizer st = new StringTokenizer(sc.nextLine().trim());
            int numTokens = st.countTokens();
            String sym = st.nextToken();
            ScalarSymbol ssymbol = new ScalarSymbol(sym);
            ArraySymbol asymbol = new ArraySymbol(sym);
            int ssi = scalars.indexOf(ssymbol);
            int asi = arrays.indexOf(asymbol);
            if (ssi == -1 && asi == -1) {
            	continue;
            }
            int num = Integer.parseInt(st.nextToken());
            if (numTokens == 2) { // scalar symbol
                scalars.get(ssi).value = num;
            } else { // array symbol
            	asymbol = arrays.get(asi);
            	asymbol.values = new int[num];
                // following are (index,val) pairs
                while (st.hasMoreTokens()) {
                    String tok = st.nextToken();
                    StringTokenizer stt = new StringTokenizer(tok," (,)");
                    int index = Integer.parseInt(stt.nextToken());
                    int val = Integer.parseInt(stt.nextToken());
                    asymbol.values[index] = val;              
                }
            }
        }
    }
    
    
    /**
     * Evaluates the expression, using RECURSION to evaluate subexpressions and to evaluate array 
     * subscript expressions.
     * 
     * @return Result of evaluation
     */
    public float evaluate() {
    		/** COMPLETE THIS METHOD **/
    	expr = expr.replace(" ", "");
    	return evaluate(expr, 0, expr.length() - 1);
    	
    	
    } 
    
    
    private float evaluate(String expr, int startIndex, int endIndex) {
    	Stack<Float> stack1 = new Stack<Float>();
    	Stack<Character> stack2 = new Stack<Character>();
    	Stack<Float> copyStack1 = new Stack<Float>();
    	Stack<Character> copyStack2 = new Stack<Character>();
    	
    	
    	
    	
    	for(int i = startIndex; i < endIndex; i++) {
    		if(isNumber(expr.charAt(i))) { //if char is a float, get all digits of number and push
    			String fullNumber = expr.charAt(i) + "";
    			int nextChar = i + 1;
    			while(isNumber(expr.charAt(nextChar)) && nextChar <= endIndex) {
    				fullNumber += expr.charAt(nextChar);
    				nextChar++;
    			}
    			stack1.push(Float.parseFloat(fullNumber));
    			
    		}
    		
    		else if(expr.charAt(i) == '(') {   //if there is an other subexpression, find the end of it and evaluate it
    			int endOfSub = findEndSub(expr, i);
    			stack1.push(evaluate(expr, i + 1, endOfSub-1));
    			i = endOfSub;
    		}
    		
    		else if(Character.isLetter(expr.charAt(i))) { //if there is a variable
    			int st = i+1;
    			String var = expr.charAt(i)+"";
    			while(st <= endIndex && Character.isLetter(expr.charAt(st))){
    				var += expr.charAt(st);
    				st++;
    			}
    			if(containsArray(arrays,var)){
        			int[] temp = getArray(arrays, var).values;
        			int endOfArray = findEndSub(expr, i+var.length());
        			stack1.push((float)temp[(int)evaluate(expr,i+var.length(),endOfArray-1)]);
        			i = endOfArray;
        		}
    			else if(containsScalar(scalars,var)){
        			stack1.push((float)getScalar(scalars,var).value);
        			i = st-1; //Check the Index if it works
        		}
    		}
    		
    		if(!stack2.isEmpty() && (stack2.peek() == '/' || stack2.peek() == '*')){
    			char c = stack2.pop();
    			float b = stack1.pop();
    			float a = stack1.pop();
    			if(c == '*') {
    				stack1.push(a*b);
    				break;
    			}
    			else if(c == '/') {
    				stack1.push(a/b);
    				break;
    			}
    		}
    		else if(expr.charAt(i) == '+' || expr.charAt(i) == '-')
    			stack2.push(expr.charAt(i));
    		else if(expr.charAt(i) == '*' || expr.charAt(i) == '/')
    			stack2.push(expr.charAt(i));
    		
    	}
    	
    	
    	

    	while(!stack1.isEmpty())
    		copyStack1.push(stack1.pop());
    	while(!stack2.isEmpty())
    		copyStack2.push(stack2.pop());
    	while(copyStack1.size() > 1){
    		float b = copyStack1.pop();
			float a = copyStack1.pop();
			char c = copyStack2.pop();
			if(c == '*') {
				copyStack1.push(b+a);
				break;
			}
			else if(c == '/') {
				copyStack1.push(b-a);
				break;
			}
			
    	}
    	return copyStack1.pop();
    	
    	
    	
    	
    	
    	
    }
    
    
    
    
    private boolean containsArray(ArrayList<ArraySymbol> list, String name){
    	for(ArraySymbol temp: list){
    		if(temp.name.equals(name))
    			return true;
    	}
    	return false;
    }
    

    private boolean containsScalar(ArrayList<ScalarSymbol> list, String name){
    	for(ScalarSymbol temp: list){
    		if(temp.name.equals(name))
    			return true;
    	}
    	return false;
    }
    
    private ArraySymbol getArray(ArrayList<ArraySymbol> list, String name){
    	ArraySymbol arr = null;
    	for(ArraySymbol t: list){
    		if(t.name.equals(name))
    			arr = t;
    	}
    	return arr;
    }
    
    
    private ScalarSymbol getScalar(ArrayList<ScalarSymbol> list, String name){
    	ScalarSymbol sca = null;
    	for(ScalarSymbol t: list){
    		if(t.name.equals(name))
    			sca = t;
    	}
    	return sca;
    }
    
    
    
    
    private boolean isNumber(char i) {
    	if((i >= 48 && i <= 57) || i == 46) {
    		return true;
    	}
    	return false;
    }
    
    private int findEndSub(String expr, int start) {
    	Stack<Character> subExpr = new Stack<Character>();
    	subExpr.push(expr.charAt(start));
    	int i = start + 1;
    	while(subExpr.isEmpty() == false) {
    		if(expr.charAt(i) == '(' || expr.charAt(i) == '[') {
    			subExpr.push(expr.charAt(i));
    		}
    		else if(expr.charAt(i) == ')' || expr.charAt(i) == ']') {
    			subExpr.pop();
    		}
    		i++;
    	}
    	return i--;
    }
    
    

    /**
     * Utility method, prints the symbols in the scalars list
     */
    public void printScalars() {
        for (ScalarSymbol ss: scalars) {
            System.out.println(ss);
        }
    }
    
    /**
     * Utility method, prints the symbols in the arrays list
     */
    public void printArrays() {
    		for (ArraySymbol as: arrays) {
    			System.out.println(as);
    		}
    }

}
