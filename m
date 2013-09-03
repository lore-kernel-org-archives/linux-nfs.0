Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:34163 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760569Ab3ICTSy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Sep 2013 15:18:54 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFSv4: use the mach cred for SECINFO w/ integrity
Date: Tue, 3 Sep 2013 15:18:49 -0400
Message-ID: <1378235929-4710-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 5ec16a8500d339b0e7a0cc76b785d18daad354d4 introduced a regression
that causes SECINFO to fail without actualy sending an RPC if:

 1) the nfs_client's rpc_client was using KRB5i/p (now tried by default)
 2) the current user doesn't have valid kerberos credentials

This situation is quite common - as of now a sec=sys mount would use
krb5i for the nfs_client's rpc_client and a user would hardly be faulted
for not having run kinit.

The solution is to use the machine cred when trying to use an integrity
protected auth flavor for SECINFO.

Older servers may not support using the machine cred or an integrity
protected auth flavor for SECINFO in every circumstance, so we fall back
to using the user's cred and the filesystem's auth flavor in this case.

We run into another problem when running against linux nfs servers -
they return NFS4ERR_WRONGSEC when using integrity auth flavor (unless the
mount is also that flavor) even though that is not a valid error for
SECINFO*.  Even though it's against spec, handle WRONGSEC errors on SECINFO
by falling back to using the user cred and the filesystem's auth flavor.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---

Posting my proposed client-side fixes to follow the Security Considerations
sections of the v4 and v4.1 specs wrt SECINFO.

The question remains - if servers aren't supposed to return NFS4ERR_WRONGSEC,
but only RECOMMENDED to use krb5i/p for SECINFO, how does a server tell the
client that it doesn't support that auth flavor?

Once we figure this out, I'll update the patch to retry in that case too.

There will also be similar patches to SECINFO_NONAME and LAYOUTGET (which has
a similiar regression, but doesn't have the no NFS4ERR_WRONGSEC limitation).


 fs/nfs/nfs4proc.c | 53 +++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 47 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f7c8106..e54b992 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -435,6 +435,20 @@ wait_on_recovery:
 	return ret;
 }
 
+/*
+ * Return 'true' if 'clp' is using an rpc_client that is integrity protected
+ * or 'false' otherwise.
+ */
+static bool _nfs4_is_integrity_protected(struct nfs_client *clp)
+{
+	rpc_authflavor_t flavor = clp->cl_rpcclient->cl_auth->au_flavor;
+
+	if (flavor == RPC_AUTH_GSS_KRB5I ||
+	    flavor == RPC_AUTH_GSS_KRB5P)
+		return true;
+
+	return false;
+}
 
 static void do_renew_lease(struct nfs_client *clp, unsigned long timestamp)
 {
@@ -5840,10 +5854,13 @@ int nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir,
 }
 
 /**
- * Use the state managment nfs_client cl_rpcclient, which uses krb5i (if
- * possible) as per RFC3530bis and RFC5661 Security Considerations sections
+ * If 'use_integrity' is true and the state managment nfs_client
+ * cl_rpcclient is using krb5i/p, use the integrity protected cl_rpcclient
+ * and the machine credential as per RFC3530bis and RFC5661 Security
+ * Considerations sections. Otherwise, just use the user cred with the
+ * filesystem's rpc_client.
  */
-static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct nfs4_secinfo_flavors *flavors)
+static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct nfs4_secinfo_flavors *flavors, bool use_integrity)
 {
 	int status;
 	struct nfs4_secinfo_arg args = {
@@ -5858,11 +5875,21 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
-	struct rpc_clnt *clnt = NFS_SERVER(dir)->nfs_client->cl_rpcclient;
+	struct rpc_clnt *clnt = NFS_SERVER(dir)->client;
+
+	if (use_integrity) {
+		clnt = NFS_SERVER(dir)->nfs_client->cl_rpcclient;
+		msg.rpc_cred = nfs4_get_clid_cred(NFS_SERVER(dir)->nfs_client);
+	}
 
 	dprintk("NFS call  secinfo %s\n", name->name);
-	status = nfs4_call_sync(clnt, NFS_SERVER(dir), &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(clnt, NFS_SERVER(dir), &msg, &args.seq_args,
+				&res.seq_res, 0);
 	dprintk("NFS reply  secinfo: %d\n", status);
+
+	if (msg.rpc_cred)
+		put_rpccred(msg.rpc_cred);
+
 	return status;
 }
 
@@ -5872,7 +5899,21 @@ int nfs4_proc_secinfo(struct inode *dir, const struct qstr *name,
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = _nfs4_proc_secinfo(dir, name, flavors);
+		err = -NFS4ERR_WRONGSEC;
+
+		/* try to use integrity protection with machine cred */
+		if (_nfs4_is_integrity_protected(NFS_SERVER(dir)->nfs_client))
+			err = _nfs4_proc_secinfo(dir, name, flavors, true);
+
+		/*
+		 * if unable to use integrity protection, or SECINFO with
+		 * integrity protection returns NFS4ERR_WRONGSEC (which is
+		 * disallowed by spec, but exists in deployed servers) use
+		 * the current filesystem's rpc_client and the user cred.
+		 */
+		if (err == -NFS4ERR_WRONGSEC)
+			err = _nfs4_proc_secinfo(dir, name, flavors, false);
+
 		trace_nfs4_secinfo(dir, name, err);
 		err = nfs4_handle_exception(NFS_SERVER(dir), err,
 				&exception);
-- 
1.7.12.4 (Apple Git-37)

