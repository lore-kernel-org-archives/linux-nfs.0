Return-Path: <SRS0=F+UG=PM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 731CAC43387
	for <linux-nfs@archiver.kernel.org>; Fri,  4 Jan 2019 06:47:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3EF8520665
	for <linux-nfs@archiver.kernel.org>; Fri,  4 Jan 2019 06:47:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="w5lFyNZR"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725931AbfADGrX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 4 Jan 2019 01:47:23 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:41210 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725919AbfADGrX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jan 2019 01:47:23 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x046d29o142320;
        Fri, 4 Jan 2019 06:47:17 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : mime-version : content-type; s=corp-2018-07-02;
 bh=o/zTzTPv6oV6tNU7SkTbOjy+I1tkDNYCb4WAgueH8O0=;
 b=w5lFyNZRm8n4q5flK+PxqZn9Wy+pro2QZXw1X01l8fKnQZkB3oN8zrc5PyAKZ+DXBd5A
 3eBT3wMTeTXwRnzxH/XHR9xWAJdB7J1s9K5V+onhZ+MLW1bayOTwSDjKzCvauXWVvsh7
 P1aUw3fUXPWlTKh/EZC9mruogGBX+Q2lLtI9RhC2+1JhNahOZ9ORgxLvQDr4dQYHaDj0
 QyVF8sqtrZRl87sEqjmOQMpJ9R9sDDXRv/w7/hNYoEb1tOpJXUKQ1krStTvT7+MOcT3J
 60fNuiVO1Aniq7B6C6GcRiqXsoKGCQkVv2gBkOsq4iecW/94AY5I+tq6Owwm9yFBShSt CA== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by aserp2130.oracle.com with ESMTP id 2pnxeeat2h-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 04 Jan 2019 06:47:17 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x046lA1w027325
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 4 Jan 2019 06:47:11 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x046lAPv015741;
        Fri, 4 Jan 2019 06:47:10 GMT
Received: from kadam (/41.202.241.42)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 03 Jan 2019 22:47:10 -0800
Date:   Fri, 4 Jan 2019 09:47:03 +0300
From:   Dan Carpenter <dan.carpenter@oracle.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        NeilBrown <neilb@suse.com>
Cc:     Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: [PATCH] nfsd: fix an IS_ERR() vs NULL check
Message-ID: <20190104064703.GB30627@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Mailer: git-send-email haha only kidding
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9125 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901040059
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The get_backchannel_cred() used to return error pointers on error but
now it returns NULL pointers.

Fixes: 97f68c6b02e0 ("SUNRPC: add 'struct cred *' to auth_cred and rpc_cre")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 fs/nfsd/nfs4callback.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index c74e4538d0eb..9b38dab1c21b 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -913,9 +913,9 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
 		return PTR_ERR(client);
 	}
 	cred = get_backchannel_cred(clp, client, ses);
-	if (IS_ERR(cred)) {
+	if (!cred) {
 		rpc_shutdown_client(client);
-		return PTR_ERR(cred);
+		return -ENOMEM;
 	}
 	clp->cl_cb_client = client;
 	clp->cl_cb_cred = cred;
-- 
2.17.1

