import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class TestRunner {

    @Test
    void testAll() {
        // Use relativeTo(getClass()) to ensure the path is resolved correctly
        // from the location of this Java class
        Results results = Runner.path("classpath:features")
                .tags(System.getProperty("karate.options"))
                .relativeTo(getClass())
                .outputHtmlReport(true)
                .parallel(5);

        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}