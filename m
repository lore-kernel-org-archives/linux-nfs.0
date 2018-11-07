Return-Path: <SRS0=4cvb=NS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E434AC46464
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 04:15:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B50522081D
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 04:15:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B50522081D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388596AbeKGNo0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 7 Nov 2018 08:44:26 -0500
Received: from mx2.suse.de ([195.135.220.15]:57028 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388667AbeKGNoZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Nov 2018 08:44:25 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 442C0B687;
        Wed,  7 Nov 2018 04:15:47 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Wed, 07 Nov 2018 15:12:31 +1100
Subject: [PATCH 21/23] SUNRPC: remove crbind rpc_cred operation
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <154156395157.24086.18081127267571403841.stgit@noble>
In-Reply-To: <154156285766.24086.14262073575778354276.stgit@noble>
References: <154156285766.24086.14262073575778354276.stgit@noble>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This now always just does get_rpccred(), so we
don't need an operation pointer to know to do that.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/sunrpc/auth.h    |    2 --
 net/sunrpc/auth.c              |   12 +-----------
 net/sunrpc/auth_gss/auth_gss.c |    2 --
 net/sunrpc/auth_null.c         |    1 -
 net/sunrpc/auth_unix.c         |    1 -
 5 files changed, 1 insertion(+), 17 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index b9449aa27fed..5486082d3d63 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -133,7 +133,6 @@ struct rpc_credops {
 	void			(*crdestroy)(struct rpc_cred *);
 
 	int			(*crmatch)(struct auth_cred *, struct rpc_cred *, int);
-	struct rpc_cred *	(*crbind)(struct rpc_task *, struct rpc_cred *, int);
 	__be32 *		(*crmarshal)(struct rpc_task *, __be32 *);
 	int			(*crrefresh)(struct rpc_task *);
 	__be32 *		(*crvalidate)(struct rpc_task *, __be32 *);
@@ -167,7 +166,6 @@ int			rpcauth_list_flavors(rpc_authflavor_t *, int);
 struct rpc_cred *	rpcauth_lookup_credcache(struct rpc_auth *, struct auth_cred *, int, gfp_t);
 void			rpcauth_init_cred(struct rpc_cred *, const struct auth_cred *, struct rpc_auth *, const struct rpc_credops *);
 struct rpc_cred *	rpcauth_lookupcred(struct rpc_auth *, int);
-struct rpc_cred *	rpcauth_generic_bind_cred(struct rpc_task *, struct rpc_cred *, int);
 void			put_rpccred(struct rpc_cred *);
 __be32 *		rpcauth_marshcred(struct rpc_task *, __be32 *);
 __be32 *		rpcauth_checkverf(struct rpc_task *, __be32 *);
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 2debbaba7809..867ea9834bde 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -658,15 +658,6 @@ rpcauth_init_cred(struct rpc_cred *cred, const struct auth_cred *acred,
 }
 EXPORT_SYMBOL_GPL(rpcauth_init_cred);
 
-struct rpc_cred *
-rpcauth_generic_bind_cred(struct rpc_task *task, struct rpc_cred *cred, int lookupflags)
-{
-	dprintk("RPC: %5u holding %s cred %p\n", task->tk_pid,
-			cred->cr_auth->au_ops->au_name, cred);
-	return get_rpccred(cred);
-}
-EXPORT_SYMBOL_GPL(rpcauth_generic_bind_cred);
-
 static struct rpc_cred *
 rpcauth_bind_root_cred(struct rpc_task *task, int lookupflags)
 {
@@ -724,8 +715,7 @@ rpcauth_bindcred(struct rpc_task *task, const struct cred *cred, int flags)
 		lookupflags |= RPCAUTH_LOOKUP_NEW;
 	if (task->tk_op_cred)
 		/* Task must use exactly this rpc_cred */
-		new = task->tk_op_cred->cr_ops->crbind(task, task->tk_op_cred,
-						       lookupflags);
+		new = get_rpccred(task->tk_op_cred);
 	else if (cred != NULL && cred != &machine_cred)
 		new = auth->au_ops->lookup_cred(auth, &acred, lookupflags);
 	else if (cred == &machine_cred)
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 7c5311c2f524..4fa1881d31ca 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -2068,7 +2068,6 @@ static const struct rpc_credops gss_credops = {
 	.cr_name		= "AUTH_GSS",
 	.crdestroy		= gss_destroy_cred,
 	.cr_init		= gss_cred_init,
-	.crbind			= rpcauth_generic_bind_cred,
 	.crmatch		= gss_match,
 	.crmarshal		= gss_marshal,
 	.crrefresh		= gss_refresh,
@@ -2083,7 +2082,6 @@ static const struct rpc_credops gss_credops = {
 static const struct rpc_credops gss_nullops = {
 	.cr_name		= "AUTH_GSS",
 	.crdestroy		= gss_destroy_nullcred,
-	.crbind			= rpcauth_generic_bind_cred,
 	.crmatch		= gss_match,
 	.crmarshal		= gss_marshal,
 	.crrefresh		= gss_refresh_null,
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index 830686e80bed..d0ceac57c06e 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -123,7 +123,6 @@ static
 const struct rpc_credops null_credops = {
 	.cr_name	= "AUTH_NULL",
 	.crdestroy	= nul_destroy_cred,
-	.crbind		= rpcauth_generic_bind_cred,
 	.crmatch	= nul_match,
 	.crmarshal	= nul_marshal,
 	.crrefresh	= nul_refresh,
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 6ee43bfbfb4b..bff113a411e0 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -246,7 +246,6 @@ static
 const struct rpc_credops unix_credops = {
 	.cr_name	= "AUTH_UNIX",
 	.crdestroy	= unx_destroy_cred,
-	.crbind		= rpcauth_generic_bind_cred,
 	.crmatch	= unx_match,
 	.crmarshal	= unx_marshal,
 	.crrefresh	= unx_refresh,


