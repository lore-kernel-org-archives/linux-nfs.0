From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 0 of 54] Introduction
Date: Tue, 08 Mar 2005 17:06:42 +1100
Message-ID: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrl-00026W-Up
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:49 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrl-0007sp-0r
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:49 -0800
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

54 (!!) patches for knfsd. Mostly nfsv4 related from Bruce Fields and co.

First 3 are trivial, silencing a pointless warning and replacing schedule_timeout
with msleep or usleep as appropriate.

The last three mail changes to 'leases' in fs/locks.c 
The only substantial change is the last one which removes "remove_lease", which
is currently only used by nfsv4 server.

[PATCH kNFSd 1 of 54] Fix error reported by nfsd which it gets ETXTBSY
[PATCH kNFSd 2 of 54] replace schedule_timeout() with msleep()
[PATCH kNFSd 3 of 54] fs/nfs4callback: replace schedule_timeout() with ssleep()
[PATCH kNFSd 4 of 54] nfsd4: remove utf8 checking
[PATCH kNFSd 5 of 54] nfsd4: create a slab cache for stateowners
[PATCH kNFSd 6 of 54] nfsd4: remove stateowner debug counters
[PATCH kNFSd 7 of 54] nfsd4: Fix oops on nfsd4 shutdown
[PATCH kNFSd 8 of 54] nfsd4: cbnull refcount leak
[PATCH kNFSd 9 of 54] nfsd4: reclaim cleanup
[PATCH kNFSd 10 of 54] nfsd4: move special stateid processing
[PATCH kNFSd 11 of 54] nfsd4: allow some reads and writes during the grace period
[PATCH kNFSd 12 of 54] nfsd4: use existing open instead of reopening on read and write
[PATCH kNFSd 13 of 54] nfsd4: miscellaneous open cleanup
[PATCH kNFSd 14 of 54] nfsd4: miscellaneous open cleanup 2
[PATCH kNFSd 15 of 54] nfsd4: miscellaneous open cleanup 3
[PATCH kNFSd 16 of 54] nfsd4: don't release nfs4_file with associated delegations
[PATCH kNFSd 17 of 54] nfsd4: do callback replays by hand
[PATCH kNFSd 18 of 54] nfsd4: simplify open_delegation
[PATCH kNFSd 19 of 54] nfsd4: simplify open_delegation 2
[PATCH kNFSd 20 of 54] nfsd4: miscellaneous delegation fixes
[PATCH kNFSd 21 of 54] nfsd4: remove unnecessary check in find_delegation_stateid
[PATCH kNFSd 22 of 54] nfsd4: fix nfs4_check_delegmode()
[PATCH kNFSd 23 of 54] nfsd4: simplify clientid hash table searches
[PATCH kNFSd 24 of 54] nfsd4: simplify verify_clientid
[PATCH kNFSd 25 of 54] nfsd4: don't allow unconfirmed renew
[PATCH kNFSd 26 of 54] nfsd4: provide no_cb_path error on renew
[PATCH kNFSd 27 of 54] nfsd4: simplify find_openstateowner_str
[PATCH kNFSd 28 of 54] nfsd4: simplify find functions
[PATCH kNFSd 29 of 54] nfsd4: return callback_ident in callbacks
[PATCH kNFSd 30 of 54] nfsd4: remove incorrect kfree from callback
[PATCH kNFSd 31 of 54] nfsd4: make nfsd4_cb_recall return void
[PATCH kNFSd 32 of 54] nfsd4: fix callback cred refcnt leak
[PATCH kNFSd 33 of 54] nfsd4: use sync rpc for delegation recall
[PATCH kNFSd 34 of 54] nfsd4: trivial callback cleanup
[PATCH kNFSd 35 of 54] nfsd4: nfs4_cb_recall cleanup
[PATCH kNFSd 36 of 54] nfsd4: remove dl_recall_cnt
[PATCH kNFSd 37 of 54] nfsd4: rename release_stateid_lockowner
[PATCH kNFSd 38 of 54] nfsd4: keep lockowners off perclient list
[PATCH kNFSd 39 of 54] nfsd4: fix laundromat delegation reaping
[PATCH kNFSd 40 of 54] nfsd4: remove st_vfs_set
[PATCH kNFSd 41 of 54] nfsd4: remove st_vfs_file checks
[PATCH kNFSd 42 of 54] nfsd4: fix cb-race
[PATCH kNFSd 43 of 54] nfsd4: fix delegation refcounting
[PATCH kNFSd 44 of 54] nfsd4: reorganize release_deleg
[PATCH kNFSd 45 of 54] nfsd4: store-file-with-deleg
[PATCH kNFSd 46 of 54] nfsd4: fix delegation filp sharing
[PATCH kNFSd 47 of 54] nfsd4: fix sleep under spinlock
[PATCH kNFSd 48 of 54] nfsd4: allow io to use deleg stateid file
[PATCH kNFSd 49 of 54] nfsd4: remove dl_state
[PATCH kNFSd 50 of 54] nfsd4: fix delegation refcount leak
[PATCH kNFSd 51 of 54] nfsd4: fix_release_state_owner prototype
[PATCH kNFSd 52 of 54] locks: remove unnecessary BUG()
[PATCH kNFSd 53 of 54] nfsd4: move delegation decisions to lock_manager callbacks
[PATCH kNFSd 54 of 54] nfsd4: eliminate unnecessary remove_lease


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
