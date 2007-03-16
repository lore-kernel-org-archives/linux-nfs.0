From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 4/4] Create two separate paths for pipefs_dir and
	pipefs_nfsdir.
Date: Fri, 16 Mar 2007 10:27:48 -0400
Message-ID: <20070316142748.6349.31715.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20070316141826.6349.9988.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HSDPI-0007EQ-VG
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 07:27:49 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HSDPK-0007yF-Nb
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 07:27:51 -0700
In-Reply-To: <20070316141826.6349.9988.stgit@RoCk.CiTi.UmIcH.EdU>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Kevin Coffman <kwc@citi.umich.edu>

Future work needs access to the base pipefs directory rather than
the nfs subdirectory.  Create two separate paths called
pipefs_dir and pipefs_nfsdir with the name of each.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/gssd.c           |   15 ++++++++-------
 utils/gssd/gssd.h           |    3 ++-
 utils/gssd/gssd_main_loop.c |    4 ++--
 utils/gssd/gssd_proc.c      |   22 +++++++++++-----------
 4 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 319dca4..747637c 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -53,7 +53,8 @@ #include "err_util.h"
 #include "gss_util.h"
 #include "krb5_util.h"
 
-char pipefsdir[PATH_MAX] = GSSD_PIPEFS_DIR;
+char pipefs_dir[PATH_MAX] = GSSD_PIPEFS_DIR;
+char pipefs_nfsdir[PATH_MAX] = GSSD_PIPEFS_DIR;
 char keytabfile[PATH_MAX] = GSSD_DEFAULT_KEYTAB_FILE;
 char ccachedir[PATH_MAX] = GSSD_DEFAULT_CRED_DIR;
 int  use_memcache = 0;
@@ -116,8 +117,8 @@ main(int argc, char *argv[])
 				rpc_verbosity++;
 				break;
 			case 'p':
-				strncpy(pipefsdir, optarg, sizeof(pipefsdir));
-				if (pipefsdir[sizeof(pipefsdir)-1] != '\0')
+				strncpy(pipefs_dir, optarg, sizeof(pipefs_dir));
+				if (pipefs_dir[sizeof(pipefs_dir)-1] != '\0')
 					errx(1, "pipefs path name too long");
 				break;
 			case 'k':
@@ -135,10 +136,10 @@ main(int argc, char *argv[])
 				break;
 		}
 	}
-	strncat(pipefsdir + strlen(pipefsdir), "/" GSSD_SERVICE_NAME,
-		sizeof(pipefsdir)-strlen(pipefsdir));
-	if (pipefsdir[sizeof(pipefsdir)-1] != '\0')
-		errx(1, "pipefs path name too long");
+	snprintf(pipefs_nfsdir, sizeof(pipefs_nfsdir), "%s/%s",
+		 pipefs_dir, GSSD_SERVICE_NAME);
+	if (pipefs_nfsdir[sizeof(pipefs_nfsdir)-1] != '\0')
+		errx(1, "pipefs_nfsdir path name too long");
 
 	if ((progname = strrchr(argv[0], '/')))
 		progname++;
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 3622b48..6b96ce1 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -58,7 +58,8 @@ enum {AUTHTYPE_KRB5, AUTHTYPE_SPKM3, AUT
 
 
 
-extern char			pipefsdir[PATH_MAX];
+extern char			pipefs_dir[PATH_MAX];
+extern char			pipefs_nfsdir[PATH_MAX];
 extern char			keytabfile[PATH_MAX];
 extern char			ccachedir[PATH_MAX];
 extern int			use_memcache;
diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
index a086bb3..0559f7b 100644
--- a/utils/gssd/gssd_main_loop.c
+++ b/utils/gssd/gssd_main_loop.c
@@ -106,9 +106,9 @@ gssd_run()
 	dn_act.sa_flags = SA_SIGINFO;
 	sigaction(DNOTIFY_SIGNAL, &dn_act, NULL);
 
-	if ((fd = open(pipefsdir, O_RDONLY)) == -1) {
+	if ((fd = open(pipefs_nfsdir, O_RDONLY)) == -1) {
 		printerr(0, "ERROR: failed to open %s: %s\n",
-			 pipefsdir, strerror(errno));
+			 pipefs_nfsdir, strerror(errno));
 		exit(1);
 	}
 	fcntl(fd, F_SETSIG, DNOTIFY_SIGNAL);
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 04de4e6..3b190f2 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -80,19 +80,19 @@ #include "context.h"
  *	with an index into pollarray[], and other basic data about that client.
  *
  * Directory structure: created by the kernel nfs client
- *      /pipefsdir/clntXX             : one per rpc_clnt struct in the kernel
- *      /pipefsdir/clntXX/krb5        : read uid for which kernel wants
- *      				 a context, write the resulting context
- *      /pipefsdir/clntXX/info        : stores info such as server name
+ *      {pipefs_nfsdir}/clntXX             : one per rpc_clnt struct in the kernel
+ *      {pipefs_nfsdir}/clntXX/krb5        : read uid for which kernel wants
+ *					    a context, write the resulting context
+ *      {pipefs_nfsdir}/clntXX/info        : stores info such as server name
  *
  * Algorithm:
- *      Poll all /pipefsdir/clntXX/krb5 files.  When ready, data read
+ *      Poll all {pipefs_nfsdir}/clntXX/krb5 files.  When ready, data read
  *      is a uid; performs rpcsec_gss context initialization protocol to
  *      get a cred for that user.  Writes result to corresponding krb5 file
  *      in a form the kernel code will understand.
  *      In addition, we make sure we are notified whenever anything is
- *      created or destroyed in pipefsdir/ or in an of the clntXX directories,
- *      and rescan the whole pipefsdir when this happens.
+ *      created or destroyed in {pipefs_nfsdir} or in an of the clntXX directories,
+ *      and rescan the whole {pipefs_nfsdir} when this happens.
  */
 
 struct pollfd * pollarray;
@@ -389,16 +389,16 @@ update_client_list(void)
 	struct dirent **namelist;
 	int i, j;
 
-	if (chdir(pipefsdir) < 0) {
+	if (chdir(pipefs_nfsdir) < 0) {
 		printerr(0, "ERROR: can't chdir to %s: %s\n",
-			 pipefsdir, strerror(errno));
+			 pipefs_nfsdir, strerror(errno));
 		return -1;
 	}
 
-	j = scandir(pipefsdir, &namelist, NULL, alphasort);
+	j = scandir(pipefs_nfsdir, &namelist, NULL, alphasort);
 	if (j < 0) {
 		printerr(0, "ERROR: can't scandir %s: %s\n",
-			 pipefsdir, strerror(errno));
+			 pipefs_nfsdir, strerror(errno));
 		return -1;
 	}
 	update_old_clients(namelist, j);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
