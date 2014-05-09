Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33241 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757881AbaEIVwm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 May 2014 17:52:42 -0400
Date: Fri, 9 May 2014 17:52:41 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd bug fixes for 3.15, part 2
Message-ID: <20140509215241.GD497@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull some nfsd bugfixes for 3.15:

  git://linux-nfs.org/~bfields/linux.git for-3.15

--b.

----------------------------------------------------------------
Kinglong Mee (1):
      NFSD: Call ->set_acl with a NULL ACL structure if no entries

Trond Myklebust (2):
      NFSd: Move default initialisers from create_client() to alloc_client()
      NFSd: call rpc_destroy_wait_queue() from free_client()

 fs/nfsd/nfs4acl.c   |   17 +++++++++--------
 fs/nfsd/nfs4state.c |   25 +++++++++++++------------
 2 files changed, 22 insertions(+), 20 deletions(-)
