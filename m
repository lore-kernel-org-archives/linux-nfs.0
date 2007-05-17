From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] mount.nfs: Add support for the 'nosharecache' option
Date: Wed, 16 May 2007 22:13:20 -0400
Message-ID: <20070517021320.32468.4299.stgit@heimdal.trondhjem.org>
References: <17994.32412.173039.15055@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Paul Krizak <paul.krizak@amd.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Ian Kent <raven@themaw.net>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoVUa-000537-Gj
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 19:13:30 -0700
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HoVUb-00072t-Ts
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 19:13:26 -0700
In-Reply-To: <17994.32412.173039.15055@notabene.brown>
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

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Adds support for the 'nosharecache' mount option to nfs-utils.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 utils/mount/nfs.man      |   34 ++++++++++++++++++++++++++++++++++
 utils/mount/nfs4_mount.h |    1 +
 utils/mount/nfs4mount.c  |   14 ++++++++++----
 utils/mount/nfs_mount.h  |    1 +
 utils/mount/nfsmount.c   |    4 ++++
 5 files changed, 50 insertions(+), 4 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 673556c..e66daba 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -288,6 +288,23 @@ Mount the NFS filesystem using the UDP protocol.
 Disables NFSv3 READDIRPLUS RPCs. Use this option when
 mounting servers that don't support or have broken
 READDIRPLUS implementations.
+.TP 1.5i
+.I nosharecache
+As of kernel 2.6.18, it is no longer possible to mount the same
+same filesystem with different mount options to a new mountpoint.
+It was deemed unsafe to do so, since cached data cannot be shared
+between the two mountpoints. In consequence, files or directories
+that were common to both mountpoint subtrees could often be seen to
+be out of sync following an update.
+.br
+This option allows administrators to select the pre-2.6.18 behaviour,
+permitting the same filesystem to be mounted with different mount
+options.
+.br
+.B Beware:
+Use of this option is not recommended unless you are certain that there
+are no hard links or subtrees of this mountpoint that are mounted
+elsewhere.
 .P
 All of the non-value options have corresponding nooption forms.
 For example, nointr means don't allow file operations to be
@@ -444,6 +461,23 @@ This extracts a
 server performance penalty but it allows two different NFS clients
 to get reasonable good results when both clients are actively
 writing to common filesystem on the server.
+.TP 1.5i
+.I nosharecache
+As of kernel 2.6.18, it is no longer possible to mount the same
+same filesystem with different mount options to a new mountpoint.
+It was deemed unsafe to do so, since cached data cannot be shared
+between the two mountpoints. In consequence, files or directories
+that were common to both mountpoint subtrees could often be seen to
+be out of sync following an update.
+.br
+This option allows administrators to select the pre-2.6.18 behaviour,
+permitting the same filesystem to be mounted with different mount
+options.
+.br
+.B Beware:
+Use of this option is not recommended unless you are certain that there
+are no hard links or subtrees of this mountpoint that are mounted
+elsewhere.
 .P
 All of the non-value options have corresponding nooption forms.
 For example, nointr means don't allow file operations to be
