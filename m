Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=BIGNUM_EMAILS,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26E51C0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 08:51:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C070D20657
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 08:51:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="qTc04UF5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C070D20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727953AbeKARxU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 13:53:20 -0400
Received: from userp2120.oracle.com ([156.151.31.85]:60928 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727704AbeKARxU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Nov 2018 13:53:20 -0400
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wA18iQJW147699;
        Thu, 1 Nov 2018 08:51:13 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : mime-version : content-type; s=corp-2018-07-02;
 bh=b+OnfMYORWGmWWasosb9vox0LbkiX2grcrJnF5y2vX4=;
 b=qTc04UF5c1/RLdHhCCFS0wh6UJMpsCSppMorv0TfiHzx5RTY6uanjJdGn8+FGBshT5G0
 auL2VNGiHjNP0a9TudFHwPB+he5zOaM/70zx/sRIFP/MgRoti+uurb933QI5uJCHEfIZ
 /3ULBF06tkX7CfgEcjSAQS/8J8Cjl0anocZjNmySyvLVzg63HIu69PnS/3ln0exquc0E
 SHF7cCzCUp+VijW0S+u5wmyGOD3hzoavXrKqbFucBOwsGBzhfjX6OTLSCHQtOm87pcdy
 x7+P+YM+krLXvRHoeaVc0gMHGaxGXHaGMnzluTaaGR5kTc06iV6GzA3PUeBw+/FIZIOf 7g== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by userp2120.oracle.com with ESMTP id 2ncgnr7kyh-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 01 Nov 2018 08:51:13 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wA18pDXF006497
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 1 Nov 2018 08:51:13 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wA18pC9t003382;
        Thu, 1 Nov 2018 08:51:12 GMT
Received: from kili.mountain (/129.205.6.86)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 01 Nov 2018 01:51:12 -0700
Date:   Thu, 1 Nov 2018 11:51:04 +0300
From:   Dan Carpenter <dan.carpenter@oracle.com>
To:     trond.myklebust@primarydata.com
Cc:     linux-nfs@vger.kernel.org
Subject: [bug report] SUNRPC: Ensure get_rpccred() and put_rpccred() can take
 NULL arguments
Message-ID: <20181101085104.ahh3fqnflsryfflf@kili.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: NeoMutt/20170113 (1.7.2)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9063 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=1 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=548
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1807170000 definitions=main-1811010078
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello Trond Myklebust,

The patch 9a8f6b5ea275: "SUNRPC: Ensure get_rpccred() and
put_rpccred() can take NULL arguments" from May 16, 2016, leads to
the following static checker warning:

	net/sunrpc/auth_generic.c:248 generic_key_timeout()
	warn: 'tcred' can also be NULL

net/sunrpc/auth_generic.c
   225  static int
   226  generic_key_timeout(struct rpc_auth *auth, struct rpc_cred *cred)
   227  {
   228          struct auth_cred *acred = &container_of(cred, struct generic_cred,
   229                                                  gc_base)->acred;
   230          struct rpc_cred *tcred;
   231          int ret = 0;
   232  
   233  
   234          /* Fast track for non crkey_timeout (no key) underlying credentials */
   235          if (auth->au_flags & RPCAUTH_AUTH_NO_CRKEY_TIMEOUT)
   236                  return 0;
   237  
   238          /* Fast track for the normal case */
   239          if (test_bit(RPC_CRED_NOTIFY_TIMEOUT, &acred->ac_flags))
   240                  return 0;
   241  
   242          /* lookup_cred either returns a valid referenced rpc_cred, or PTR_ERR */
   243          tcred = auth->au_ops->lookup_cred(auth, acred, 0);

It used to be that nul_lookup_cred() would always return valid pointers
but then we modified get_rpccred() to return NULL pointers.  If it
happened here, then it leads to a NULL pointer dereference.

   244          if (IS_ERR(tcred))
   245                  return -EACCES;
   246  
   247          /* Test for the almost error case */
   248          ret = tcred->cr_ops->crkey_timeout(tcred);
                      ^^^^^^^^^^^^^
Here.

   249          if (ret != 0) {
   250                  set_bit(RPC_CRED_KEY_EXPIRE_SOON, &acred->ac_flags);
   251                  ret = 0;
   252          } else {
   253                  /* In case underlying cred key has been reset */
   254                  if (test_and_clear_bit(RPC_CRED_KEY_EXPIRE_SOON,
   255                                          &acred->ac_flags))
   256                          dprintk("RPC:        UID %d Credential key reset\n",
   257                                  from_kuid(&init_user_ns, tcred->cr_uid));
   258                  /* set up fasttrack for the normal case */
   259                  set_bit(RPC_CRED_NOTIFY_TIMEOUT, &acred->ac_flags);
   260          }
   261  
   262          put_rpccred(tcred);
   263          return ret;
   264  }

regards,
dan carpenter
