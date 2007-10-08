From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/12] text-based mount.nfs: combine nfsmount_s()
	and	nfs4mount_s() paths
Date: Mon, 08 Oct 2007 11:53:51 -0400
Message-ID: <20071008155351.15051.10327.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ieuvl-0007iJ-09
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:05 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ieuvn-0006BX-GH
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:10 -0700
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

The top-level logic that handles text-based mount options is mostly the
same for NFS and NFSv4 mounts.  To improve maintainability, let's combine
the nfsmount_s() and nfs4mount_s() functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c   |   12 +++-------
 utils/mount/stropts.c |   59 +++++++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/stropts.h |    4 ++-
 3 files changed, 65 insertions(+), 10 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index e622231..21946f7 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -376,14 +376,10 @@ static int try_mount(char *spec, char *mount_point, int flags,
 {
 	int ret;
 
-	if (string) {
-		if (strcmp(fs_type, "nfs4") == 0)
-			ret = nfs4mount_s(spec, mount_point, flags,
-						extra_opts, fake, bg);
-		else
-			ret = nfsmount_s(spec, mount_point, flags,
-						extra_opts, fake, bg);
-	} else {
+	if (string)
+		ret = nfsmount_string(spec, mount_point, fs_type, flags,
+					extra_opts, fake, bg);
+	else {
 		if (strcmp(fs_type, "nfs4") == 0)
 			ret = nfs4mount(spec, mount_point, flags,
 					extra_opts, fake, bg);
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 6270312..8859bf5 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -365,3 +365,62 @@ out:
 	po_destroy(options);
 	return retval;
 }
+
+/**
+ * nfsmount_string - Mount an NFS file system using C string options
+ * @spec: C string specifying remote share to mount ("hostname:path")
+ * @node: C string pathname of local mounted-on directory
+ * @type: C string that represents file system type ("nfs" or "nfs4")
+ * @flags: MS_ style mount flags
+ * @extra_opts:	pointer to C string containing fs-specific mount options
+ *		(input and output argument)
+ * @fake: flag indicating whether to carry out the whole operation
+ * @child: one if this is a mount daemon (bg)
+ */
+int nfsmount_string(const char *spec, const char *node, const char *type,
+		    int flags, char **extra_opts, int fake, int child)
+{
+	struct mount_options *options = NULL;
+	struct sockaddr_in saddr;
+	char *hostname;
+	int err, retval = EX_FAIL;
+
+	if (!parse_devname(spec, &hostname))
+		goto out;
+	err = fill_ipv4_sockaddr(hostname, &saddr);
+	free(hostname);
+	if (!err)
+		goto out;
+
+	options = po_split(*extra_opts);
+	if (!options) {
+		nfs_error(_("%s: internal option parsing error"), progname);
+		goto out;
+	}
+
+	if (!set_mandatory_options(type, &saddr, options))
+		goto out;
+
+	if (po_join(options, extra_opts) == PO_FAILED) {
+		nfs_error(_("%s: internal option parsing error"), progname);
+		goto out;
+	}
+
+	if (verbose)
+		printf(_("%s: text-based options: '%s'\n"),
+			progname, *extra_opts);
+
+	if (!fake) {
+		if (mount(spec, node, type,
+				flags & ~(MS_USER|MS_USERS), *extra_opts)) {
+			mount_error(spec, node, errno);
+			goto out;
+		}
+	}
+
+	retval = EX_SUCCESS;
+
+out:
+	po_destroy(options);
+	return retval;
+}
diff --git a/utils/mount/stropts.h b/utils/mount/stropts.h
index a2a0604..b926d68 100644
--- a/utils/mount/stropts.h
+++ b/utils/mount/stropts.h
@@ -21,5 +21,5 @@
  *
  */
 
-int nfsmount_s(const char *, const char *, int , char **, int, int);
-int nfs4mount_s(const char *, const char *, int, char **, int, int);
+int nfsmount_string(const char *, const char *, const char *, int,
+			char **, int, int);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
