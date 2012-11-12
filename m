Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:59742 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395Ab2KLUBG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Nov 2012 15:01:06 -0500
Received: by mail-vb0-f46.google.com with SMTP id ff1so6652181vbb.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Nov 2012 12:01:05 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 00/11] nfsd: add nfsdcltrack support and limit the use of md5 hashes in nfsdv4 code
Date: Mon, 12 Nov 2012 15:00:47 -0500
Message-Id: <1352750458-16857-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the first "official" posting of the patchset that I sent as an
RFC last week. I've spent some time testing the set now and I'm fairly
convinced that it works properly. At this point, it's probably ready to
soak in -next for a bit and if all goes well, merge in 3.8.

The main changes from the last set are:

1/ I've prefixed this set with the patches to add nfsdcltrack

2/ fixed an off-by-one bug in nfsd4_cltrack_legacy_recdir()

3/ error handling for nfs4_make_rec_clidname() has been cleaned up so
   that errors from the functions called are returned to the caller

4/ the callers of nfs4_make_rec_clidname in the legacy tracker now call
   it earlier, which means that it's computed under fewer locks

5/ if nfs4_make_rec_clidname returns -ENOENT, then the legacy tracker
   will now disable the client ID tracking altogether and emit a
   printk to warn that recovery won't work properly

6/ the legacy tracker also frees the contents of the reclaim list in
   its gracedone operation. There's no point in keeping that around
   afterward.

Bruce, let me know if you see anything that needs addressing before
you can put this into your for-next branch.

Thanks,

Jeff Layton (11):
  nfsd: add a usermodehelper upcall for NFSv4 client ID tracking
  nfsd: change heuristic for selecting the client_tracking_ops
  nfsd: pass info about the legacy recoverydir in environment variables
  nfsd: warn about impending removal of nfsdcld upcall
  nfsd: have nfsd4_find_reclaim_client take a char * argument
  nfsd: break out reclaim record removal into separate function
  nfsd: make nfs4_client_to_reclaim return a pointer to the reclaim
    record
  nfsd: don't search for client by hash on legacy reboot recovery
    gracedone
  nfsd: move the confirmed and unconfirmed hlists to a rbtree
  nfsd: get rid of cl_recdir field
  nfsd: release the legacy reclaimable clients list in grace_done

 fs/nfsd/nfs4recover.c | 354 ++++++++++++++++++++++++++++++++++++++++++++++----
 fs/nfsd/nfs4state.c   | 217 ++++++++++++++++++-------------
 fs/nfsd/state.h       |  14 +-
 3 files changed, 461 insertions(+), 124 deletions(-)

-- 
1.7.11.7

