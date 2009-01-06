From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] showmount command: Quiesce warning when TI-RPC is disabled
Date: Tue, 06 Jan 2009 18:22:54 -0500
Message-ID: <20090106232254.24661.4504.stgit@ingres.1015granger.net>
References: <20090106231909.24661.92964.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:19751 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754107AbZAFXYn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2009 18:24:43 -0500
In-Reply-To: <20090106231909.24661.92964.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make sure nfs_sm_pgmtbl is not compiled if TI-RPC functions are not
available.  This quiesces the following compiler warning:

  showmount.c:53: warning: =E2=80=98nfs_sm_pgmtbl=E2=80=99 defined but =
not used

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/showmount/showmount.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/utils/showmount/showmount.c b/utils/showmount/showmount.c
index 17f7d87..2695c51 100644
--- a/utils/showmount/showmount.c
+++ b/utils/showmount/showmount.c
@@ -50,13 +50,6 @@ static int	aflag =3D 0;
 static int	dflag =3D 0;
 static int	eflag =3D 0;
=20
-static const char *nfs_sm_pgmtbl[] =3D {
-	"showmount",
-	"mount",
-	"mountd",
-	NULL,
-};
-
 static struct option longopts[] =3D
 {
 	{ "all", 0, 0, 'a' },
@@ -87,6 +80,13 @@ static void usage(FILE *fp, int n)
=20
 #ifdef HAVE_CLNT_CREATE
=20
+static const char *nfs_sm_pgmtbl[] =3D {
+	"showmount",
+	"mount",
+	"mountd",
+	NULL,
+};
+
 /*
  * Generate an RPC client handle connected to the mountd service
  * at @hostname, or die trying.

