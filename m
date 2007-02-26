From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 06/11] nfs-utils: mount:  AUTH_NONE mounts
Date: Mon, 26 Feb 2007 06:18:21 -0500
Message-ID: <45E2C1FD.7000506@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010009020307010105060600"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLdpa-0000K7-VE
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:15:46 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLdpb-0006R2-Nz
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:15:49 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBFk9h000944
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:15:46 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBFkZG005736
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:15:46 -0500
Received: from [10.13.248.66] (vpn-248-66.boston.redhat.com [10.13.248.66])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	l1QBFjKk025590
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:15:46 -0500
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
--------------010009020307010105060600
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------010009020307010105060600
Content-Type: text/x-patch;
 name="patch-06.dif"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-06.dif"

commit 0ffd74c990aca3761b79316d47e1b1778273681c
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Feb 24 15:27:46 2007 -0500

    Added support to specify the AUTH_NONE security flavor (i.e. -o sec=none)
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index d437036..7759260 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -1093,12 +1093,14 @@ nfsmount(const char *spec, const char *node, int *flags,
 
 		flavor = mountres->auth_flavors.auth_flavors_val;
 		while (--i >= 0) {
-			if (flavor[i] == data.pseudoflavor)
-				yum = 1;
 #ifdef NFS_MOUNT_DEBUG
-			printf("auth flavor %d: %d\n",
-				i, flavor[i]);
+			printf("auth flavor[%d] %d\n", i, flavor[i]);
 #endif
+			if (flavor[i] == data.pseudoflavor ||
+				flavor[i] == AUTH_NONE) {
+				yum = 1;
+				break;
+			}
 		}
 		if (!yum) {
 			fprintf(stderr,

--------------010009020307010105060600
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------010009020307010105060600
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------010009020307010105060600--
