public with sharing class BotController {

    public class HandlerMapping {
        
        public String handlerClassName;
        public Pattern utterancePattern;

        public HandlerMapping(String handlerClassName, String patternStr) {
            this.handlerClassName = handlerClassName;
            this.utterancePattern = Pattern.compile(patternStr);
        }

    }

    static List<HandlerMapping> handlerMappings;
    
    static {
        List<Bot_Command__c> commands = [SELECT apex_class__c, pattern__c FROM Bot_Command__c WHERE Active__c = True ORDER BY Name];
        System.debug(commands);
        List<HandlerMapping> mappings = new List<HandlerMapping>();
        for (Bot_Command__c command : commands) {
			mappings.add(new HandlerMapping(command.apex_class__c, command.pattern__c));
        }
        handlerMappings = mappings;
    }
    
    @AuraEnabled
    public static BotResponse submit(String utterance, Map<String, String> session, String fileName, String fileContent) {
        
        try {
            
            if (session != null) {
                String nextCommand = session.get('nextCommand');
                if (nextCommand != null) {
                    Type t = Type.forName('', nextCommand);
                    BotHandler handler = (BotHandler)t.newInstance();
                    return handler.handle(utterance, null, session, fileName, fileContent);
                }
            }
        
            for (HandlerMapping mapping : BotController.handlerMappings) {
                List<String> params = new List<String>();
                BotHandler handler = findMatchingHandlerIfPossible(mapping, utterance, session, params);
                if (handler != null) {
                    return handler.handle(utterance, params, session, fileName, fileContent);
                }
            }
            
            return new BotResponse(new BotMessage('Bot', 'I don\'t know how to answer that'));
            
        } catch (Exception e) {
            System.debug(e);                
            return new BotResponse(new BotMessage('Bot', 'Oops, something went wrong invoking that command'));
        }
        
    }

    public static BotHandler findMatchingHandlerIfPossible(HandlerMapping mapping, String utterance, Map<String, String> session, List<String> params) {
        // String patternToMatch = mapping.utterancePattern.pattern();
        // System.debug('[BotController.cls] Pattern to match: ' + patternToMatch);
        Matcher utteranceMatcher = mapping.utterancePattern.matcher(utterance);
        if (utteranceMatcher.matches()) {
            Type t = Type.forName('', mapping.handlerClassName);
            BotHandler handler = (BotHandler)t.newInstance();
            for (Integer i = 1; i <= utteranceMatcher.groupCount(); i++) {
                params.add(utteranceMatcher.group(i).trim());
            }
            return handler;
        } else {
            return null;
        }
}
    
}