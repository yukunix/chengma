package com.chengma.devplatform.web.rest;

import com.chengma.devplatform.common.constant.DevplatformConstants;
import com.chengma.devplatform.common.dao.ResponseResult;
import com.chengma.devplatform.domain.User;
import com.chengma.devplatform.security.AuthoritiesConstants;
import com.chengma.devplatform.service.TlbAccountService;
import com.chengma.devplatform.service.UserService;
import com.chengma.devplatform.service.dto.TlbAccountDTO;
import com.chengma.devplatform.web.rest.util.HeaderUtil;
import com.chengma.devplatform.web.rest.util.PaginationUtil;
import com.chengma.devplatform.web.rest.vm.LoginVM;
import com.codahale.metrics.annotation.Timed;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.annotation.Secured;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.validation.Valid;
import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.List;

/**
 * REST controller for managing SysComponent.
 */
@RestController
@RequestMapping("/api")
public class TlbAccountResource {

    private final Logger log = LoggerFactory.getLogger(TlbAccountResource.class);

    private static final String ENTITY_NAME = "tlbAccount";

    private final TlbAccountService tlbAccountService;

    private final UserJWTController userJWTController;

    private final UserService userService;

    public TlbAccountResource(TlbAccountService tlbAccountService, UserJWTController userJWTController, UserService userService) {
        this.tlbAccountService = tlbAccountService;
        this.userJWTController = userJWTController;
        this.userService = userService;
    }

    /**
     * POST  /sys-components : Create a new sysComponent.
     *
     * @param tlbAccountDTO the sysComponentDTO to create
     * @return the ResponseEntity with status 201 (Created) and with body the new sysComponentDTO, or with status 400 (Bad Request) if the sysComponent has already an ID
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PostMapping("/tlb-account/createTlbAccount")
    @Timed
    public ResponseEntity<ResponseResult> createTlbAccount(@RequestBody TlbAccountDTO tlbAccountDTO) throws URISyntaxException {
        log.debug("REST request to save TlbAccount : {}", tlbAccountDTO);
        if (tlbAccountDTO.getId() != null) {
            return ResponseEntity.badRequest().headers(HeaderUtil.createFailureAlert(ENTITY_NAME, "idexists", "A new sysComponent cannot already have an ID")).body(null);
        }
        ResponseResult json = new ResponseResult();
        HashMap<String, Object> params = new HashMap<>();
        params.put("account", tlbAccountDTO.getAccount());
        params.put("group", tlbAccountDTO.getGroup());
        HashMap<String, Object> checkMap = tlbAccountService.checkAccountInfo(params);
        if(!ResponseResult.SUCCESS_CODE.equals(checkMap.get("statusCode"))){
            json.setMsgCode(checkMap.get("msg").toString());
            return new ResponseEntity<>(json, null, HttpStatus.OK);
        }
        TlbAccountDTO accountDTO = tlbAccountService.save(tlbAccountDTO);

        json.setStatusCode(ResponseResult.SUCCESS_CODE);
        json.setData(accountDTO);
        return new ResponseEntity<>(json, null, HttpStatus.OK);
    }


    /**
     * POST  /sys-components : Create a new sysComponent.
     *
     * @param params the sysComponentDTO to create
     * @return the ResponseEntity with status 201 (Created) and with body the new sysComponentDTO, or with status 400 (Bad Request) if the sysComponent has already an ID
     * @throws URISyntaxException if the Location URI syntax is incorrect
     */
    @PostMapping("/tlb-account/createCrmTlbAccount")
    @Timed
    @Secured(AuthoritiesConstants.ADMIN)
    public ResponseEntity<ResponseResult> createCrmTlbAccount(@RequestBody HashMap<String, Object> params) throws URISyntaxException {
        log.debug("REST request to save  crm user TlbAccount  : {}", params);
        ResponseResult json = new ResponseResult();
        HashMap<String, Object> checkMap = tlbAccountService.checkAccountInfo(params);
        if(!ResponseResult.SUCCESS_CODE.equals(checkMap.get("statusCode"))){
            json.setMsgCode(checkMap.get("msg").toString());
            return new ResponseEntity<>(json, null, HttpStatus.OK);
        }
        checkMap = tlbAccountService.checkCrmMobile(params);
        if(!ResponseResult.SUCCESS_CODE.equals(checkMap.get("statusCode"))){
            json.setMsgCode(checkMap.get("msg").toString());
            return new ResponseEntity<>(json, null, HttpStatus.OK);
        }
        TlbAccountDTO accountDTO = tlbAccountService.createCrmTlb(params);

        json.setStatusCode(ResponseResult.SUCCESS_CODE);
        json.setData(accountDTO);
        return new ResponseEntity<>(json, null, HttpStatus.OK);
    }


