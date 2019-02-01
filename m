Return-Path: <SRS0=c+aj=QI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9B9DC282D8
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Feb 2019 19:57:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A83E2218AF
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Feb 2019 19:57:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CgVDhAm/"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729416AbfBAT5e (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Feb 2019 14:57:34 -0500
Received: from mail-io1-f67.google.com ([209.85.166.67]:42001 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727097AbfBAT5e (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Feb 2019 14:57:34 -0500
Received: by mail-io1-f67.google.com with SMTP id x6so6683867ioa.9
        for <linux-nfs@vger.kernel.org>; Fri, 01 Feb 2019 11:57:33 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=YbSxqbwld/2BO0pv+Hci8l9vQ6yfOqjeePvHQkpfG1c=;
        b=CgVDhAm/KPtIjWQ8PZk6Hj6BcAY3X6vZ/C7xUllvBZ7mWaD6meT3K+MfhvYawz8hD0
         IbTXC7T+wiS8cIEE0xPJUad3mDMnvmNMotpvkHckaMuVp1ElbgJ9XUkgMIgV+daQ6TJB
         jXsJH0QlFu8iOTdPJ2lzbhWp1gfcr1AvSoATKntfAmDBUkT/7p1Hlkgv0V9gvUlYesE+
         Dofv4kg/mts72p0QYgSDSdb1m+6qxtCwzM4WW8bpqzy6StYH8WHn3jXOfyfINeOkzCtI
         rcMRR5SPrHsqJ4YUpoAfHGjfNabbgPe1kHDblLyO69tZCqpmdEhsb/fic/dIJGvwZqJC
         8Kew==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=YbSxqbwld/2BO0pv+Hci8l9vQ6yfOqjeePvHQkpfG1c=;
        b=P3CDM2bTUZ8dBgN/tNSos+V8sMsFGeyln1WOUEvO7gkf32Bt8YQEJNiGRShjlYem8N
         zzUbyJVi9Kf1JSM4x5OpQampHCPh0oPJUv2ihaecSjmrwPsNWg/sxyXwcWKpD45jqrKP
         9gxZGFYPf+sjf3vS9kqA1FoNyM+R8Si7GVDfWrdSKNGidxJGeAvP16H2oUSQE7x6mRzQ
         i08DbhHZyKQLehLSNhirUChyXlNbyvvMndbOOtOmqmRNMQU04e3nHC1VDvNnFDIB1AhV
         +Fx+q+Iwe6HYq/WQtrAwjtI+NR1aB2gB/tlPhJuyVyA1P7BHMBSsIFO4P55D3cT7mf3b
         TIyg==
X-Gm-Message-State: AHQUAubT8SegLS3NlnySw7LcH9dzGNitVeCaCakaPmdflp5s6F7Ifi9O
        7SkGKwlrqvHicEBggRZoEJg=
X-Google-Smtp-Source: AHgI3IbkBshDGigJ1+XhnH/xnvrQkFGgGVWBx+f3Ma7V3P+BFumZn1OyZdX5vXR6XtpeUu7MHidCEQ==
X-Received: by 2002:a6b:e316:: with SMTP id u22mr3676981ioc.33.1549051053218;
        Fri, 01 Feb 2019 11:57:33 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id n143sm1690052itn.42.2019.02.01.11.57.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 11:57:32 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x11JvVnn008696;
        Fri, 1 Feb 2019 19:57:31 GMT
Subject: [PATCH RFC 01/10] SUNRPC: Remove some dprintk() call sites from
 auth functions
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     simo@redhat.com
Date:   Fri, 01 Feb 2019 14:57:31 -0500
Message-ID: <20190201195731.11389.69008.stgit@manet.1015granger.net>
In-Reply-To: <20190201195538.11389.96106.stgit@manet.1015granger.net>
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Clean up: Reduce dprintk noise by removing dprintk() call sites
from hot path that do not report exceptions. These are usually
replaceable with function graph tracing.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/auth.c      |   29 -----------------------------
 net/sunrpc/auth_unix.c |    9 +--------
 2 files changed, 1 insertion(+), 37 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 8dfab61..275e84e 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -17,10 +17,6 @@
 #include <linux/sunrpc/gss_api.h>
 #include <linux/spinlock.h>
 
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
-# define RPCDBG_FACILITY	RPCDBG_AUTH
-#endif
-
 #define RPC_CREDCACHE_DEFAULT_HASHBITS	(4)
 struct rpc_cred_cache {
 	struct hlist_head	*hashtable;
@@ -267,8 +263,6 @@ static int param_get_hashtbl_sz(char *buffer, const struct kernel_param *kp)
 		}
 	}
 	rcu_read_unlock();
-
-	dprintk("RPC:       %s returns %d\n", __func__, result);
 	return result;
 }
 EXPORT_SYMBOL_GPL(rpcauth_list_flavors);
