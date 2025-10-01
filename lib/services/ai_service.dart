import 'dart:async';
import 'dart:math';

class AIService {
  final Random _random = Random();

  // Respuestas simuladas más elaboradas y realistas
  final List<String> _sampleResponses = [
    '''Entiendo tu pregunta. Basándome en mi conocimiento, puedo decirte que este es un tema fascinante que tiene múltiples perspectivas.

Primero, es importante considerar el contexto histórico y las implicaciones actuales. Los expertos en el campo han identificado varios factores clave:

1. **Factor principal**: La evolución constante de las tecnologías y metodologías
2. **Consideraciones secundarias**: El impacto en diferentes sectores
3. **Perspectivas futuras**: Tendencias emergentes y oportunidades

Te recomendaría explorar más a fondo estos aspectos para obtener una comprensión completa del tema.''',

    '''Excelente pregunta. Déjame explicártelo de manera detallada:

La respuesta a esto involucra varios componentes interrelacionados. En primer lugar, debemos entender los fundamentos básicos antes de profundizar en aspectos más complejos.

**Puntos clave a considerar:**

• **Aspecto técnico**: Las especificaciones y requisitos actuales
• **Aspecto práctico**: Aplicaciones del mundo real y casos de uso
• **Aspecto evolutivo**: Cómo ha cambiado con el tiempo

Además, es fundamental tener en cuenta las mejores prácticas de la industria y las recomendaciones de expertos reconocidos en el campo.

¿Hay algún aspecto específico sobre el que te gustaría que profundice más?''',

    '''Basándome en la información disponible, puedo ofrecerte una perspectiva integral sobre este tema:

**Contexto General**
Este es un área que ha experimentado un desarrollo significativo en los últimos años, con avances notables en múltiples frentes.

**Análisis Detallado**
1. Los fundamentos teóricos proporcionan una base sólida
2. Las implementaciones prácticas han demostrado su efectividad
3. Las tendencias futuras sugieren un potencial considerable

**Recomendaciones**
Para aprovechar al máximo este conocimiento, te sugiero:
- Investigar casos de estudio relevantes
- Experimentar con diferentes enfoques
- Mantenerte actualizado con las últimas novedades

¿Te gustaría que elabore sobre algún punto en particular?''',

    '''Interesante consulta. Voy a desglosar esto en partes más manejables:

**Primera Parte: Fundamentos**
Los conceptos básicos que necesitas entender incluyen las definiciones clave y los principios fundamentales que gobiernan este dominio.

**Segunda Parte: Aplicaciones Prácticas**
En la práctica, esto se traduce en soluciones concretas que pueden implementarse en diversos escenarios. Las organizaciones líderes han adoptado enfoques innovadores que han demostrado resultados positivos.

**Tercera Parte: Consideraciones Avanzadas**
Para usuarios más experimentados, existen técnicas avanzadas y optimizaciones que pueden mejorar significativamente los resultados.

**Conclusión**
La clave está en encontrar el equilibrio adecuado entre teoría y práctica, adaptando las soluciones a tus necesidades específicas.''',

    '''Gracias por tu pregunta. Permíteme proporcionarte una respuesta comprehensiva:

**Introducción**
Este tema abarca un espectro amplio de conceptos y aplicaciones que son relevantes tanto para principiantes como para usuarios avanzados.

**Desarrollo**
Los aspectos más importantes a considerar incluyen:

1. **Metodología**: Enfoques sistemáticos y estructurados
2. **Herramientas**: Recursos disponibles y sus capacidades
3. **Mejores Prácticas**: Estándares de la industria y recomendaciones

**Ejemplos Prácticos**
Algunas situaciones donde esto es particularmente útil:
- Escenarios empresariales complejos
- Proyectos de innovación tecnológica
- Soluciones a desafíos específicos del sector

**Conclusiones**
La implementación exitosa requiere planificación cuidadosa y adaptación continua a las necesidades cambiantes.

¿Necesitas ayuda con algún aspecto específico de la implementación?''',
  ];

