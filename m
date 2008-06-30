From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/7] text-based mount command: Make "internal error" message
	more explicit
Date: Mon, 30 Jun 2008 13:10:18 -0400
Message-ID: <20080630171017.9905.15113.stgit@ellison.1015granger.net>
References: <20080630170420.9905.90111.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:51793 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754331AbYF3RKv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 13:10:51 -0400
In-Reply-To: <20080630170420.9905.90111.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The text-based mount command displays the rather inexplicable "mount:
internal error" whenever it encounters a problem that is entirely
unexpected by its designers.

Let's beef that error message up to include instructions about reporting
the problem, and fix the error code returned by the mount option rewriting
logic so that also will no longer report "internal error".  An error in there
should generally only occur if there was an invalid mount option specified.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/error.c   |    7 ++++++-
 utils/mount/stropts.c |    7 ++++---
 2 files changed, 10 insertions(+), 4 deletions(-)


diff --git a/utils/mount/error.c b/utils/mount/error.c
index 147e919..5fd5705 100644
--- a/utils/mount/error.c
+++ b/utils/mount/error.c
@@ -231,8 +231,13 @@ void mount_error(const char *spec, const char *mount_point, int error)
 		rpc_mount_errors((char *)spec, 0, 0);
 		break;
 	case EIO:
+		nfs_error(_("%s: mount system call failed"), progname);
+		break;
 	case EFAULT:
-		nfs_error(_("%s: internal error"), progname);
+		nfs_error(_("%s: encountered unexpected error condition."),
+				progname);
+		nfs_error(_("%s: please report the error to" PACKAGE_BUGREPORT),
+				progname);
 		break;
 	default:
 		nfs_error(_("%s: %s"),
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 967fd69..c8148c4 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -356,12 +356,13 @@ static struct mount_options *rewrite_mount_options(char *str)
 	clnt_addr_t nfs_server = { };
 	int p;
 
-	errno = EIO;
-
 	options = po_split(str);
-	if (!options)
+	if (!options) {
+		errno = EFAULT;
 		return NULL;
+	}
 
+	errno = EINVAL;
 	option = po_get(options, "addr");
 	if (option) {
 		nfs_server.saddr.sin_family = AF_INET;