diff --git a/utils/mount/nfs4_mount.h b/utils/mount/nfs4_mount.h
index 74c9b95..2fcca6d 100644
--- a/utils/mount/nfs4_mount.h
+++ b/utils/mount/nfs4_mount.h
@@ -65,6 +65,7 @@ struct nfs4_mount_data {
 #define NFS4_MOUNT_NOCTO	0x0010	/* 1 */
 #define NFS4_MOUNT_NOAC		0x0020	/* 1 */
 #define NFS4_MOUNT_STRICTLOCK	0x1000	/* 1 */
+#define NFS4_MOUNT_UNSHARED	0x8000	/* 5 */
 #define NFS4_MOUNT_FLAGMASK	0xFFFF
 
 /* pseudoflavors: */
diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index 2a58d0a..0376f32 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -201,7 +201,7 @@ int nfs4mount(const char *spec, const char *node, int *flags,
 	char *s;
 	int val;
 	int bg, soft, intr;
-	int nocto, noac;
+	int nocto, noac, unshared;
 	int retry;
 	int retval;
 	time_t timeout, t;
@@ -252,6 +252,7 @@ int nfs4mount(const char *spec, const char *node, int *flags,
 	intr = NFS4_MOUNT_INTR;
 	nocto = 0;
 	noac = 0;
+	unshared = 0;
 	retry = 10000;		/* 10000 minutes ~ 1 week */
 
 	/*
@@ -336,6 +337,8 @@ int nfs4mount(const char *spec, const char *node, int *flags,
 				nocto = !val;
 			else if (!strcmp(opt, "ac"))
 				noac = !val;
+			else if (!strcmp(opt, "sharecache"))
+				unshared = !val;
 			else if (!sloppy) {
 				printf(_("unknown nfs mount option: "
 					 "%s%s\n"), val ? "" : "no", opt);
@@ -347,7 +350,8 @@ int nfs4mount(const char *spec, const char *node, int *flags,
 	data.flags = (soft ? NFS4_MOUNT_SOFT : 0)
 		| (intr ? NFS4_MOUNT_INTR : 0)
 		| (nocto ? NFS4_MOUNT_NOCTO : 0)
-		| (noac ? NFS4_MOUNT_NOAC : 0);
+		| (noac ? NFS4_MOUNT_NOAC : 0)
+		| (unshared ? NFS4_MOUNT_UNSHARED : 0);
 
 	/*
 	 * Give a warning if the rpc.idmapd daemon is not running
@@ -388,11 +392,13 @@ int nfs4mount(const char *spec, const char *node, int *flags,
 	       data.acregmin, data.acregmax, data.acdirmin, data.acdirmax);
 	printf("port = %d, bg = %d, retry = %d, flags = %.8x\n",
 	       ntohs(server_addr.sin_port), bg, retry, data.flags);
-	printf("soft = %d, intr = %d, nocto = %d, noac = %d\n",
+	printf("soft = %d, intr = %d, nocto = %d, noac = %d, "
+	       "nosharecache = %d\n",
 	       (data.flags & NFS4_MOUNT_SOFT) != 0,
 	       (data.flags & NFS4_MOUNT_INTR) != 0,
 	       (data.flags & NFS4_MOUNT_NOCTO) != 0,
-	       (data.flags & NFS4_MOUNT_NOAC) != 0);
+	       (data.flags & NFS4_MOUNT_NOAC) != 0,
+	       (data.flags & NFS4_MOUNT_UNSHARED) != 0);
 
 	if (num_flavour > 0) {
 		int pf_cnt, i;
diff --git a/utils/mount/nfs_mount.h b/utils/mount/nfs_mount.h
index 4a061d8..50ce2a8 100644
--- a/utils/mount/nfs_mount.h
+++ b/utils/mount/nfs_mount.h
@@ -64,6 +64,7 @@ struct nfs_mount_data {
 #define NFS_MOUNT_NOACL     0x0800  /* 4 */
 #define NFS_MOUNT_SECFLAVOUR	0x2000	/* 5 */
 #define NFS_MOUNT_NORDIRPLUS	0x4000	/* 5 */
+#define NFS_MOUNT_UNSHARED	0x8000	/* 5 */
 
 /* security pseudoflavors */
 
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 815064a..f21aaff 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -804,6 +804,10 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 				data->flags &= ~NFS_MOUNT_NORDIRPLUS;
 				if (!val)
 					data->flags |= NFS_MOUNT_NORDIRPLUS;
+			} else if (!strcmp(opt, "sharecache")) {
+				data->flags &= ~NFS_MOUNT_UNSHARED;
+				if (!val)
+					data->flags |= NFS_MOUNT_UNSHARED;
 #endif
 			} else {
 			bad_option:

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
