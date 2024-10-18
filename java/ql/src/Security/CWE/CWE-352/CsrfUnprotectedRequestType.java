// BAD - a GET request should not be used with a state-changing action like transfer
@RequestMapping(value="transfer", method=RequestMethod.GET)
public boolean transfer(HttpServletRequest request, HttpServletResponse response){
  return sendMoney(request, response);
}