    @PostMapping("/tlb-account/updateTlbAccount")
    @Timed
    public ResponseEntity<ResponseResult> updateTlbAccount(@RequestBody TlbAccountDTO tlbAccountDTO) throws URISyntaxException {
        log.debug("REST request to update TlbAccount : {}", tlbAccountDTO);
        if (tlbAccountDTO.getId() == null) {
            return createTlbAccount(tlbAccountDTO);
        }
        TlbAccountDTO tlbAccountDTO1 = tlbAccountService.save(tlbAccountDTO);;
        ResponseResult json = new ResponseResult();
        json.setStatusCode(ResponseResult.SUCCESS_CODE);
        json.setData(tlbAccountDTO1);
        return new ResponseEntity<>(json, null, HttpStatus.OK);
    }


    /**
     * GET  /sys-components : get all the sysComponents.
     *
     * @param params the pagination information
     * @return the ResponseEntity with status 200 (OK) and the list of sysComponents in body
     */
    @PostMapping("/tlb-account/pageList")
    @Timed
    public ResponseEntity<ResponseResult> pageList(@RequestBody  HashMap<String, Object> params) {
        log.debug("REST request to get a page of TlbAccount");
        Page<TlbAccountDTO> page = tlbAccountService.pageList(params);
        HttpHeaders headers = PaginationUtil.generatePaginationHttpHeaders(page, "/api/tbl-user");
        ResponseResult json = new ResponseResult();
        HashMap<String, Object> retMap = new HashMap<>();
        retMap.put("list", page.getContent());
        retMap.put("total", page.getTotalElements());
        retMap.put("totalPage", page.getTotalPages());
        json.setData(retMap);
        json.setStatusCode(ResponseResult.SUCCESS_CODE);
        return new ResponseEntity<>(json, headers, HttpStatus.OK);
    }
    /**
     * GET  /sys-components : get all the sysComponents.
     *
     * @param params the pagination information
     * @return the ResponseEntity with status 200 (OK) and the list of sysComponents in body
     */
    @PostMapping("/tlb-account/getAll")
    @Timed
    public ResponseEntity<ResponseResult> getAll(@RequestBody HashMap<String, Object> params) {
        log.debug("REST request to get a page of TlbAccount");
        List<TlbAccountDTO> tlbAccountDTOList = tlbAccountService.findAll(params);
        ResponseResult json = new ResponseResult();
        json.setData(tlbAccountDTOList);
        json.setStatusCode(ResponseResult.SUCCESS_CODE);
        return new ResponseEntity<>(json, HttpStatus.OK);
    }

    /**
     * 提现
     * @param params
     * @return
     */

