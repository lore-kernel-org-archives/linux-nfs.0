From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfs-utils: fix conflicting info in nfs(5) manpage for
 proto= option
Date: Fri, 22 Jun 2007 10:42:03 -0400
Message-ID: <20070622104203.50130636.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I1kKv-0002Vx-OI
	for nfs@lists.sourceforge.net; Fri, 22 Jun 2007 07:42:11 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I1kKy-0007uS-Ta
	for nfs@lists.sourceforge.net; Fri, 22 Jun 2007 07:42:13 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l5MEg6Ba022933
	for <nfs@lists.sourceforge.net>; Fri, 22 Jun 2007 10:42:06 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l5MEg5kU029466
	for <nfs@lists.sourceforge.net>; Fri, 22 Jun 2007 10:42:05 -0400
Received: from tupile.connectathon.org (vpn-14-92.rdu.redhat.com [10.11.14.92])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with SMTP id l5MEg3Ho030659
	for <nfs@lists.sourceforge.net>; Fri, 22 Jun 2007 10:42:03 -0400
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

The nfs manpage has conflicting info about the defaults in the proto= and tcp options. The info in the proto= option is wrong. This should fix it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 673556c..3026847 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -386,8 +386,8 @@ its portmapper, the standard NFS port number 2049 is
 used instead.
 .TP 1.5i
 .I proto=n
-Mount the NFS filesystem using a specific network protocol
-instead of the default UDP protocol.
+Mount the NFS filesystem using a specific network protocol.
+The default is to use TCP if it is supported by client and server.
 Many NFS version 4 servers only support TCP.
 Valid protocol types are
 .IR udp

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
