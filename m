Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55563 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751094Ab1CIWoR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Mar 2011 17:44:17 -0500
Date: Wed, 9 Mar 2011 17:44:15 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org
Subject: nfsd bugfixes for 2.6.38
Message-ID: <20110309224414.GA25355@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Three nfsd bugfixes (all v4-related) are available from the for-2.6.38
branch at:

  git://linux-nfs.org/~bfields/linux.git for-2.6.38

(A couple slightly bigger fixes I'm punting to the 2.6.39 merge window
given the likely impending release.)

--b.

Benny Halevy (1):
      NFSD: fix decode_cb_sequence4resok

J. Bruce Fields (1):
      nfsd4: fix bad pointer on failure to find delegation

roel (1):
      nfsd: wrong index used in inner loop

 fs/nfsd/nfs4callback.c |    2 +-
 fs/nfsd/nfs4state.c    |   13 +++++++------
 fs/nfsd/nfs4xdr.c      |    4 ++--
 3 files changed, 10 insertions(+), 9 deletions(-)