    @PostMapping("/tlb-account/withdrawals")
    @Timed
    public ResponseEntity<ResponseResult> withdrawals(@RequestBody HashMap<String, Object> params) {
        log.debug("REST request to withdrawals from TlbAccount");
        ResponseResult json = new ResponseResult();
        HashMap<String, Object> checkMap = tlbAccountService.checkWithdrawals(params);
        if(!ResponseResult.SUCCESS_CODE.equals(checkMap.get("statusCode"))){
            json.setMsgCode(checkMap.get("msg").toString());
            return new ResponseEntity<>(json, null, HttpStatus.OK);
        }
        TlbAccountDTO tlbAccountDTO = tlbAccountService.withdrawals(params);
        json.setData(tlbAccountDTO);
        json.setStatusCode(ResponseResult.SUCCESS_CODE);
        return new ResponseEntity<>(json, HttpStatus.OK);
    }

    @PostMapping("/tlb-account/recharge")
    @Timed
    public ResponseEntity<ResponseResult> recharge(@RequestBody HashMap<String, Object> params) {
        log.debug("REST request to get a page of TlbAccount");
        TlbAccountDTO tlbAccountDTO = tlbAccountService.recharge(params);
        ResponseResult json = new ResponseResult();
        json.setData(tlbAccountDTO);
        json.setStatusCode(ResponseResult.SUCCESS_CODE);
        return new ResponseEntity<>(json, HttpStatus.OK);
    }
    /**
     * GET  /sys-components/:id : get the "id" sysComponent.
     *
     * @param id the id of the sysComponentDTO to retrieve
     * @return the ResponseEntity with status 200 (OK) and with body the sysComponentDTO, or with status 404 (Not Found)
     */
    @GetMapping("/tlb-account/getTlbAccount/{id}")
    @Timed
    public ResponseEntity<ResponseResult> getTlbAccount(@PathVariable String id) {
        log.debug("REST request to get TlbAccount : {}", id);
        ResponseResult json = new ResponseResult();

        try {
            TlbAccountDTO sysComponentDTO = tlbAccountService.findOne(id);
            json.setData(sysComponentDTO);
            json.setStatusCode(ResponseResult.SUCCESS_CODE);
        }catch (Exception e){
            json.setStatusCode(ResponseResult.FAIL_CODE);
        }
        return new ResponseEntity<>(json, null, HttpStatus.OK);
    }


    @DeleteMapping("/tlb-account/deleteTlbAccount/{id}")
    @Timed
    public ResponseEntity<ResponseResult> deleteTlbAccount(@PathVariable String id) {
        log.debug("REST request to get TlbAccount : {}", id);
        tlbAccountService.delete(id);
        ResponseResult json = new ResponseResult();
        json.setStatusCode(ResponseResult.SUCCESS_CODE);
        return new ResponseEntity<>(json, null, HttpStatus.OK);
    }

    @GetMapping("/tlb-account/getTlbAccountByNo/{account}")
    @Timed
    public ResponseEntity<ResponseResult> getAccount(@PathVariable String account) {
        log.debug("REST request to get TlbAccount : {}", account);

        ResponseResult json = new ResponseResult();
        json.setData(tlbAccountService.findByAccount(account));
        json.setStatusCode(ResponseResult.SUCCESS_CODE);
        return new ResponseEntity<>(json, null, HttpStatus.OK);
    }

    /**
     *修改账户交易密码
     * @param params (account oldPassword newPassword)
     * @return
     */
    @PostMapping("/tlb-account/editPassword")
    @Timed
    public ResponseEntity<ResponseResult> editPassword(@RequestBody HashMap<String, Object> params) {
        TlbAccountDTO tlbAccountDTO = tlbAccountService.editTradePassword(params);
        log.debug("REST request to editTlbAccountMt4Password  : {}", params.get("newPassword").toString());
        ResponseResult json = new ResponseResult();
        if(tlbAccountDTO==null){
            json.setStatusCode(ResponseResult.FAIL_CODE);
            json.setMsgCode(DevplatformConstants.ERROR_USER_OR_PASSWORD);
        }else{
            json.setData(tlbAccountDTO);
            json.setStatusCode(ResponseResult.SUCCESS_CODE);
        }
        return new ResponseEntity<>(json, null, HttpStatus.OK);
    }

