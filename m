From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 5] knfsd: Introduction - Assorted bugfixes
Date: Tue, 23 Jan 2007 11:22:03 +1100
Message-ID: <20070123111558.27683.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H99Qk-0007R3-Dg
	for nfs@lists.sourceforge.net; Mon, 22 Jan 2007 16:22:30 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H99Qk-0002AR-VG
	for nfs@lists.sourceforge.net; Mon, 22 Jan 2007 16:22:32 -0800
To: Andrew Morton <akpm@osdl.org>
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

Following are 5 patches for kNFSd suitable for inclusion in 2.6.20.

A couple should go to 2.6.19-stable, but I'll send those separately.

NeilBrown


 [PATCH 001 of 5] knfsd: Update email address and status for NFSD in MAINTAINERS.
 [PATCH 002 of 5] knfsd: Fix setting of ACL server versions.
 [PATCH 003 of 5] knfsd: Fix an NFSD bug with full sized, non-page-aligned reads.
 [PATCH 004 of 5] knfsd: Replace some warning ins nfsfh.h with BUG_ON or WARN_ON
 [PATCH 005 of 5] knfsd: Don't mess with the 'mode' when storing a exclusive-create cookie.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
