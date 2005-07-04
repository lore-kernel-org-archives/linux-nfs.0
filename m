From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 000 of 19] Introduction
Date: Mon, 04 Jul 2005 11:01:41 +1000
Message-ID: <20050704110022.27753.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpFLh-0001k0-Fb
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:13 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DpFLe-0007TC-Re
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:13 -0700
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Following are 19 assorted nfsv4 server patches for 2.6-latest.
Mostly tidy-ups and minor bug fixes.
They would all be suitable for 2.6.13.

Thanks,
NeilBrown


 [PATCH kNFSd 001 of 19] nfsd4: reboot recovery fix
 [PATCH kNFSd 002 of 19] nfsd4: fix sync'ing of recovery directory
 [PATCH kNFSd 003 of 19] nfsd4: lookup_one_len takes i_sem
 [PATCH kNFSd 004 of 19] nfsd4: prevent multiple unlinks of recovery directories
 [PATCH kNFSd 005 of 19] nfsd4: fix release_lockowner
 [PATCH kNFSd 006 of 19] nfsd4: ERR_GRACE should bump seqid on open
 [PATCH kNFSd 007 of 19] nfsd4: ERR_GRACE should bump seqid on lock
 [PATCH kNFSd 008 of 19] nfsd4: stop overusing RECLAIM_BAD
 [PATCH kNFSd 009 of 19] nfsd4: comment indentation
 [PATCH kNFSd 010 of 19] nfsd4: fix open_reclaim seqid
 [PATCH kNFSd 011 of 19] nfsd4: seqid comments
 [PATCH kNFSd 012 of 19] nfsd4: relax new lock seqid check
 [PATCH kNFSd 013 of 19] nfsd4: always update stateid on open
 [PATCH kNFSd 014 of 19] nfsd4: return better error on io incompatible with open mode
 [PATCH kNFSd 015 of 19] nfsd4: renew lease on seqid modifying operations
 [PATCH kNFSd 016 of 19] nfsd4: clarify close_lru handling
 [PATCH kNFSd 017 of 19] nfsd4: clean up nfs4_preprocess_seqid_op
 [PATCH kNFSd 018 of 19] nfsd4: check lock type against openmode.
 [PATCH kNFSd 019 of 19] nfsd4: fix fh_expire_type


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
