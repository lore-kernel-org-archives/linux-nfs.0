From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 000 of 2] Introduction
Date: Wed, 01 Jun 2005 11:20:26 +1000
Message-ID: <20050601111730.4494.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DdHuQ-0004KI-DP
	for nfs@lists.sourceforge.net; Tue, 31 May 2005 18:20:38 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DdHuN-0002Ox-AO
	for nfs@lists.sourceforge.net; Tue, 31 May 2005 18:20:37 -0700
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
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

Hi,
 here are two patches for 2.4, which appear to be too late for 2.4.31...
 The first fixes a small semantic problem.
 The second adds some missing locking, that would only be a possible problem if using
 direct_io with xfs (I think).

NeilBrown

 [PATCH kNFSd 001 of 2] Don't drop setuid on directories when ownership changed by NFSd
 [PATCH kNFSd 002 of 2] Claim i_alloc_sem while changing file size in nfsd


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
