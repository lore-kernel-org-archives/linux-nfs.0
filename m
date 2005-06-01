From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 000 of 28] Introduction
Date: Thu, 02 Jun 2005 08:50:55 +1000
Message-ID: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3I-0005vb-7V
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:08 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3G-0002Pk-Pc
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:08 -0700
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


Following are a bunch of patches for nfsd-v4 (and a little lockd fix).
They should all wait for after 2.6.12

The last three are probably the most interesting.  

The NFSv4 server needs to keep state information about clients in
stable storage.  To do this it is given a directory name (via a write
to the NFSd filesystem) and it creates subdirectories (which may later
contain files) inside this directory.

This is implemented in patches 26-28

NeilBrown


 [PATCH kNFSd 001 of 28] lockd: flush signals on shutdown
 [PATCH kNFSd 002 of 28] nfs4: hold filp while reading or writing
 [PATCH kNFSd 003 of 28] nfsd4: fix probe_callback
 [PATCH kNFSd 004 of 28] nfsd4: nfs4_check_open_reclaim cleanup
 [PATCH kNFSd 005 of 28] nfsd4: create separate laundromat workqueue
 [PATCH kNFSd 006 of 28] nfsd4: simplify lease changing
 [PATCH kNFSd 007 of 28] nfsd4: delegation recovery
 [PATCH kNFSd 008 of 28] nfsd4: rename nfs4_state_init
 [PATCH kNFSd 009 of 28] nfsd4: clean up state initialization
 [PATCH kNFSd 010 of 28] nfsd4: remove nfs4_reclaim_init
 [PATCH kNFSd 011 of 28] nfsd4: idmap initialization
 [PATCH kNFSd 012 of 28] nfsd4: setclientid simplification
 [PATCH kNFSd 013 of 28] nfsd4: reboot hash
 [PATCH kNFSd 014 of 28] nfsd4: add find_{un}conf_by_str functions to simplify setclientid
 [PATCH kNFSd 015 of 28] nfsd4: grace period end
 [PATCH kNFSd 016 of 28] nfsd4: make needlessly global code static
 [PATCH kNFSd 017 of 28] nfsd4: fix uncomfirmed list
 [PATCH kNFSd 018 of 28] nfsd4: fix setclientid_confirm cases
 [PATCH kNFSd 019 of 28] nfsd4: fix setclientid_confirm error return
 [PATCH kNFSd 020 of 28] nfsd4: setclientid_confirm gotoectomy
 [PATCH kNFSd 021 of 28] nfsd4: setclientid_confirm comments
 [PATCH kNFSd 022 of 28] nfsd4: miscellaneous setclientid_confirm cleanup
 [PATCH kNFSd 023 of 28] nfsd4: rename state list fields
 [PATCH kNFSd 024 of 28] nfsd4: allow multiple lockowners
 [PATCH kNFSd 025 of 28] nfsd4: remove cb_parsed
 [PATCH kNFSd 026 of 28] nfsd4: initialize recovery directory
 [PATCH kNFSd 027 of 28] nfsd4: reboot recovery
 [PATCH kNFSd 028 of 28] nfsd4-reboot-dirname


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
