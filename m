Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:57679 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755715AbbCCW3P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2015 17:29:15 -0500
Date: Tue, 3 Mar 2015 17:29:14 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd fixes for 4.0
Message-ID: <20150303222914.GC19439@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 4.0 from:

  git://linux-nfs.org/~bfields/linux.git for-4.0

Three miscellaneous bugfixes, most importantly the clp->cl_revoked bug,
which we've seen several reports of people hitting.

--b.

----------------------------------------------------------------
Andrew Elble (1):
      nfsd: fix clp->cl_revoked list deletion causing softlock in nfsd

Dan Carpenter (1):
      sunrpc: integer underflow in rsc_parse()

David Ramos (1):
      svcrpc: fix memory leak in gssp_accept_sec_context_upcall

 fs/nfsd/nfs4state.c                  | 2 +-
 net/sunrpc/auth_gss/gss_rpc_upcall.c | 2 ++
 net/sunrpc/auth_gss/svcauth_gss.c    | 2 ++
 3 files changed, 5 insertions(+), 1 deletion(-)
