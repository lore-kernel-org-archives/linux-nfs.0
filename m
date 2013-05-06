Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:47032 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758975Ab3EFVMS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 May 2013 17:12:18 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
        Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFSv3: match sec= flavor against server list
Date: Mon,  6 May 2013 17:12:13 -0400
Message-Id: <1367874733-4746-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Older linux clients match the 'sec=' mount option flavor against the server's
flavor list (if available) and return EPERM if the specified flavor or AUTH_NULL
(which "matches" any flavor) is not found.

Recent changes skip this step and allow the vfs mount even though no operations
will succeed, creating a 'dud' mount.

This patch reverts back to the old behavior of matching specified flavors
against the server list and also returns EPERM when no sec= is specified and
none of the flavors returned by the server are supported by the client.

Example of behavior change:

the server's /etc/exports:

/export/krb5      *(sec=krb5,rw,no_root_squash)

old client behavior:

$ uname -a
Linux one.apikia.fake 3.8.8-202.fc18.x86_64 #1 SMP Wed Apr 17 23:25:17 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux
$ sudo mount -v -o sec=sys,vers=3 zero:/export/krb5 /mnt
mount.nfs: timeout set for Sun May  5 17:32:04 2013
mount.nfs: trying text-based options 'sec=sys,vers=3,addr=192.168.100.10'
mount.nfs: prog 100003, trying vers=3, prot=6
mount.nfs: trying 192.168.100.10 prog 100003 vers 3 prot TCP port 2049
mount.nfs: prog 100005, trying vers=3, prot=17
mount.nfs: trying 192.168.100.10 prog 100005 vers 3 prot UDP port 20048
mount.nfs: mount(2): Permission denied
mount.nfs: access denied by server while mounting zero:/export/krb5

recently changed behavior:

$ uname -a
Linux one.apikia.fake 3.9.0-testing+ #2 SMP Fri May 3 20:29:32 EDT 2013 x86_64 x86_64 x86_64 GNU/Linux
$ sudo mount -v -o sec=sys,vers=3 zero:/export/krb5 /mnt
mount.nfs: timeout set for Sun May  5 17:37:17 2013
mount.nfs: trying text-based options 'sec=sys,vers=3,addr=192.168.100.10'
mount.nfs: prog 100003, trying vers=3, prot=6
mount.nfs: trying 192.168.100.10 prog 100003 vers 3 prot TCP port 2049
mount.nfs: prog 100005, trying vers=3, prot=17
mount.nfs: trying 192.168.100.10 prog 100005 vers 3 prot UDP port 20048
$ ls /mnt
ls: cannot open directory /mnt: Permission denied
$ sudo ls /mnt
ls: cannot open directory /mnt: Permission denied
$ sudo df /mnt
df: ‘/mnt’: Permission denied
df: no file systems processed
$ sudo umount /mnt
$

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---

V4 - better readability, better comments

 fs/nfs/super.c | 48 +++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 41 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index eb494f6..53c2657 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1610,16 +1610,15 @@ out_security_failure:
 /*
  * Select a security flavor for this mount.  The selected flavor
  * is planted in args->auth_flavors[0].
+ *
+ * Returns 0 on success, -EACCES on failure.
  */
-static void nfs_select_flavor(struct nfs_parsed_mount_data *args,
+static int nfs_select_flavor(struct nfs_parsed_mount_data *args,
 			      struct nfs_mount_request *request)
 {
 	unsigned int i, count = *(request->auth_flav_len);
 	rpc_authflavor_t flavor;
 
-	if (args->auth_flavors[0] != RPC_AUTH_MAXFLAVOR)
-		goto out;
-
 	/*
 	 * The NFSv2 MNT operation does not return a flavor list.
 	 */
@@ -1634,6 +1633,25 @@ static void nfs_select_flavor(struct nfs_parsed_mount_data *args,
 		goto out_default;
 
 	/*
+	 * If the sec= mount option is used, the specified flavor or AUTH_NULL
+	 * must be in the list returned by the server.
+	 *
+	 * AUTH_NULL has a special meaning when it's in the server list - it
+	 * means that the server will ignore the rpc creds, so any flavor
+	 * can be used.
+	 */
+	if (args->auth_flavors[0] != RPC_AUTH_MAXFLAVOR) {
+		for (i = 0; i < count; i++) {
+			if (args->auth_flavors[0] == request->auth_flavs[i] ||
+			    request->auth_flavs[i] == RPC_AUTH_NULL)
+				goto out;
+		}
+		dfprintk(MOUNT, "NFS: auth flavor %d not supported by server\n",
+			args->auth_flavors[0]);
+		goto out_err;
+	}
+
+	/*
 	 * RFC 2623, section 2.7 suggests we SHOULD prefer the
 	 * flavor listed first.  However, some servers list
 	 * AUTH_NULL first.  Avoid ever choosing AUTH_NULL.
@@ -1653,12 +1671,29 @@ static void nfs_select_flavor(struct nfs_parsed_mount_data *args,
 		}
 	}
 
+	/*
+	 * As a last chance, see if the server list contains AUTH_NULL -
+	 * if it does, use the default flavor.
+	 */
+	for (i = 0; i < count; i++) {
+		if (request->auth_flavs[i] == RPC_AUTH_NULL)
+			goto out_default;
+	}
+
+	dfprintk(MOUNT, "NFS: no auth flavors in common with server\n");
+	goto out_err;
+
 out_default:
-	flavor = RPC_AUTH_UNIX;
+	/* use default if flavor not already set */
+	flavor = (args->auth_flavors[0] == RPC_AUTH_MAXFLAVOR) ?
+		RPC_AUTH_UNIX : args->auth_flavors[0];
 out_set:
 	args->auth_flavors[0] = flavor;
 out:
 	dfprintk(MOUNT, "NFS: using auth flavor %d\n", args->auth_flavors[0]);
+	return 0;
+out_err:
+	return -EACCES;
 }
 
 /*
@@ -1721,8 +1756,7 @@ static int nfs_request_mount(struct nfs_parsed_mount_data *args,
 		return status;
 	}
 
-	nfs_select_flavor(args, &request);
-	return 0;
+	return nfs_select_flavor(args, &request);
 }
 
 struct dentry *nfs_try_mount(int flags, const char *dev_name,
-- 
1.7.12.4 (Apple Git-37)

