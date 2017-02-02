Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38584 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751969AbdBBUiQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Feb 2017 15:38:16 -0500
Date: Thu, 2 Feb 2017 15:38:15 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] second nfsd bugfix pull request
Message-ID: <20170202203815.GA17298@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.10-2

----------------------------------------------------------------
Three more miscellaneous nfsd bugfixes.

----------------------------------------------------------------
Christoph Hellwig (1):
      nfsd: special case truncates some more

J. Bruce Fields (1):
      svcrpc: fix oops in absence of krb5 module

Kinglong Mee (1):
      NFSD: Fix a null reference case in find_or_create_lock_stateid()

 fs/nfsd/nfs4layouts.c             |  5 +-
 fs/nfsd/nfs4state.c               | 19 ++++----
 fs/nfsd/state.h                   |  4 +-
 fs/nfsd/vfs.c                     | 97 +++++++++++++++------------------------
 net/sunrpc/auth_gss/gss_rpc_xdr.c |  2 +-
 5 files changed, 51 insertions(+), 76 deletions(-)
