Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38472 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751000AbeBSFD7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Feb 2018 00:03:59 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 19 Feb 2018 16:02:29 +1100
Subject: [PATCH 08/23] SUNRPC: remove machine_cred field from struct
 auth_cred
Cc: linux-nfs@vger.kernel.org
Message-ID: <151901654902.17421.785215237196505340.stgit@noble>
In-Reply-To: <151901634940.17421.7637564368419392071.stgit@noble>
References: <151901634940.17421.7637564368419392071.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The cred is a machine_cred iff ->principal is set, so there is no
need for the extra flag.

There is one case which deserves some
explanation. nfs4_root_machine_cred() calls rpc_lookup_machine_cred()
with a NULL principal name which results in not getting a machine
credential, but getting a root credential instead.
This appears to be what is expected of the caller, and is
clearly the result provided by both auth_unix and auth_gss
which already ignore the flag. in the ->crmatch functions.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/sunrpc/auth.h    |    3 +--
 net/sunrpc/auth_generic.c      |   12 ++++++------
 net/sunrpc/auth_gss/auth_gss.c |    5 +----
 3 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 2b19e687dc29..85b9fc2f5dbb 100644
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
index de7ffff73943..d7f74d5c6f4d 100644
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
index 97513cf5ec4e..8d210ba1e13b 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1340,9 +1340,7 @@ gss_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags, gfp_t
 	 */
 	cred->gc_base.cr_flags = 1UL << RPCAUTH_CRED_NEW;
 	cred->gc_service = gss_auth->service;
-	cred->gc_principal = NULL;
-	if (acred->machine_cred)
-		cred->gc_principal = acred->principal;
+	cred->gc_principal = acred->principal;
 	kref_get(&gss_auth->kref);
 	return &cred->gc_base;
 
@@ -1555,7 +1553,6 @@ static int gss_renew_cred(struct rpc_task *task)
 	struct auth_cred acred = {
 		.cred = oldcred->cr_cred,
 		.principal = gss_cred->gc_principal,
-		.machine_cred = (gss_cred->gc_principal != NULL ? 1 : 0),
 	};
 	struct rpc_cred *new;
 


