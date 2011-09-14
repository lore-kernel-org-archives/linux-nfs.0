Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60149 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932140Ab1INLp1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 00/25] nfsd4 state cleanup
Date: Wed, 14 Sep 2011 07:44:56 -0400
Message-Id: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is just another batch of little cleanups and bugfixes to the nfsd4
state code.

What I'm actually thinking I'd like to do next is change the way
stateid's are composed to make it possible to look up the client first.
Once the client's looked up, lookup of the individual stateid, and most
of the following work, looks to me like it could be done under a
per-client lock.  The set of clients doesn't change very much so we
could use locking that favors readers (maybe rcu) for that part.  So
that could be a first step towards saner locking.

And then also still to do:
	- close replays: we keep around a stateid to handle close
	  replays only in the case where it's the last stateid for an
	  openowner, but that's not sufficient.
	- the data structures aren't really right for the things we need
	  to do: e.g. release_lockowner currently does a linear search
	  through all the lockowners!
	- multiple client-to-lockowner locks for a given (owner, file)
	  aren't handled right.
	- I need to look again at doing a better job of distinguishing
	  the bad, expired, and stale cases for stateid's.

I was hoping to have that ready for 3.2 but unfortunately keep running
across small bugs or cleanup opportunities like these along the way;
perhaps next week....

--b.

J. Bruce Fields (25):
  nfsd4: centralize handling of replay owners
  nfsd4: cleanup seqid op stateowner usage
  nfsd4: extend state lock over seqid replay logic
  nfsd4: eliminate impossible open replay case
  nfsd4: drop most stateowner refcounting
  nfsd4: eliminate unused lt_stateowner
  nfsd4: share common seqid checks
  nfsd4: simplify check_open logic
  nfsd4: move double-confirm test to open_confirm
  nfsd4: move CLOSE_STATE special case to caller
  nfsd4: split stateowners into open and lockowners
  nfsd4: split out some free_generic_stateid code
  nfsd4: rearrange to avoid a forward reference
  nfsd4: split up find_stateid
  nfsd4: split preprocess_seqid, cleanup
  nfsd4: pass around typemask instead of flags
  nfsd4: rename init_stateid
  nfsd4: remove redundant stateid initialization
  nfsd4: move some of nfs4_stateid into a separate structure
  nfsd4: add common dl_stid field to delegation
  nfsd4: share common stid-hashing helper function
  nfsd4: hash deleg stateid's like any other
  nfsd4: fix test_stateid for delegation stateid's
  nfsd4: use deleg changes to cleanup preprocess_stateid_op
  nfsd4: better stateid hashing

 fs/nfsd/nfs4callback.c |    2 +-
 fs/nfsd/nfs4proc.c     |   25 +-
 fs/nfsd/nfs4state.c    |  989 +++++++++++++++++++++++-------------------------
 fs/nfsd/nfs4xdr.c      |   52 ++--
 fs/nfsd/state.h        |   92 +++--
 fs/nfsd/xdr4.h         |   12 +-
 6 files changed, 570 insertions(+), 602 deletions(-)

-- 
1.7.4.1

