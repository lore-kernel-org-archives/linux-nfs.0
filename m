From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 0 of 18] Introduction
Date: Fri, 24 Sep 2004 14:54:52 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040924145130.2689.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAi7E-00089t-VA
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:28 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CAi7C-0008Jb-Ql
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:28 -0700
To: Andrew Morton <akpm@osdl.org>
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


Following are 18 patches against nfsd in 2.6.lastest.  They are mostly 
nfsv4 related with patch 2 being the exception (It is just a code-cleanup patch). 


Subject: [PATCH kNFSd 1 of 18] nfsd4 fix: nfsd oopsed when encountering a conflict with a local lock
Subject: [PATCH kNFSd 2 of 18] separate a little of logic from fh_verify into new function
Subject: [PATCH kNFSd 3 of 18] nfsd4: don't take i_sem around call to ->getxattr
Subject: [PATCH kNFSd 4 of 18] make sure getxattr inode op is non-NULL before calling it
Subject: [PATCH kNFSd 5 of 18] nfsd4: reference count stateowners
Subject: [PATCH kNFSd 6 of 18] nfsd4: take a reference to preserve stateowner through xdr replay code
Subject: [PATCH kNFSd 7 of 18] nfsd4: revert awkward extension of state lock over xdr for replay encoding
Subject: [PATCH kNFSd 8 of 18] nfsd4: fix race in xdr encoding of lock_denied response.
Subject: [PATCH kNFSd 9 of 18] remove incorrect stateid modification in nfsv4 open upgrade
Subject: [PATCH kNFSd 10 of 18] nfsd4: move open owner checks from nfsd4_process_open2 into new function
Subject: [PATCH kNFSd 11 of 18] nfsd4_open_locktype_posix_flag
Subject: [PATCH kNFSd 12 of 18] nfsd4: move seqid decrement on reclaim to separate function
Subject: [PATCH kNFSd 13 of 18] nfsd4: reorganize "if" in nfsd4_process_open2 to make test clearer
Subject: [PATCH kNFSd 14 of 18] nfsd4: move open_upgrade code into a separate function
Subject: [PATCH kNFSd 15 of 18] nfsd4: move some nfsd4_process_open2 code to nfs4_new_open
Subject: [PATCH kNFSd 16 of 18] Clean up nfsd4_process_open2
Subject: [PATCH kNFSd 17 of 18] nfsd4: fix putrootfh return
Subject: [PATCH kNFSd 18 of 18] nfsd4: move code to truncate on open to separate function

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
