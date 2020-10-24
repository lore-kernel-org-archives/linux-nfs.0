Return-Path: <SRS0=awoq=D7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.9 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D245AC2D0A3
	for <linux-nfs@archiver.kernel.org>; Sat, 24 Oct 2020 21:39:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 915AA22210
	for <linux-nfs@archiver.kernel.org>; Sat, 24 Oct 2020 21:39:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="uizQMAk8"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1764955AbgJXVjH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 24 Oct 2020 17:39:07 -0400
Received: from userp2120.oracle.com ([156.151.31.85]:40534 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1765137AbgJXVjE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Oct 2020 17:39:04 -0400
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.42/8.16.0.42) with SMTP id 09OLWhs4026528;
        Sat, 24 Oct 2020 21:38:56 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id; s=corp-2020-01-29;
 bh=e1lTqXLcN5w00NKyttGMzYu+FWxt1ovJrYWEOkDWP80=;
 b=uizQMAk8XeEwFWBgtyaffLpnOgTwYbnO3BRolFl3O+qB6A78XCN0Uiwo0S8xKyV7clHh
 dqSGMeIuymxy9nn5no08154e6K1TmsbByurMoXJS/kUNUN28wxSqJrSPXK7ZD+QBV5bM
 HAAAPdhHuv7lQ3WRkp0Nx6YNIURlmfSMwZmyp+2wVmNGAEO47mBOWwrUolmqpQnOMOnM
 22azSbARDQLUzc3GSGPUDu0/GAODjQWUHvX6bweLtze1ZYTDcgFdjN95cbJWbYcMYr9I
 xNF2/93fRDfqJ9BjKLH1aKUa2kq87sZX6rtTTKXbTkWWz8zf4eKgO6V8Vm9tCS0DnAeU 7g== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
        by userp2120.oracle.com with ESMTP id 34ccwmh3kx-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
        Sat, 24 Oct 2020 21:38:56 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
        by userp3030.oracle.com (8.16.0.42/8.16.0.42) with SMTP id 09OLVATd101963;
        Sat, 24 Oct 2020 21:36:56 GMT
Received: from pps.reinject (localhost [127.0.0.1])
        by userp3030.oracle.com with ESMTP id 34c9cr9gkq-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
        Sat, 24 Oct 2020 21:36:56 +0000
Received: from userp3030.oracle.com (userp3030.oracle.com [127.0.0.1])
        by pps.reinject (8.16.0.36/8.16.0.36) with SMTP id 09OLau1K107516;
        Sat, 24 Oct 2020 21:36:56 GMT
Received: from cdmvmol7.uk.oracle.com (dhcp-10-175-182-191.vpn.oracle.com [10.175.182.191])
        by userp3030.oracle.com with ESMTP id 34c9cr9gka-1;
        Sat, 24 Oct 2020 21:36:55 +0000
From:   Calum Mackay <calum.mackay@oracle.com>
To:     trondmy@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: correct error code comment in xs_tcp_setup_socket()
Date:   Sat, 24 Oct 2020 22:36:38 +0100
Message-Id: <20201024213638.16697-1-calum.mackay@oracle.com>
X-Mailer: git-send-email 2.18.4
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9784 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 phishscore=0 mlxscore=0 adultscore=0
 spamscore=0 mlxlogscore=999 clxscore=1011 malwarescore=0
 priorityscore=1501 impostorscore=0 bulkscore=0 suspectscore=0
 lowpriorityscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-2009150000 definitions=main-2010240165
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This comment was introduced by commit 6ea44adce915
("SUNRPC: ensure correct error is reported by xs_tcp_setup_socket()").

I believe EIO was a typo at the time: it should have been EAGAIN.

Subsequently, commit 0445f92c5d53 ("SUNRPC: Fix disconnection races")
changed that to ENOTCONN.

Rather than trying to keep the comment here in sync with the code in
xprt_force_disconnect(), make the point in a non-specific way.

Fixes: 6ea44adce915 ("SUNRPC: ensure correct error is reported by xs_tcp_setup_socket()")
Signed-off-by: Calum Mackay <calum.mackay@oracle.com>
---
 net/sunrpc/xprtsock.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 554e1bb4c1c7..3f11de5ad486 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2278,10 +2278,8 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 	case -EHOSTUNREACH:
 	case -EADDRINUSE:
 	case -ENOBUFS:
-		/*
-		 * xs_tcp_force_close() wakes tasks with -EIO.
-		 * We need to wake them first to ensure the
-		 * correct error code.
+		/* xs_tcp_force_close() wakes tasks with a fixed error code.
+		 * We need to wake them first to ensure the correct error code.
 		 */
 		xprt_wake_pending_tasks(xprt, status);
 		xs_tcp_force_close(xprt);
-- 
2.18.4

