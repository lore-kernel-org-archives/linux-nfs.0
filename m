From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 0 of 16] Introduction
Date: Tue, 22 Mar 2005 16:42:00 +1100
Message-ID: <20050322163830.8762.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDcA2-0006ly-Aq
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:38 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DDc9z-00059v-TZ
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:38 -0800
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

Following are 16 patches against nfsd in 2.6.12-rc1-mm1

Most are nfsv4 related.
Patch 2 removes an inexplicable increment of f_count for a file.  This 
fixes a problem wherein an exported filesystem may never be unmountable because a
file on it is never closed.

This could possibly be a candidate for 2.6.12.  The rest should wait to go 
in to 2.6.13-rc

NeilBrown


[PATCH kNFSd 0 of 16] Introduction
[PATCH kNFSd 1 of 16] svcrpc: auth_domain documentation
[PATCH kNFSd 2 of 16] nlm: fix f_count leak
[PATCH kNFSd 3 of 16] nfsd4: fix share conflict tests
[PATCH kNFSd 4 of 16] nfsd4: remove unneeded stateowner arguments
[PATCH kNFSd 5 of 16] nfsd4: fix use after put() in cb_recall
[PATCH kNFSd 6 of 16] nfsd4: allow read on open for write
[PATCH kNFSd 7 of 16] nfsd4: factor out common open_truncate code
[PATCH kNFSd 8 of 16] nfsd4: fix failure to truncate on some opens
[PATCH kNFSd 9 of 16] nfsd4_remove_unused_acl_function
[PATCH kNFSd 10 of 16] nfsd4: don't set WRITE_OWNER in either allow or deny bits
[PATCH kNFSd 11 of 16] nfsd4: acl don't set named attrs
[PATCH kNFSd 12 of 16] nfsd4: acl error fix
[PATCH kNFSd 13 of 16] nfsd4: rename release_delegation
[PATCH kNFSd 14 of 16] nfsd4: remove trailing whitespace from nfs4proc.c
[PATCH kNFSd 15 of 16] nfsd4: fix open returns for other claim types
[PATCH kNFSd 16 of 16] nfsd4: fix indentation in nfsd4_open


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
