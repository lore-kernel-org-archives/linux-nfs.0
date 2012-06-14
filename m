Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36899 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754595Ab2FNUCD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jun 2012 16:02:03 -0400
Date: Thu, 14 Jun 2012 16:02:01 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org
Subject: nfsd bugfixes for 3.5
Message-ID: <20120614200201.GA13186@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull two nfsd bugfixes from:

  git://linux-nfs.org/~bfields/linux.git for-3.5

--b.

----------------------------------------------------------------
J. Bruce Fields (1):
      nfsd4: BUG_ON(!is_spin_locked()) no good on UP kernels

Stanislav Kinsbursky (1):
      NFS: hard-code init_net for NFS callback transports

 fs/nfs/callback.c   |   11 +++++------
 fs/nfsd/nfs4state.c |    4 ++--
 2 files changed, 7 insertions(+), 8 deletions(-)

commit bc2df47a408f2d64cf81bcfd0f6e3e14c84cb0ab
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Jun 12 08:28:48 2012 -0400

    nfsd4: BUG_ON(!is_spin_locked()) no good on UP kernels
    
    Most frequent symptom was a BUG triggering in expire_client, with the
    server locking up shortly thereafter.
    
    Introduced by 508dc6e110c6dbdc0bbe84298ccfe22de7538486 "nfsd41:
    free_session/free_client must be called under the client_lock".
    
    Cc: stable@kernel.org
    Cc: Benny Halevy <bhalevy@tonian.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 12918b10d59e975fd5241eef03ef9e6d5ea3dcfe
Author: Stanislav Kinsbursky <skinsbursky@parallels.com>
Date:   Fri Jun 1 13:55:47 2012 +0400

    NFS: hard-code init_net for NFS callback transports
    
    In case of destroying mount namespace on child reaper exit, nsproxy is zeroed
    to the point already. So, dereferencing of it is invalid.
    This patch hard-code "init_net" for all network namespace references for NFS
    callback services. This will be fixed with proper NFS callback
    containerization.
    
    Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
