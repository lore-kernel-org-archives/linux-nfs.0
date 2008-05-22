From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] text-based mount command: use correct server name in
	rewrite_mount_options
Date: Thu, 22 May 2008 12:11:16 -0400
Message-ID: <20080522161116.3044.2908.stgit@ellison.1015granger.net>
References: <20080522160457.3044.16441.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41252 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754185AbYEVQMd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 May 2008 12:12:33 -0400
In-Reply-To: <20080522160457.3044.16441.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix error reporting when probe_bothports() fails while rewriting mount
options.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/error.c   |    3 +++
 utils/mount/stropts.c |    9 +++++----
 2 files changed, 8 insertions(+), 4 deletions(-)


diff --git a/utils/mount/error.c b/utils/mount/error.c
index 23a91ff..147e919 100644
--- a/utils/mount/error.c
+++ b/utils/mount/error.c
@@ -227,6 +227,9 @@ void mount_error(const char *spec, const char *mount_point, int error)
 			nfs_error(_("%s: mount point %s does not exist"),
 				progname, mount_point);
 		break;
+	case ESPIPE:
+		rpc_mount_errors((char *)spec, 0, 0);
+		break;
 	case EIO:
 	case EFAULT:
 		nfs_error(_("%s: internal error"), progname);
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 3564f15..967fd69 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -356,6 +356,8 @@ static struct mount_options *rewrite_mount_options(char *str)
 	clnt_addr_t nfs_server = { };
 	int p;
 
+	errno = EIO;
+
 	options = po_split(str);
 	if (!options)
 		return NULL;
@@ -426,7 +428,7 @@ static struct mount_options *rewrite_mount_options(char *str)
 	po_remove_all(options, "udp");
 
 	if (!probe_bothports(&mnt_server, &nfs_server)) {
-		rpc_mount_errors("rpcbind", 0, 0);
+		errno = ESPIPE;
 		goto err;
 	}
 
@@ -452,6 +454,7 @@ static struct mount_options *rewrite_mount_options(char *str)
 
 	}
 
+	errno = 0;
 	return options;
 
 err:
@@ -498,10 +501,8 @@ static int nfs_retry_nfs23mount(struct nfsmount_info *mi)
 	char **extra_opts = mi->extra_opts;
 
 	retry_options = rewrite_mount_options(*extra_opts);
-	if (!retry_options) {
-		errno = EIO;
+	if (!retry_options)
 		return 0;
-	}
 
 	if (po_join(retry_options, &retry_str) == PO_FAILED) {
 		po_destroy(retry_options);