@@ -636,9 +630,6 @@ struct rpc_cred *
 	struct rpc_cred *ret;
 	const struct cred *cred = current_cred();
 
-	dprintk("RPC:       looking up %s cred\n",
-		auth->au_ops->au_name);
-
 	memset(&acred, 0, sizeof(acred));
 	acred.cred = cred;
 	ret = auth->au_ops->lookup_cred(auth, &acred, flags);
@@ -670,8 +661,6 @@ struct rpc_cred *
 	};
 	struct rpc_cred *ret;
 
-	dprintk("RPC: %5u looking up %s cred\n",
-		task->tk_pid, task->tk_client->cl_auth->au_ops->au_name);
 	ret = auth->au_ops->lookup_cred(auth, &acred, lookupflags);
 	put_cred(acred.cred);
 	return ret;
@@ -688,8 +677,6 @@ struct rpc_cred *
 
 	if (!acred.principal)
 		return NULL;
-	dprintk("RPC: %5u looking up %s machine cred\n",
-		task->tk_pid, task->tk_client->cl_auth->au_ops->au_name);
 	return auth->au_ops->lookup_cred(auth, &acred, lookupflags);
 }
 
@@ -698,8 +685,6 @@ struct rpc_cred *
 {
 	struct rpc_auth *auth = task->tk_client->cl_auth;
 
-	dprintk("RPC: %5u looking up %s cred\n",
-		task->tk_pid, auth->au_ops->au_name);
 	return rpcauth_lookupcred(auth, lookupflags);
 }
 
@@ -776,9 +761,6 @@ struct rpc_cred *
 {
 	struct rpc_cred	*cred = task->tk_rqstp->rq_cred;
 
-	dprintk("RPC: %5u marshaling %s cred %p\n",
-		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
-
 	return cred->cr_ops->crmarshal(task, p);
 }
 
@@ -787,9 +769,6 @@ struct rpc_cred *
 {
 	struct rpc_cred	*cred = task->tk_rqstp->rq_cred;
 
-	dprintk("RPC: %5u validating %s cred %p\n",
-		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
-
 	return cred->cr_ops->crvalidate(task, p);
 }
 
@@ -808,8 +787,6 @@ static void rpcauth_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 {
 	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
 
-	dprintk("RPC: %5u using %s cred %p to wrap rpc data\n",
-			task->tk_pid, cred->cr_ops->cr_name, cred);
 	if (cred->cr_ops->crwrap_req)
 		return cred->cr_ops->crwrap_req(task, encode, rqstp, data, obj);
 	/* By default, we encode the arguments normally. */
@@ -833,8 +810,6 @@ static void rpcauth_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 {
 	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
 
-	dprintk("RPC: %5u using %s cred %p to unwrap rpc data\n",
-			task->tk_pid, cred->cr_ops->cr_name, cred);
 	if (cred->cr_ops->crunwrap_resp)
 		return cred->cr_ops->crunwrap_resp(task, decode, rqstp,
 						   data, obj);
@@ -865,8 +840,6 @@ static void rpcauth_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 			goto out;
 		cred = task->tk_rqstp->rq_cred;
 	}
-	dprintk("RPC: %5u refreshing %s cred %p\n",
-		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
 
 	err = cred->cr_ops->crrefresh(task);
 out:
@@ -880,8 +853,6 @@ static void rpcauth_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 {
 	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
 
-	dprintk("RPC: %5u invalidating %s cred %p\n",
-		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
 	if (cred)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 }
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 387f6b3..fc8a591 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -28,8 +28,6 @@
 static struct rpc_auth *
 unx_create(const struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 {
-	dprintk("RPC:       creating UNIX authenticator for client %p\n",
-			clnt);
 	refcount_inc(&unix_auth.au_count);
 	return &unix_auth;
 }
@@ -37,7 +35,6 @@
 static void
 unx_destroy(struct rpc_auth *auth)
 {
-	dprintk("RPC:       destroying UNIX authenticator %p\n", auth);
 }
 
 /*
@@ -48,10 +45,6 @@
 {
 	struct rpc_cred *ret = mempool_alloc(unix_pool, GFP_NOFS);
 
-	dprintk("RPC:       allocating UNIX cred for uid %d gid %d\n",
-			from_kuid(&init_user_ns, acred->cred->fsuid),
-			from_kgid(&init_user_ns, acred->cred->fsgid));
-
 	rpcauth_init_cred(ret, acred, auth, &unix_credops);
 	ret->cr_flags = 1UL << RPCAUTH_CRED_UPTODATE;
 	return ret;
@@ -61,7 +54,7 @@
 unx_free_cred_callback(struct rcu_head *head)
 {
 	struct rpc_cred *rpc_cred = container_of(head, struct rpc_cred, cr_rcu);
-	dprintk("RPC:       unx_free_cred %p\n", rpc_cred);
+
 	put_cred(rpc_cred->cr_cred);
 	mempool_free(rpc_cred, unix_pool);
 }

