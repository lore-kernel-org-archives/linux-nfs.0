From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 8] knfsd: Introduction
Date: Fri, 29 Sep 2006 13:08:34 +1000
Message-ID: <20060929130518.23919.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GT8jz-0007o6-Qt
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 20:08:44 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GT8k0-0001UO-D6
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 20:08:44 -0700
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

Follow are 8 knfsd related patches made against 2.6.18-mm2
and suitable for 2.6.19.

1 adds support to tmpfs to make it exportable
2 and 3 are straight forward bugfixes.
4 is a bugfix in dcache.c code, so some external review wouldn't
go astray.
5-8 are more nfsv4 updates.

Thanks,
NeilBrown

 [PATCH 001 of 8] knfsd: Add nfs-export support to tmpfs
 [PATCH 002 of 8] knfsd: lockd: fix refount on nsm.
 [PATCH 003 of 8] knfsd: Fix auto-sizing of nfsd request/reply buffers
 [PATCH 004 of 8] knfsd: Close a race-opportunity in d_splice_alias
 [PATCH 005 of 8] knfsd: nfsd: store export path in export
 [PATCH 006 of 8] knfsd: nfsd4: fslocations data structures
 [PATCH 007 of 8] knfsd: nfsd4: xdr encoding for fs_locations
 [PATCH 008 of 8] knfsd: nfsd4: actually use all the pieces to implement referrals

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
