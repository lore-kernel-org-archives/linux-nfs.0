From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 05/11] nfs-utils: mount:Fixed exit status
Date: Mon, 26 Feb 2007 06:18:10 -0500
Message-ID: <45E2C1F2.2000603@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000800080204060101030302"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLdpO-0000Je-Vb
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:15:35 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLdpQ-0006Ng-Kp
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:15:37 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBFZ6B000867
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:15:35 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBFZwh005693
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:15:35 -0500
Received: from [10.13.248.66] (vpn-248-66.boston.redhat.com [10.13.248.66])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	l1QBFYwN025586
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:15:35 -0500
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
--------------000800080204060101030302
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------000800080204060101030302
Content-Type: text/x-patch;
 name="patch-05.dif"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-05.dif"

commit 200d810e3fa2c7f35932faac87a6409fac5a9d4d
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Feb 24 15:21:52 2007 -0500

    Return the correct exit status on failed mounts
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 13bffbc..8440055 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -472,21 +472,24 @@ int main(int argc, char *argv[])
 		}
 	}
 
-	if (!mnt_err && !fake) {
-		if(!(flags & MS_REMOUNT)) {
-			mnt_err = do_mount_syscall(spec, mount_point,
-					nfs_mount_vers == 4 ? "nfs4" : "nfs", flags, mount_opts);
-		
-			if(mnt_err) {
-				mount_error(mount_point);
-				exit(-1);
-			}
-		}
-		if(!nomtab) {
-			add_mtab(spec, mount_point, nfs_mount_vers == 4 ? "nfs4" : "nfs",
-				 flags, extra_opts, 0, 0);
+	if (fake)
+		return 0;
+	if (mnt_err)
+		exit(EX_FAIL);
+
+	if(!(flags & MS_REMOUNT)) {
+		mnt_err = do_mount_syscall(spec, mount_point,
+				nfs_mount_vers == 4 ? "nfs4" : "nfs", flags, mount_opts);
+
+		if(mnt_err) {
+			mount_error(mount_point);
+			exit(EX_FAIL);
 		}
 	}
+	if(!nomtab) {
+		add_mtab(spec, mount_point, nfs_mount_vers == 4 ? "nfs4" : "nfs",
+			 flags, extra_opts, 0, 0);
+	}
 
 	return 0;
 }

--------------000800080204060101030302
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------000800080204060101030302
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------000800080204060101030302--
