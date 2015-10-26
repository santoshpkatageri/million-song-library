package io.swagger.model;


import io.swagger.annotations.*;
import com.fasterxml.jackson.annotation.JsonProperty;


@ApiModel(description = "")
@javax.annotation.Generated(value = "class io.swagger.codegen.languages.JaxRSServerCodegen", date = "2015-10-20T17:56:37.516-06:00")
public class LoginSuccessResponse  {
  
  private String sessionToken = null;

  
  /**
   **/
  @ApiModelProperty(required = true, value = "")
  @JsonProperty("sessionToken")
  public String getSessionToken() {
    return sessionToken;
  }
  public void setSessionToken(String sessionToken) {
    this.sessionToken = sessionToken;
  }

  

  @Override
  public String toString()  {
    StringBuilder sb = new StringBuilder();
    sb.append("class LoginSuccessResponse {\n");
    
    sb.append("  sessionToken: ").append(sessionToken).append("\n");
    sb.append("}\n");
    return sb.toString();
  }
}