From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] umount.nfs command: Add an AF_INET6-capable version of
	nfs_call_unmount()
Date: Wed, 28 Jan 2009 18:07:44 -0500
Message-ID: <20090128230743.21484.52918.stgit@ingres.1015granger.net>
References: <20090128225938.21484.82096.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:46430 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbZA1XJG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jan 2009 18:09:06 -0500
In-Reply-To: <20090128225938.21484.82096.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need an AF_INET6-capable version of nfs_call_unmount() to allow the
umount.nfs command to support unmounting NFS servers over IPv6.  The legacy
mount.nfs command still likes to use nfs_call_umount(), so we leave it in
place and introduce a new API that can take a "struct sockaddr *".

The umount.nfs command will invoke this new API, but we'll leave the legacy
mount.nfs command and the umount.nfs4 command alone.  The umount.nfs4
command does not need this support because NFSv4 unmount operations are
entirely local.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   53 +++++++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/network.h |    4 +++-
 2 files changed, 56 insertions(+), 1 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 91a005c..174d7f6 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -838,6 +838,59 @@ int start_statd(void)
 }
 
 /**
+ * nfs_advise_umount - ask the server to remove a share from it's rmtab
+ * @sap: pointer to IP address of server to call
+ * @salen: length of server address
+ * @pmap: partially filled-in mountd RPC service tuple
+ * @argp: directory path of share to "unmount"
+ *
+ * Returns one if the unmount call succeeded; zero if the unmount
+ * failed for any reason;  rpccreateerr.cf_stat is set to reflect
+ * the nature of the error.
+ *
+ * We use a fast timeout since this call is advisory only.
+ */
+int nfs_advise_umount(const struct sockaddr *sap, const socklen_t salen,
+		      const struct pmap *pmap, const dirpath *argp)
+{
+	struct sockaddr_storage address;
+	struct sockaddr *saddr = (struct sockaddr *)&address;
+	struct pmap mnt_pmap = *pmap;
+	struct timeval timeout = {
+		.tv_sec		= MOUNT_TIMEOUT >> 3,
+	};
+	CLIENT *client;
+	enum clnt_stat res = 0;
+
+	if (nfs_probe_mntport(sap, salen, &mnt_pmap) == 0)
+		return 0;
+
+	memcpy(saddr, sap, salen);
+	nfs_set_port(saddr, mnt_pmap.pm_port);
+
+	client = nfs_get_rpcclient(saddr, salen, mnt_pmap.pm_prot,
+					mnt_pmap.pm_prog, mnt_pmap.pm_vers,
+					&timeout);
+	if (client == NULL)
+		return 0;
+
+	client->cl_auth = authunix_create_default();
+
+	res = CLNT_CALL(client, MOUNTPROC_UMNT,
+			(xdrproc_t)xdr_dirpath, (caddr_t)argp,
+			(xdrproc_t)xdr_void, NULL,
+			timeout);
+
+	auth_destroy(client->cl_auth);
+	CLNT_DESTROY(client);
+
+	if (res != RPC_SUCCESS)
+		return 0;
+
+	return 1;
+}
+
+/**
  * nfs_call_umount - ask the server to remove a share from it's rmtab
  * @mnt_server: address of RPC MNT program server
  * @argp: directory path of share to "unmount"
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 25060ab..0dd90f8 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -52,7 +52,6 @@ int nfs_present_sockaddr(const struct sockaddr *,
 			 const socklen_t, char *, const size_t);
 int nfs_callback_address(const struct sockaddr *, const socklen_t,
 		struct sockaddr *, socklen_t *);
-int nfs_call_umount(clnt_addr_t *, dirpath *);
 int clnt_ping(struct sockaddr_in *, const unsigned long,
 		const unsigned long, const unsigned int,
 		struct sockaddr_in *);
@@ -66,6 +65,9 @@ int start_statd(void);
 
 unsigned long nfsvers_to_mnt(const unsigned long);
 
+int nfs_call_umount(clnt_addr_t *, dirpath *);
+int nfs_advise_umount(const struct sockaddr *, const socklen_t,
+		      const struct pmap *, const dirpath *);
 CLIENT *mnt_openclnt(clnt_addr_t *, int *);
 void mnt_closeclnt(CLIENT *, int);
 

