From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 000 of 26] Introduction
Date: Fri, 13 Jan 2006 12:00:47 +1100
Message-ID: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJI-0002XA-7v
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:00:56 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJH-0004fy-Q6
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:00:56 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.16] == smtp-dist-01.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:00:49 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:00:47 +1100
To: nfs@lists.sourceforge.net
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

(I sent these to Andrew already an inadvertantly didn't copy
to the nfs list as is my practice.  So this set is to the list
and not to Andrew).

Just in time for -rc1 (if I'm lucky:-) here are a bunch of 
nfsd patches.
 The last 4 are from Al Viro on Christmas day and are trivial.
 The 20 before that are from the NFSv4 team and mostly affect
   only -v4 (which is still experimental).
 The second rearranges removes two 'inlines' saving many bytes.
 The first causes any error from 'fsync' on a directory to be propagated 
   back to the client.

Thanks,
NeilBrown

 [PATCH kNFSd 000 of 26] Introduction
 [PATCH kNFSd 001 of 26] Check error status from nfsd_sync_dir
 [PATCH kNFSd 002 of 26] Remove inline from a couple of large NFS functions.
 [PATCH kNFSd 003 of 26] svcrpc: save and restore the daddr field when request deferred
 [PATCH kNFSd 004 of 26] nfsd4: misc lock fixes
 [PATCH kNFSd 005 of 26] nfsd4: fix nfsd4_lock cleanup on failure
 [PATCH kNFSd 006 of 26] nfsd4: rename lk_stateowner
 [PATCH kNFSd 007 of 26] nfsd4: remove release_state_owner()
 [PATCH kNFSd 008 of 26] nfsd4: fix check_for_locks
 [PATCH kNFSd 009 of 26] nfsd4: operation debugging
 [PATCH kNFSd 010 of 26] svcrpc: gss: handle the GSS_S_CONTINUE
 [PATCH kNFSd 011 of 26] svcrpc: gss: server context init failure handling
 [PATCH kNFSd 012 of 26] svcrpc: gss: svc context creation error handling
 [PATCH kNFSd 013 of 26] nfsd4: fix open of recovery directory
 [PATCH kNFSd 014 of 26] nfsd4: recovery lookup dir check
 [PATCH kNFSd 015 of 26] nfsd4: handle replays of failed open reclaims
 [PATCH kNFSd 016 of 26] nfsd4: no replays on unconfirmed owners
 [PATCH kNFSd 017 of 26] nfsd4: nfs4state.c miscellaneous goto removals
 [PATCH kNFSd 018 of 26] nfsd4: simplify process-open1 logic
 [PATCH kNFSd 019 of 26] nfsd4: don't create on open that fails due to ERR_GRACE
 [PATCH kNFSd 020 of 26] nfsd4: fix open_downgrade
 [PATCH kNFSd 021 of 26] nfsd4: Fix bug in rdattr_error return
 [PATCH kNFSd 022 of 26] nfsd4: clean up settattr code
 [PATCH kNFSd 023 of 26] nfsd/vfs.c: endianness fixes
 [PATCH kNFSd 024 of 26] nfsd4_truncate() bogus return value
 [PATCH kNFSd 025 of 26] NFSERR_SERVERFAULT returned host-endian
 [PATCH kNFSd 026 of 26] Subject: [PATCH] nfsd4_lock() returns bogus values to clients


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