    /**
     *修改账户交易密码
     * @param params (account oldPassword newPassword)
     * @return
     */
    @PostMapping("/tlb-account/editSeePassword")
    @Timed
    public ResponseEntity<ResponseResult> editSeePassword(@RequestBody HashMap<String, Object> params) {
        TlbAccountDTO tlbAccountDTO = tlbAccountService.editSeePassword(params);
        log.debug("REST request to editTlbAccountSeePassword  : {}", params.get("newPassword").toString());
        ResponseResult json = new ResponseResult();
        if(tlbAccountDTO==null){
            json.setStatusCode(ResponseResult.FAIL_CODE);
            json.setMsgCode(DevplatformConstants.ERROR_USER_OR_PASSWORD);
        }else{
            json.setData(tlbAccountDTO);
            json.setStatusCode(ResponseResult.SUCCESS_CODE);
        }
        return new ResponseEntity<>(json, null, HttpStatus.OK);
    }

    @PostMapping("/tlb-account/verification")
    @Timed
    public ResponseEntity<ResponseResult> verification(@Valid @RequestBody LoginVM loginVM, HttpServletResponse response, HttpServletRequest request) {
        ResponseResult returnResponse = new ResponseResult();

        TlbAccountDTO tlbAccountDTO = tlbAccountService.findByAccountAndPassword(loginVM.getUsername(), loginVM.getPassword());

        //觀摩賬號
        if(tlbAccountDTO == null){
            tlbAccountDTO = tlbAccountService.findByAccountEqualsAndSeePasswordEquals(loginVM.getUsername(), loginVM.getPassword());
            if(null != tlbAccountDTO) {
                tlbAccountDTO.setEnableTrade("N");
            }
        }

        if(null != tlbAccountDTO){
            //处理手机认证登录
            //String mobile = params.get("mobileNum").toString();
            User dbUser = userService.getUserWithAuthorities(tlbAccountDTO.getUserId());
            //查询是否已经进行登记
            //已登记，直接跳转到后台
            if (dbUser != null) {
                loginVM = new LoginVM();
                loginVM.setUsername(dbUser.getLogin());
                loginVM.setPassword(dbUser.getPasswordRemark());
                return userJWTController.inAuthorize(request, loginVM, response, true,tlbAccountDTO);
            }
        }else{
            String msgCode = DevplatformConstants.ERROR_USER_OR_PASSWORD;
            returnResponse.setMsgCode(msgCode);
        }
        return new ResponseEntity<>(returnResponse, null, HttpStatus.OK);
    }

    @PostMapping("/tlb-account/confirmAccount")
    @Timed
    public ResponseEntity<ResponseResult> confirmAccount( @RequestBody TlbAccountDTO tlbAccountDTO) {
        ResponseResult json = new ResponseResult();
        HashMap<String, Object> checkMap = tlbAccountService.confirmAccount(tlbAccountDTO);
        if(!ResponseResult.SUCCESS_CODE.equals(checkMap.get("statusCode"))){
            json.setMsgCode(checkMap.get("msg").toString());
            return new ResponseEntity<>(json, null, HttpStatus.OK);
        }
        log.debug("REST request to confirmAccount TlbAccountDTO : {}", tlbAccountDTO);
        json.setStatusCode(ResponseResult.SUCCESS_CODE);
        return new ResponseEntity<>(json, null, HttpStatus.OK);
    }

    @GetMapping("/tlb-account/resetPassword/{id}")
    @Timed
    public ResponseEntity<ResponseResult> resetPassword(@PathVariable String id) {
        log.debug("REST request to resetPassword TlbAccount : {}", id);
        tlbAccountService.resetPassword(id);
        ResponseResult json = new ResponseResult();
        json.setStatusCode(ResponseResult.SUCCESS_CODE);
        return new ResponseEntity<>(json, null, HttpStatus.OK);
    }
}

