Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:36579 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932429AbbFIXoR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jun 2015 19:44:17 -0400
Received: by ieclw1 with SMTP id lw1so23787064iec.3
        for <linux-nfs@vger.kernel.org>; Tue, 09 Jun 2015 16:44:16 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org,
        Michael Skralivetsky <michael.skralivetsky@primarydata.com>,
        chuck.lever@oracle.com
Subject: [PATCH v3 4/5] nfs: make nfs4_init_nonuniform_client_string use a dynamically allocated buffer
Date: Tue,  9 Jun 2015 19:43:59 -0400
Message-Id: <1433893440-3988-5-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1433893440-3988-1-git-send-email-jeff.layton@primarydata.com>
References: <1433893440-3988-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The way the *_client_string functions work is a little goofy. They build
the string in an on-stack buffer and then use kstrdup to copy it. This
is not only stack-heavy but artificially limits the size of the client
name string. Change it so that we determine the length of the string,
allocate it and then scnprintf into it.

Since the contents of the nonuniform string depend on rcu-managed data
structures, it's possible that they'll change between when we allocate
the string and when we go to fill it. If that happens, free the string,
recalculate the length and try again. If it the mismatch isn't resolved
on the second try then just give up and return -EINVAL.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/nfs4proc.c | 74 ++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 51 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8713ada99b3c..3c9d513554d7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4955,25 +4955,54 @@ static void nfs4_init_boot_verifier(const struct nfs_client *clp,
 	memcpy(bootverf->data, verf, sizeof(bootverf->data));
 }
 
-static unsigned int
-nfs4_init_nonuniform_client_string(struct nfs_client *clp,
-				   char *buf, size_t len)
+static int
+nfs4_init_nonuniform_client_string(struct nfs_client *clp)
 {
-	unsigned int result;
+	int result;
+	size_t len;
+	char *str;
+	bool retried = false;
 
 	if (clp->cl_owner_id != NULL)
-		return strlcpy(buf, clp->cl_owner_id, len);
+		return 0;
+retry:
+	rcu_read_lock();
+	len = 10 + strlen(clp->cl_ipaddr) + 1 +
+		strlen(rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR)) +
+		1 +
+		strlen(rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_PROTO)) +
+		1;
+	rcu_read_unlock();
+
+	if (len > NFS4_OPAQUE_LIMIT + 1)
+		return -EINVAL;
+
+	/*
+	 * Since this string is allocated at mount time, and held until the
+	 * nfs_client is destroyed, we can use GFP_KERNEL here w/o worrying
+	 * about a memory-reclaim deadlock.
+	 */
+	str = kmalloc(len, GFP_KERNEL);
+	if (!str)
+		return -ENOMEM;
 
 	rcu_read_lock();
-	result = scnprintf(buf, len, "Linux NFSv4.0 %s/%s %s",
-				clp->cl_ipaddr,
-				rpc_peeraddr2str(clp->cl_rpcclient,
-							RPC_DISPLAY_ADDR),
-				rpc_peeraddr2str(clp->cl_rpcclient,
-							RPC_DISPLAY_PROTO));
+	result = scnprintf(str, len, "Linux NFSv4.0 %s/%s %s",
+			clp->cl_ipaddr,
+			rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR),
+			rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_PROTO));
 	rcu_read_unlock();
-	clp->cl_owner_id = kstrdup(buf, GFP_KERNEL);
-	return result;
+
+	/* Did something change? */
+	if (result >= len) {
+		kfree(str);
+		if (retried)
+			return -EINVAL;
+		retried = true;
+		goto retry;
+	}
+	clp->cl_owner_id = str;
+	return 0;
 }
 
 static unsigned int
@@ -5064,20 +5093,19 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 
 	/* nfs_client_id4 */
 	nfs4_init_boot_verifier(clp, &sc_verifier);
-	if (test_bit(NFS_CS_MIGRATION, &clp->cl_flags))
+	if (test_bit(NFS_CS_MIGRATION, &clp->cl_flags)) {
 		setclientid.sc_name_len =
 				nfs4_init_uniform_client_string(clp,
 						setclientid.sc_name,
 						sizeof(setclientid.sc_name));
-	else
-		setclientid.sc_name_len =
-				nfs4_init_nonuniform_client_string(clp,
-						setclientid.sc_name,
-						sizeof(setclientid.sc_name));
-
-	if (!clp->cl_owner_id) {
-		status = -ENOMEM;
-		goto out;
+		if (!clp->cl_owner_id) {
+			status = -ENOMEM;
+			goto out;
+		}
+	} else {
+		status = nfs4_init_nonuniform_client_string(clp);
+		if (status)
+			goto out;
 	}
 
 	/* cb_client4 */
-- 
2.4.2

