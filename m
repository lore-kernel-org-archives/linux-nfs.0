Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:5795 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753243Ab3EFN2N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 May 2013 09:28:13 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: chuck.lever@oracle.com
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        Weston Andros Adamson <dros@netapp.com>
Subject: =?UTF-8?q?=5BPATCH=5D=20NFSv3=3A=20match=20sec=3D=20flavor=20against=20server=20list?=
Date: Mon,  6 May 2013 09:27:54 -0400
Message-Id: <1367846874-1234-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Older clients match the 'sec=' mount option flavor against the server's
flavor list (if available) and return EPERM if the specified flavor is not
found. Recent changes would skip this step and allow the vfs mount even
though no operations will succeed.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---

Hey Chuck,

This fixes a regression that was introduced with the recent nfs_select_flavor 
changes - I'm pretty sure we want to match the specified flavor instead of just
using it.

Example of the regression:

the server's /etc/exports:

/export/krb5      *(sec=krb5,sec=none,rw,no_root_squash)

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

I also made an attempt to support "AUTH_NULL means the server will ignore the
cred, so just use the specified flavor" behavior from much older kernels, but 
I'm not sure if we want this logic.

I'd actually prefer getting rid of this AUTH_NULL logic, it's just that some 
older clients (RHEL 5, etc) would succeed in mounting when sec=sys specified,
server list = [AUTH_NULL] (the client ends up sending AUTH_UNIX creds that are
ignored by the server), while newer kernels do not. The workaround in newer
kernels is to specify sec=none.

Thoughts?

 -dros

 fs/nfs/super.c | 39 ++++++++++++++++++++++++++++++++-------
 1 file changed, 32 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index eb494f6..6476b5d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1611,14 +1611,12 @@ out_security_failure:
  * Select a security flavor for this mount.  The selected flavor
  * is planted in args->auth_flavors[0].
  */
-static void nfs_select_flavor(struct nfs_parsed_mount_data *args,
+static int nfs_select_flavor(struct nfs_parsed_mount_data *args,
 			      struct nfs_mount_request *request)
 {
 	unsigned int i, count = *(request->auth_flav_len);
 	rpc_authflavor_t flavor;
-
-	if (args->auth_flavors[0] != RPC_AUTH_MAXFLAVOR)
-		goto out;
+	bool auth_null_seen = false;
 
 	/*
 	 * The NFSv2 MNT operation does not return a flavor list.
@@ -1634,6 +1632,26 @@ static void nfs_select_flavor(struct nfs_parsed_mount_data *args,
 		goto out_default;
 
 	/*
+	 * If the sec= mount option is used, the flavor must be in the list
+	 * returned by the server.
+	 *
+	 * One exception is when the server's flavor list includes AUTH_NULL:
+	 * Some servers implement AUTH_NULL by completely ignoring the rpc
+	 * cred, so the client can use any flavor.
+	 */
+	if (args->auth_flavors[0] != RPC_AUTH_MAXFLAVOR) {
+		for (i = 0; i < count; i++) {
+			if (args->auth_flavors[0] == request->auth_flavs[i])
+				goto out;
+			if (request->auth_flavs[i] == RPC_AUTH_NULL)
+				auth_null_seen = true;
+		}
+		if (auth_null_seen)
+			goto out;
+		goto out_nomatch;
+	}
+
+	/*
 	 * RFC 2623, section 2.7 suggests we SHOULD prefer the
 	 * flavor listed first.  However, some servers list
 	 * AUTH_NULL first.  Avoid ever choosing AUTH_NULL.
@@ -1654,11 +1672,19 @@ static void nfs_select_flavor(struct nfs_parsed_mount_data *args,
 	}
 
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
+
+out_nomatch:
+	dfprintk(MOUNT, "NFS: auth flavor %d not supported by server\n",
+		args->auth_flavors[0]);
+	return -EPERM;
 }
 
 /*
@@ -1721,8 +1747,7 @@ static int nfs_request_mount(struct nfs_parsed_mount_data *args,
 		return status;
 	}
 
-	nfs_select_flavor(args, &request);
-	return 0;
+	return nfs_select_flavor(args, &request);
 }
 
 struct dentry *nfs_try_mount(int flags, const char *dev_name,
-- 
1.7.12.4 (Apple Git-37)

