From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/10] mount.nfs: Refactor mount logic to allow
	support for	"bg" option
Date: Fri, 03 Aug 2007 13:24:10 -0400
Message-ID: <20070803172410.3357.66177.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IH0sh-00021a-9A
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:24:07 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IH0sl-0000hW-5w
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

Refactor main() a bit to make adding support for "bg" option easier.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |   43 +++++++++++++++++++++++++++----------------
 1 files changed, 27 insertions(+), 16 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 9ac817c..c0c3971 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -361,6 +361,31 @@ static int chk_mountpoint(char *mount_point)
 	return 0;
 }
 
+static int try_mount(char *spec, char *mount_point, int flags,
+			char *fs_type, char **extra_opts, char *mount_opts,
+			int fake, int nomtab, int bg)
+{
+	int ret;
+
+	if (strcmp(fs_type, "nfs4") == 0)
+		ret = nfs4mount(spec, mount_point, flags,
+				extra_opts, fake, bg);
+	else
+		ret = nfsmount(spec, mount_point, flags,
+				extra_opts, fake, bg);
+
+	if (ret)
+		return ret;
+
+	if (!fake)
+		print_one(spec, mount_point, fs_type, mount_opts);
+
+	if (!nomtab)
+		ret = add_mtab(spec, mount_point, fs_type, flags, *extra_opts,
+				0, 0 /* these are always zero for NFS */ );
+	return ret;
+}
+
 int main(int argc, char *argv[])
 {
 	int c, flags = 0, mnt_err = 1, fake = 0;
@@ -492,22 +517,8 @@ int main(int argc, char *argv[])
 		goto out;
 	}
 
-	if (strcmp(fs_type, "nfs4") == 0)
-		mnt_err = nfs4mount(spec, mount_point, flags,
-					&extra_opts, fake, 0);
-	else
-		mnt_err = nfsmount(spec, mount_point, flags,
-					&extra_opts, fake, 0);
-
-	if (mnt_err)
-		exit(EX_FAIL);
-
-	if (!fake)
-		print_one(spec, mount_point, fs_type, mount_opts);
-
-	if (!nomtab)
-		mnt_err = add_mtab(spec, mount_point, fs_type, flags, extra_opts,
-				0, 0 /* these are always zero for NFS */ );
+	mnt_err = try_mount(spec, mount_point, flags, fs_type, &extra_opts,
+				mount_opts, fake, nomtab, 0);
 
 out:
 	free(mount_point);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
