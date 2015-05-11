Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51093 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751435AbbEKVm3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 May 2015 17:42:29 -0400
Date: Mon, 11 May 2015 17:42:28 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd bugfixes for 4.1
Message-ID: <20150511214228.GC23754@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd fixes for 4.1 from

  git://linux-nfs.org/~bfields/linux.git for-4.1

Mainly pnfs fixes (and for problems with generic callback code made more
obvious by pnfs).

--b.

----------------------------------------------------------------
Christoph Hellwig (5):
      nfsd/blocklayout: pretend we can send deviceid notifications
      nfsd: fix the check for confirmed openowner in nfs4_preprocess_stateid_op
      nfsd: split transport vs operation errors for callbacks
      nfsd: fix callback restarts
      nfsd: skip CB_NULL probes for 4.1 or later

Sachin Bhamare (1):
      nfsd: fix pNFS return on close semantics

Scott Mayhew (1):
      svcrpc: fix potential GSSX_ACCEPT_SEC_CONTEXT decoding failures

 fs/nfsd/blocklayout.c             |  11 +++
 fs/nfsd/nfs4callback.c            | 119 ++++++++++++++----------------
 fs/nfsd/nfs4state.c               | 147 +++++++++++++++++++++++++++++++++-----
 fs/nfsd/state.h                   |  19 ++++-
 fs/nfsd/xdr4.h                    |   1 +
 net/sunrpc/auth_gss/gss_rpc_xdr.c |  23 ++++--
 6 files changed, 228 insertions(+), 92 deletions(-)
