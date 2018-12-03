Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FD9DC64EB4
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:32:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6F7BE20834
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:32:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F7BE20834
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726004AbeLCAcz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 19:32:55 -0500
Received: from mx2.suse.de ([195.135.220.15]:41100 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725785AbeLCAcz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 2 Dec 2018 19:32:55 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 2B8CAAD90;
        Mon,  3 Dec 2018 00:32:48 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Mon, 03 Dec 2018 11:30:30 +1100
Subject: [PATCH 08/23] SUNRPC: remove machine_cred field from struct
 auth_cred
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <154379703042.28598.14367691422771762233.stgit@noble>
In-Reply-To: <154379689752.28598.6750646657534626618.stgit@noble>
References: <154379689752.28598.6750646657534626618.stgit@noble>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The cred is a machine_cred iff ->principal is set, so there is no
need for the extra flag.

There is one case which deserves some
explanation. nfs4_root_machine_cred() calls rpc_lookup_machine_cred()
with a NULL principal name which results in not getting a machine
credential, but getting a root credential instead.
This appears to be what is expected of the caller, and is
clearly the result provided by both auth_unix and auth_gss
which already ignore the flag.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/sunrpc/auth.h    |    3 +--
 net/sunrpc/auth_generic.c      |   12 ++++++------
 net/sunrpc/auth_gss/auth_gss.c |    5 +----
 3 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 831ea65bd9f4..1c0468f39479 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -46,9 +46,8 @@ enum {
 
 struct auth_cred {
 	const struct cred *cred;
-	const char *principal;
+	const char *principal;	/* If present, this is a machine credential */
 	unsigned long ac_flags;
-	unsigned char machine_cred : 1;
 };
 
 /*
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index 6c7c65da6063..7d1a8f45726c 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -50,12 +50,13 @@ EXPORT_SYMBOL_GPL(rpc_lookup_cred_nonblock);
 
 /*
  * Public call interface for looking up machine creds.
+ * Note that if service_name is NULL, we actually look up
+ * "root" credential.
  */
 struct rpc_cred *rpc_lookup_machine_cred(const char *service_name)
 {
 	struct auth_cred acred = {
 		.principal = service_name,
-		.machine_cred = 1,
 		.cred = get_task_cred(&init_task),
 	};
 	struct rpc_cred *ret;
@@ -108,11 +109,10 @@ generic_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags, g
 
 	gcred->acred.cred = gcred->gc_base.cr_cred;
 	gcred->acred.ac_flags = 0;
-	gcred->acred.machine_cred = acred->machine_cred;
 	gcred->acred.principal = acred->principal;
 
 	dprintk("RPC:       allocated %s cred %p for uid %d gid %d\n",
-			gcred->acred.machine_cred ? "machine" : "generic",
+			gcred->acred.principal ? "machine" : "generic",
 			gcred,
 			from_kuid(&init_user_ns, acred->cred->fsuid),
 			from_kgid(&init_user_ns, acred->cred->fsgid));
@@ -145,7 +145,7 @@ generic_destroy_cred(struct rpc_cred *cred)
 static int
 machine_cred_match(struct auth_cred *acred, struct generic_cred *gcred, int flags)
 {
-	if (!gcred->acred.machine_cred ||
+	if (!gcred->acred.principal ||
 	    gcred->acred.principal != acred->principal ||
 	    !uid_eq(gcred->acred.cred->fsuid, acred->cred->fsuid) ||
 	    !gid_eq(gcred->acred.cred->fsgid, acred->cred->fsgid))
@@ -163,12 +163,12 @@ generic_match(struct auth_cred *acred, struct rpc_cred *cred, int flags)
 	int i;
 	struct group_info *a, *g;
 
-	if (acred->machine_cred)
+	if (acred->principal)
 		return machine_cred_match(acred, gcred, flags);
 
 	if (!uid_eq(gcred->acred.cred->fsuid, acred->cred->fsuid) ||
 	    !gid_eq(gcred->acred.cred->fsgid, acred->cred->fsgid) ||
-	    gcred->acred.machine_cred != 0)
+	    gcred->acred.principal != NULL)
 		goto out_nomatch;
 
 	a = acred->cred->group_info;
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 8c9e572aeea2..0fb390d9cd6e 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1395,9 +1395,7 @@ gss_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags, gfp_t
 	 */
 	cred->gc_base.cr_flags = 1UL << RPCAUTH_CRED_NEW;
 	cred->gc_service = gss_auth->service;
-	cred->gc_principal = NULL;
-	if (acred->machine_cred)
-		cred->gc_principal = acred->principal;
+	cred->gc_principal = acred->principal;
 	kref_get(&gss_auth->kref);
 	return &cred->gc_base;
 
@@ -1610,7 +1608,6 @@ static int gss_renew_cred(struct rpc_task *task)
 	struct auth_cred acred = {
 		.cred = oldcred->cr_cred,
 		.principal = gss_cred->gc_principal,
-		.machine_cred = (gss_cred->gc_principal != NULL ? 1 : 0),
 	};
 	struct rpc_cred *new;
 