  // Respuestas contextuales según palabras clave
  String _getContextualResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('código') ||
        lowerMessage.contains('programación') ||
        lowerMessage.contains('programa')) {
      return '''Claro, hablemos sobre programación. 

**Conceptos Fundamentales**
La programación es el arte de resolver problemas mediante instrucciones que una computadora puede ejecutar. Los elementos clave incluyen:

• **Algoritmos**: Secuencias lógicas de pasos
• **Estructuras de datos**: Organización eficiente de información
• **Paradigmas**: Diferentes enfoques (POO, funcional, etc.)

**Mejores Prácticas**
1. Código limpio y legible
2. Documentación apropiada
3. Testing exhaustivo
4. Refactorización continua

**Lenguajes Populares**
Dependiendo de tu objetivo, lenguajes como Python, JavaScript, Java, o Dart (para Flutter) son excelentes opciones.

¿Hay algún lenguaje o concepto específico sobre el que quieras aprender más?''';
    }

    if (lowerMessage.contains('ayuda') || lowerMessage.contains('ayudar')) {
      return '''¡Por supuesto que puedo ayudarte! Estoy aquí para asistirte con una amplia variedad de temas.

**Mis Capacidades**
Puedo ayudarte con:

📚 **Conocimiento General**
- Responder preguntas sobre diversos temas
- Explicar conceptos complejos de manera simple
- Proporcionar información actualizada

💻 **Programación y Tecnología**
- Ayuda con código y debugging
- Explicación de conceptos técnicos
- Sugerencias de mejores prácticas

✍️ **Escritura y Creatividad**
- Redacción y edición de textos
- Ideas creativas y brainstorming
- Estructuración de contenido

🎯 **Productividad**
- Organización y planificación
- Resolución de problemas
- Consejos y recomendaciones

Por favor, cuéntame más sobre lo que necesitas y estaré encantado de asistirte de la mejor manera posible.''';
    }

    if (lowerMessage.contains('flutter') || lowerMessage.contains('dart')) {
      return '''¡Excelente elección! Flutter es un framework increíblemente potente para desarrollo multiplataforma.

**¿Por qué Flutter?**
• Rendimiento nativo en iOS y Android
• Hot Reload para desarrollo ágil
• Rica biblioteca de widgets personalizables
• Comunidad activa y creciente

**Conceptos Clave**
1. **Widgets**: Todo en Flutter es un widget
2. **State Management**: Provider, Riverpod, Bloc, etc.
3. **Material Design & Cupertino**: Diseños nativos
4. **Dart Language**: Lenguaje moderno y eficiente

**Arquitectura Recomendada**
- Separación de responsabilidades
- Clean Architecture
- Dependency Injection
- Testing comprehensivo

**Recursos Útiles**
- Documentación oficial de Flutter
- Paquetes en pub.dev
- Comunidad en Discord y Stack Overflow

¿En qué aspecto específico de Flutter necesitas ayuda?''';
    }

    // Respuesta por defecto aleatoria
    return _sampleResponses[_random.nextInt(_sampleResponses.length)];
  }

  // Simular delay de respuesta con streaming
  Stream<String> generateResponse(String userMessage) async* {
    // Simular tiempo de "pensamiento"
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));

    final response = _getContextualResponse(userMessage);
    final words = response.split(' ');

    // Simular escritura palabra por palabra
    StringBuffer currentText = StringBuffer();

    for (int i = 0; i < words.length; i++) {
      currentText.write(words[i]);
      if (i < words.length - 1) {
        currentText.write(' ');
      }

      yield currentText.toString();

      // Delay variable entre palabras para mayor realismo
      final delay = _random.nextInt(50) + 20;
      await Future.delayed(Duration(milliseconds: delay));

      // Pausas más largas después de puntos y comas
      if (words[i].endsWith('.') ||
          words[i].endsWith(',') ||
          words[i].endsWith(':')) {
        await Future.delayed(
          Duration(milliseconds: 100 + _random.nextInt(200)),
        );
      }
    }
  }

  // Generar título para la conversación basado en el primer mensaje
  String generateChatTitle(String firstMessage) {
    if (firstMessage.length <= 30) {
      return firstMessage;
    }

    // Tomar las primeras palabras significativas
    final words = firstMessage.split(' ');
    final significantWords = words.where((word) => word.length > 3).take(4);

    if (significantWords.isEmpty) {
      return '${words.take(3).join(' ')}...';
    }

    return '${significantWords.join(' ')}...';
  }

  // Sugerencias de seguimiento
  List<String> getSuggestedFollowUps(String lastAIMessage) {
    return [
      '¿Puedes explicar más sobre esto?',
      'Dame un ejemplo práctico',
      '¿Cuáles son las alternativas?',
      'Profundiza en este tema',
    ];
  }
}
