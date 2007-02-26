From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 08/11] nfs-utils: mount: Fixed TCP mounts with alpha
	servers
Date: Mon, 26 Feb 2007 06:18:43 -0500
Message-ID: <45E2C213.6060803@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080508040402050000010006"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLdpw-0000QA-MT
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:16:08 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLdpy-0006eG-G7
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:16:10 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBG9jv001098
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:16:09 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBG802005790
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:16:08 -0500
Received: from [10.13.248.66] (vpn-248-66.boston.redhat.com [10.13.248.66])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	l1QBG7wF025609
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:16:08 -0500
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

This is a multi-part message in MIME format.
--------------080508040402050000010006
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------080508040402050000010006
Content-Type: text/x-patch;
 name="patch-08.dif"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-08.dif"

commit 84e8186d1ad1f280c2a849349efbddab1f1fe16d
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Feb 24 16:02:08 2007 -0500

    Removed some old mounting versioning code that was
    stopping tcp mount from working with alpha servers
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 00aee61..b3d3696 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -487,7 +487,7 @@ int main(int argc, char *argv[])
 	else {
 		if (!strcmp(progname, "mount.nfs")) {
 			mnt_err = nfsmount(spec, mount_point, &flags,
-					&extra_opts, &mount_opts, &nfs_mount_vers, 0);
+					&extra_opts, &mount_opts,  0);
 		}
 	}
 	if (fake)
diff --git a/utils/mount/nfs_mount.h b/utils/mount/nfs_mount.h
index 2200362..69531b4 100644
--- a/utils/mount/nfs_mount.h
+++ b/utils/mount/nfs_mount.h
@@ -78,7 +78,7 @@ struct nfs_mount_data {
 #define AUTH_GSS_SPKMP		390011
 #endif
 
-int nfsmount(const char *, const char *, int *, char **, char **, int *, int);
+int nfsmount(const char *, const char *, int *, char **, char **, int);
 void mount_errors(char *, int, int);
 int contains(const char *, const char *);
 char *get_value(const char *, const char *);
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 7759260..3ca9b80 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -818,8 +818,7 @@ nfsmnt_check_compat(const struct pmap *nfs_pmap, const struct pmap *mnt_pmap)
 
 int
 nfsmount(const char *spec, const char *node, int *flags,
-	 char **extra_opts, char **mount_opts, int *nfs_mount_vers,
-	 int running_bg)
+	 char **extra_opts, char **mount_opts, int running_bg)
 {
 	static char *prev_bg_host;
 	char hostdir[1024];
@@ -850,9 +849,7 @@ nfsmount(const char *spec, const char *node, int *flags,
 
 	/* The version to try is either specified or 0
 	   In case it is 0 we tell the caller what we tried */
-	if (!*nfs_mount_vers)
-		*nfs_mount_vers = find_kernel_nfs_mount_version();
-	nfs_mount_version = *nfs_mount_vers;
+	nfs_mount_version = find_kernel_nfs_mount_version();
 
 	retval = EX_FAIL;
 	fsock = -1;

--------------080508040402050000010006
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------080508040402050000010006
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080508040402050000010006--
