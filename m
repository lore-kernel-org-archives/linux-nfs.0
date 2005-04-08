From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 000 of 16] Introduction
Date: Fri, 08 Apr 2005 11:00:14 +1000
Message-ID: <20050408105936.25374.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJikO-0006Tw-9O
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DJikL-0000uZ-Kn
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
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


16 patches for knfsd.
The first three are bug fixes that would be good to get into 2.6.12
The rest are continuing work on tidying and extending the V4 server.

Thanks,
NeilBrown


 [PATCH kNFSd 001 of 16] nfsd: clear signals before exiting the nfsd() thread
 [PATCH kNFSd 002 of 16] nfsd4: callback create rpc client returns
 [PATCH kNFSd 003 of 16] nfsd4: fix struct file leak

 [PATCH kNFSd 004 of 16] nfsd4: find_delegation_file()
 [PATCH kNFSd 005 of 16] nfsd4: nfs4_check_delegmode
 [PATCH kNFSd 006 of 16] nfsd4: don't reopen for delegated client
 [PATCH kNFSd 007 of 16] nfsd4: add open state code for CLAIM_DELEGATE_CUR
 [PATCH kNFSd 008 of 16] nfsd4: support CLAIM_DELEGATE_CUR
 [PATCH kNFSd 009 of 16] nfsd4: fix fh_expire_type
 [PATCH kNFSd 010 of 16] nfsd4: block metadata ops during grace period
 [PATCH kNFSd 011 of 16] nfsd4: slabify nfs4_files
 [PATCH kNFSd 012 of 16] nfsd4: slabify stateids
 [PATCH kNFSd 013 of 16] nfsd4: slabify delegations
 [PATCH kNFSd 014 of 16] nfsd4: remove debugging counters
 [PATCH kNFSd 015 of 16] nfsd4: rename nfs4_file fields
 [PATCH kNFSd 016 of 16] nfsd4: reference count struct nfs4_file


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
