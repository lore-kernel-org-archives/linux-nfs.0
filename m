Return-Path: <SRS0=4cvb=NS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E03CC0044C
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 04:16:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2F4F32081D
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 04:16:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F4F32081D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388846AbeKGNoi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 7 Nov 2018 08:44:38 -0500
Received: from mx2.suse.de ([195.135.220.15]:57170 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388667AbeKGNoh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Nov 2018 08:44:37 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 2C106B659;
        Wed,  7 Nov 2018 04:16:00 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Wed, 07 Nov 2018 15:12:31 +1100
Subject: [PATCH 23/23] SUNRPC discard cr_uid from struct rpc_cred.
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <154156395166.24086.4433778895891818320.stgit@noble>
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

Just use ->cr_cred->fsuid directly.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/sunrpc/auth.h    |    2 --
 net/sunrpc/auth.c              |    1 -
 net/sunrpc/auth_gss/auth_gss.c |   12 ++++++------
 3 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 5486082d3d63..eed3cb16ccf1 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -58,8 +58,6 @@ struct rpc_cred {
 	refcount_t		cr_count;	/* ref count */
 	const struct cred	*cr_cred;
 
-	kuid_t			cr_uid;
-
 	/* per-flavor data */
 };
 #define RPCAUTH_CRED_NEW	0
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index a07a7c59d3a4..1ff9768f5456 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -655,7 +655,6 @@ rpcauth_init_cred(struct rpc_cred *cred, const struct auth_cred *acred,
 	cred->cr_ops = ops;
 	cred->cr_expire = jiffies;
 	cred->cr_cred = get_cred(acred->cred);
-	cred->cr_uid = acred->cred->fsuid;
 }
 EXPORT_SYMBOL_GPL(rpcauth_init_cred);
 
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 4fa1881d31ca..9ab100e3346a 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -565,7 +565,7 @@ gss_setup_upcall(struct gss_auth *gss_auth, struct rpc_cred *cred)
 	struct gss_cred *gss_cred = container_of(cred,
 			struct gss_cred, gc_base);
 	struct gss_upcall_msg *gss_new, *gss_msg;
-	kuid_t uid = cred->cr_uid;
+	kuid_t uid = cred->cr_cred->fsuid;
 
 	gss_new = gss_alloc_msg(gss_auth, uid, gss_cred->gc_principal);
 	if (IS_ERR(gss_new))
@@ -604,7 +604,7 @@ gss_refresh_upcall(struct rpc_task *task)
 	int err = 0;
 
 	dprintk("RPC: %5u %s for uid %u\n",
-		task->tk_pid, __func__, from_kuid(&init_user_ns, cred->cr_uid));
+		task->tk_pid, __func__, from_kuid(&init_user_ns, cred->cr_cred->fsuid));
 	gss_msg = gss_setup_upcall(gss_auth, cred);
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
 		/* XXX: warning on the first, under the assumption we
@@ -637,7 +637,7 @@ gss_refresh_upcall(struct rpc_task *task)
 out:
 	dprintk("RPC: %5u %s for uid %u result %d\n",
 		task->tk_pid, __func__,
-		from_kuid(&init_user_ns, cred->cr_uid),	err);
+		from_kuid(&init_user_ns, cred->cr_cred->fsuid),	err);
 	return err;
 }
 
@@ -653,7 +653,7 @@ gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 	int err;
 
 	dprintk("RPC:       %s for uid %u\n",
-		__func__, from_kuid(&init_user_ns, cred->cr_uid));
+		__func__, from_kuid(&init_user_ns, cred->cr_cred->fsuid));
 retry:
 	err = 0;
 	/* if gssd is down, just skip upcalling altogether */
@@ -701,7 +701,7 @@ gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 	gss_release_msg(gss_msg);
 out:
 	dprintk("RPC:       %s for uid %u result %d\n",
-		__func__, from_kuid(&init_user_ns, cred->cr_uid), err);
+		__func__, from_kuid(&init_user_ns, cred->cr_cred->fsuid), err);
 	return err;
 }
 
@@ -1497,7 +1497,7 @@ gss_match(struct auth_cred *acred, struct rpc_cred *rc, int flags)
 	} else {
 		if (gss_cred->gc_principal != NULL)
 			return 0;
-		ret = uid_eq(rc->cr_uid, acred->cred->fsuid);
+		ret = uid_eq(rc->cr_cred->fsuid, acred->cred->fsuid);
 	}
 	return ret;
 }


