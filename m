Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33877 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753667Ab1BOS7G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Feb 2011 13:59:06 -0500
Date: Tue, 15 Feb 2011 13:59:02 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: 2.6.38 nfsd bugfixes
Message-ID: <20110215185902.GG29420@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The following bugfixes for 2.6.38 are available from:

	git://linux-nfs.org/~bfields/linux.git for-2.6.38

(Note several of the "nfsd4:" patches are just one fix for a
merge-window regression, with some preperatory cleanup rather finely
split out.)

--b.

Benny Halevy (1):
      NFSD: use nfserr for status after decode_cb_op_status

J. Bruce Fields (9):
      nfsd: don't leak dentry count on mnt_want_write failure
      nfsd4: split up nfsd_break_deleg_cb
      nfsd4: add helper function for lease setup
      nfsd4: fix leak on allocation error
      nfsd4: split lease setting into separate function
      nfsd4: remove unused deleg dprintk's.
      nfsd4: modify fi_delegations under recall_lock
      nfsd4: acquire only one lease per file
      nfsd: break lease on unlink due to rename

Konstantin Khorenko (1):
      NFSD: memory corruption due to writing beyond the stat array

 fs/nfsd/nfs4callback.c |    6 +-
 fs/nfsd/nfs4state.c    |  186 +++++++++++++++++++++++++++---------------------
 fs/nfsd/state.h        |    5 +-
 fs/nfsd/vfs.c          |   21 ++++--
 4 files changed, 125 insertions(+), 93 deletions(-)
