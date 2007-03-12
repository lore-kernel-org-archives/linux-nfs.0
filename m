From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: nfs-utils patch for mount-reserved-port
Date: Mon, 12 Mar 2007 11:55:17 -0400
Message-ID: <EXNANE01XsNQptgFrYI000000b1@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQmvB-0000MW-08
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 08:58:49 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HQmvC-0006px-3l
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 08:58:51 -0700
Received: from svlexc03.hq.netapp.com (svlexc03.corp.netapp.com
	[10.57.156.149])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l2CFwXxO014417
	for <nfs@lists.sourceforge.net>; Mon, 12 Mar 2007 08:58:44 -0700 (PDT)
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

Only create a mount-time reserved port socket for kernels
which require it (pre-2.1.32/nfs_mount_version 1).

Signed-off-by: Tom Talpey <tmt@netapp.com>

Index: nfs-utils-1.0.12/utils/mount/nfsmount.c
===================================================================
--- nfs-utils-1.0.12.orig/utils/mount/nfsmount.c
+++ nfs-utils-1.0.12/utils/mount/nfsmount.c
@@ -1120,20 +1120,22 @@ noauth_flavors:
 #endif
        }
 
-       /* create nfs socket for kernel */
-
-       if (nfs_pmap->pm_prot == IPPROTO_TCP)
-               fsock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
-       else
-               fsock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
-       if (fsock < 0) {
-               perror(_("nfs socket"));
-               goto fail;
-       }
-       if (bindresvport(fsock, 0) < 0) {
-               perror(_("nfs bindresvport"));
-               goto fail;
+       if (nfs_mount_version == 1) {
+               /* create nfs socket for kernel */
+               if (nfs_pmap->pm_prot == IPPROTO_TCP)
+                       fsock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
+               else
+                       fsock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
+               if (fsock < 0) {
+                       perror(_("nfs socket"));
+                       goto fail;
+               }
+               if (bindresvport(fsock, 0) < 0) {
+                       perror(_("nfs bindresvport"));
+                       goto fail;
+               }
        }
+
 #ifdef NFS_MOUNT_DEBUG
        printf(_("using port %d for nfs deamon\n"), nfs_pmap->pm_port);
 #endif
@@ -1143,7 +1145,7 @@ noauth_flavors:
         * to avoid problems with multihomed hosts.
         * --Swen
         */
-       if (linux_version_code() <= 66314
+       if (linux_version_code() <= 66314 && fsock != -1
            && connect(fsock, (struct sockaddr *) nfs_saddr,
                       sizeof (*nfs_saddr)) < 0) {
                perror(_("nfs connect"));



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
