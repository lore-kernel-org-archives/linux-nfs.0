Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:50761 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756855Ab0ITQcr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 12:32:47 -0400
Received: by mail-gx0-f174.google.com with SMTP id 23so1361234gxk.19
        for <linux-nfs@vger.kernel.org>; Mon, 20 Sep 2010 09:32:47 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/7] mountd: Support TI-RPC mountd listener
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 20 Sep 2010 12:32:44 -0400
Message-ID: <20100920163244.3170.72910.stgit@ellison.1015granger.net>
In-Reply-To: <20100920162616.3170.24625.stgit@ellison.1015granger.net>
References: <20100920162616.3170.24625.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

If TI-RPC is available, use it to create mountd's svc listener.  If
not, use the old function, rpc_init(), to create mountd's listener.

IPv6 can be supported if TI-RPC is available.  In this case,
/etc/netconfig is searched to determine which transports to advertise.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/mountd.c |   26 +++++++++++++++++---------
 1 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 753fd37..a4fdcc8 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -86,6 +86,11 @@ static int version3(void)
 	return nfs_version & NFSVERSBIT(3);
 }
 
+static int version23(void)
+{
+	return nfs_version & (NFSVERSBIT(2) | NFSVERSBIT(3));
+}
+
 static int version_any(void)
 {
 	return nfs_version & NFSVERSBIT_ALL;
@@ -95,11 +100,11 @@ static void
 unregister_services (void)
 {
 	if (version2()) {
-		pmap_unset (MOUNTPROG, MOUNTVERS);
-		pmap_unset (MOUNTPROG, MOUNTVERS_POSIX);
+		nfs_svc_unregister(MOUNTPROG, MOUNTVERS);
+		nfs_svc_unregister(MOUNTPROG, MOUNTVERS_POSIX);
 	}
 	if (version3())
-		pmap_unset (MOUNTPROG, MOUNTVERS_NFSV3);
+		nfs_svc_unregister(MOUNTPROG, MOUNTVERS_NFSV3);
 }
 
 static void
@@ -687,6 +692,7 @@ main(int argc, char **argv)
 {
 	char	*export_file = _PATH_EXPORTS;
 	char    *state_dir = NFS_STATEDIR;
+	unsigned int listeners = 0;
 	int	foreground = 0;
 	int	port = 0;
 	int	descriptors = 0;
@@ -830,14 +836,16 @@ main(int argc, char **argv)
 		cache_open();
 
 	if (version2()) {
-		rpc_init("mountd", MOUNTPROG, MOUNTVERS,
-			 mount_dispatch, port);
-		rpc_init("mountd", MOUNTPROG, MOUNTVERS_POSIX,
-			 mount_dispatch, port);
+		listeners += nfs_svc_create("mountd", MOUNTPROG,
+					MOUNTVERS, mount_dispatch, port);
+		listeners += nfs_svc_create("mountd", MOUNTPROG,
+					MOUNTVERS_POSIX, mount_dispatch, port);
 	}
 	if (version3())
-		rpc_init("mountd", MOUNTPROG, MOUNTVERS_NFSV3,
-			 mount_dispatch, port);
+		listeners += nfs_svc_create("mountd", MOUNTPROG,
+					MOUNTVERS_NFSV3, mount_dispatch, port);
+	if (version23() && listeners == 0)
+		xlog(L_FATAL, "mountd: could not create listeners\n");
 
 	sa.sa_handler = killer;
 	sigaction(SIGINT, &sa, NULL);

