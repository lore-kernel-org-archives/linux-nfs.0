From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 30/31] mount.nfs: Squelch unused parameter warnings on empty
	functions
Date: Mon, 29 Jun 2009 13:39:41 -0400
Message-ID: <20090629173941.2076.45123.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:25924 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755895AbZF2RkE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:40:04 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Address compiler warnings:

    fstab.c:288: warning: unused parameter =E2=80=98sig=E2=80=99
   =20
    parse_dev.c:186: warning: unused parameter =E2=80=98dev=E2=80=99
    parse_dev.c:187: warning: unused parameter =E2=80=98hostname=E2=80=99
    parse_dev.c:187: warning: unused parameter =E2=80=98pathname=E2=80=99

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/fstab.c     |    2 +-
 utils/mount/parse_dev.c |    5 +++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/utils/mount/fstab.c b/utils/mount/fstab.c
index 7668167..2775d0b 100644
--- a/utils/mount/fstab.c
+++ b/utils/mount/fstab.c
@@ -285,7 +285,7 @@ handler (int sig) {
 }
=20
 static void
-setlkw_timeout (int sig) {
+setlkw_timeout (__attribute__((unused)) int sig) {
      /* nothing, fcntl will fail anyway */
 }
=20
diff --git a/utils/mount/parse_dev.c b/utils/mount/parse_dev.c
index c0a8e18..c8a58b1 100644
--- a/utils/mount/parse_dev.c
+++ b/utils/mount/parse_dev.c
@@ -183,8 +183,9 @@ static int nfs_parse_square_bracket(const char *dev=
,
  * with the mount request and failing with a cryptic error message
  * later.
  */
-static int nfs_parse_nfs_url(const char *dev,
-			     char **hostname, char **pathname)
+static int nfs_parse_nfs_url(__attribute__((unused)) const char *dev,
+			     __attribute__((unused)) char **hostname,
+			     __attribute__((unused)) char **pathname)
 {
 	nfs_error(_("%s: NFS URLs are not supported"), progname);
 	return 0;

