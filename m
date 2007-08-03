From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/10] mount.nfs: restore bg argument to nfsmount()
	and	nfs4mount()
Date: Fri, 03 Aug 2007 13:24:05 -0400
Message-ID: <20070803172405.3357.16141.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IH0si-00022P-EI
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:24:08 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IH0sl-0007qX-E2
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:24:11 -0700
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

To enable background mounting again, restore the "bg" argument to
nfsmount() and nfs4mount() that was recently removed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c      |    6 ++++--
 utils/mount/nfs4_mount.h |    2 +-
 utils/mount/nfs4mount.c  |    2 +-
 utils/mount/nfs_mount.h  |    2 +-
 utils/mount/nfsmount.c   |    4 ++--
 5 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index a7ad035..9ac817c 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -493,9 +493,11 @@ int main(int argc, char *argv[])
 	}
 
 	if (strcmp(fs_type, "nfs4") == 0)
-		mnt_err = nfs4mount(spec, mount_point, flags, &extra_opts, fake);
+		mnt_err = nfs4mount(spec, mount_point, flags,
+					&extra_opts, fake, 0);
 	else
-		mnt_err = nfsmount(spec, mount_point, flags, &extra_opts, fake);
+		mnt_err = nfsmount(spec, mount_point, flags,
+					&extra_opts, fake, 0);
 
 	if (mnt_err)
 		exit(EX_FAIL);
diff --git a/utils/mount/nfs4_mount.h b/utils/mount/nfs4_mount.h
index 00581fd..b03792e 100644
--- a/utils/mount/nfs4_mount.h
+++ b/utils/mount/nfs4_mount.h
@@ -68,6 +68,6 @@ struct nfs4_mount_data {
 #define NFS4_MOUNT_UNSHARED	0x8000	/* 5 */
 #define NFS4_MOUNT_FLAGMASK	0xFFFF
 
-int nfs4mount(const char *, const char *, int, char **, int);
+int nfs4mount(const char *, const char *, int, char **, int, int);
 
 #endif
diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index 421989e..b012271 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -166,7 +166,7 @@ static int get_my_ipv4addr(char *ip_addr, int len)
 }
 
 int nfs4mount(const char *spec, const char *node, int flags,
-	      char **extra_opts, int fake)
+	      char **extra_opts, int fake, int running_bg)
 {
 	static struct nfs4_mount_data data;
 	static char hostdir[1024];
diff --git a/utils/mount/nfs_mount.h b/utils/mount/nfs_mount.h
index dcce370..7df8fb2 100644
--- a/utils/mount/nfs_mount.h
+++ b/utils/mount/nfs_mount.h
@@ -80,7 +80,7 @@ struct nfs_mount_data {
 #define AUTH_GSS_SPKMP		390011
 #endif
 
-int	nfsmount(const char *, const char *, int , char **, int);
+int	nfsmount(const char *, const char *, int , char **, int, int);
 int	nfsumount(int, char **);
 
 #endif /* _NFS_MOUNT_H */
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 7befbee..5839482 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -488,14 +488,14 @@ out_bad:
 
 int
 nfsmount(const char *spec, const char *node, int flags,
-	 char **extra_opts, int fake)
+	 char **extra_opts, int fake, int running_bg)
 {
 	static char *prev_bg_host;
 	char hostdir[1024];
 	char *hostname, *dirname, *old_opts, *mounthost = NULL;
 	char new_opts[1024], cbuf[1024];
 	static struct nfs_mount_data data;
-	int val, running_bg = 0;
+	int val;
 	static int doonce = 0;
 
 	clnt_addr_t mnt_server = { &mounthost, };


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
