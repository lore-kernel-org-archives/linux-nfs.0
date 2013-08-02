Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39263 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754431Ab3HBQPJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Aug 2013 12:15:09 -0400
Date: Fri, 2 Aug 2013 12:15:08 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd bugfixes for 3.11
Message-ID: <20130802161508.GM17581@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull some more nfsd bugfixes for 3.11 from

  git://linux-nfs.org/~bfields/linux.git for-3.11

Most of this is due to a screwup on my part--some gss-proxy crashes got
fixed before the merge window but somehow never made it out of a
temporary git repo on my laptop....

--b.

----------------------------------------------------------------
J. Bruce Fields (4):
      svcrpc: fix gss_rpc_upcall create error
      svcrpc: fix gss-proxy xdr decoding oops
      svcrpc: fix kfree oops in gss-proxy code
      svcrpc: set cr_gss_mech from gss-proxy as well as legacy upcall

NeilBrown (1):
      NFSD/sunrpc: avoid deadlock on TCP connection due to memory pressure.

 net/sunrpc/auth_gss/gss_rpc_upcall.c |    3 +--
 net/sunrpc/auth_gss/gss_rpc_xdr.c    |    9 +++++----
 net/sunrpc/auth_gss/svcauth_gss.c    |    2 +-
 net/sunrpc/svcsock.c                 |    4 +++-
 4 files changed, 10 insertions(+), 8 deletions(-)
