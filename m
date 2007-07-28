From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/23] libnfs.a: move more mount-only functions out of
	libnfs.a
Date: Sat, 28 Jul 2007 17:50:35 -0400
Message-ID: <20070728215035.21871.17023.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFGOm-0003e3-Ff
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:00 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IFGOq-0003r7-3V
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 14:34:04 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Continue clean-up with nfsvers_to_mnt() and mntvers_to_nfs().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/conn.h |    2 --
 support/nfs/conn.c     |   18 ------------------
 utils/mount/network.c  |   34 ++++++++++++++++++++++++++++++++++
 utils/mount/network.h  |    2 ++
 4 files changed, 36 insertions(+), 20 deletions(-)

diff --git a/support/include/conn.h b/support/include/conn.h
index f21c10e..48f5a1c 100644
--- a/support/include/conn.h
+++ b/support/include/conn.h
@@ -30,8 +30,6 @@ static const struct timeval RETRY_TIMEOUT = { 3, 0 };
 
 int clnt_ping(struct sockaddr_in *, const u_long, const u_long, const u_int,
 	      struct sockaddr_in *);
-u_long nfsvers_to_mnt(const u_long);
-u_long mntvers_to_nfs(const u_long);
 int get_socket(struct sockaddr_in *, u_int, int, int);
 
 #endif /* _CONN_H */
diff --git a/support/nfs/conn.c b/support/nfs/conn.c
index cf080c2..970abfe 100644
--- a/support/nfs/conn.c
+++ b/support/nfs/conn.c
@@ -25,24 +25,6 @@
 
 extern int verbose;
 
-/* Map an NFS version into the corresponding Mountd version */
-u_long nfsvers_to_mnt(const u_long vers)
-{
-	static const u_long nfs_to_mnt[] = { 0, 0, 1, 3 };
-	if (vers <= 3)
-		return nfs_to_mnt[vers];
-	return 0;
-}
-
-/* Map a Mountd version into the corresponding NFS version */
-u_long mntvers_to_nfs(const u_long vers)
-{
-	static const u_long mnt_to_nfs[] = { 0, 2, 2, 3 };
-	if (vers <= 3)
-		return mnt_to_nfs[vers];
-	return 0;
-}
-
 /*
  * Create a socket that is locally bound to a 
  * reserve or non-reserve port. For any failures,
diff --git a/utils/mount/network.c b/utils/mount/network.c
index 08b1f99..c092571 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -57,6 +57,40 @@ extern int nfs_mount_data_version;
 extern char *progname;
 extern int verbose;
 
+static const unsigned long nfs_to_mnt[] = {
+	0,
+	0,
+	1,
+	3,
+};
+
+static const unsigned long mnt_to_nfs[] = {
+	0,
+	2,
+	2,
+	3,
+};
+
+/*
+ * Map an NFS version into the corresponding Mountd version
+ */
+unsigned long nfsvers_to_mnt(const unsigned long vers)
+{
+	if (vers <= 3)
+		return nfs_to_mnt[vers];
+	return 0;
+}
+
+/*
+ * Map a Mountd version into the corresponding NFS version
+ */
+static unsigned long mntvers_to_nfs(const unsigned long vers)
+{
+	if (vers <= 3)
+		return mnt_to_nfs[vers];
+	return 0;
+}
+
 static const unsigned int probe_udp_only[] = {
 	IPPROTO_UDP,
 	0,
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 81a59da..b3a5525 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -33,5 +33,7 @@ int nfs_call_umount(clnt_addr_t *, dirpath *);
 
 int start_statd(void);
 
+unsigned long nfsvers_to_mnt(const unsigned long);
+
 CLIENT *mnt_openclnt(clnt_addr_t *, int *);
 void mnt_closeclnt(CLIENT *, int);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
