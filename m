From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils: exportfs: automatically set 'nohide' on
 referral exports.
Date: Tue, 02 Oct 2007 10:38:08 -0400
Message-ID: <470257D0.7000306@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Icisv-0005GC-IC
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 07:38:05 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Icit0-0003d8-EP
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 07:38:10 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l92Ec9fI020585
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Tue, 2 Oct 2007 10:38:09 -0400
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l92Ec8Sp014058
	for <nfs@lists.sourceforge.net>; Tue, 2 Oct 2007 10:38:08 -0400
Received: from [10.12.32.32] (dickson.boston.devel.redhat.com [10.12.32.32])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	l92Ec86V029369
	for <nfs@lists.sourceforge.net>; Tue, 2 Oct 2007 10:38:08 -0400
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

To activate referral mounts, the local directory (on the
server) has to be --bind mounted (i.e. mount --bind . .),
which means when the local directory is accessed (by the client)
a mount point is being crossed. If the 'nohide' is not
set on the export (or crossmnt on the parent export) the
referral *silently* fails since the mount point can not be
crossed.

This silent failure  makes it almost impossible to figure
out why referral mounts fail, since there is no error message
or network traffic. So by setting the nohide option automatically
this silent failure is eliminated.

This patch is relative to the Fedora nfs-utils git tree:
git://git.infradead.org/~steved/nfs-utils.fedora

but does apply to Neil's git tree.

steved.


commit 34038ab17a5fa157bfee103eb3fe58bb999b40a4
Author: Steve Dickson <steved@dickson.boston.devel.redhat.com>
Date:   Tue Oct 2 09:56:42 2007 -0400

     This patch turns on the 'nohide' export option automatically
     for all FS location exports due to the fact this option
     is need to for referral mount to work.

     Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 5fc3e4a..40012c3 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -508,6 +508,12 @@ bad_option:
  		while (isblank(*cp))
  			cp++;
  	}
+	/*
+	 * Turn on nohide which will allow this export to cross over
+	 * the 'mount --bind' mount point.
+	 */
+	if (ep->e_fslocdata)
+		ep->e_flags |= NFSEXP_NOHIDE;

  	ep->e_squids = squids;
  	ep->e_sqgids = sqgids;

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
