Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46755 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753885Ab3CKTpf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Mar 2013 15:45:35 -0400
Date: Mon, 11 Mar 2013 15:45:30 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: 3.9 nfsd bugfixes
Message-ID: <20130311194530.GC642@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull a couple 3.9 nfsd bugfixes from:

  git://linux-nfs.org/~bfields/linux.git for-3.9

Some minor fallout from the user-namespace work broke most krb5 mounts
to nfsd, and I screwed up a change to the AF_LOCAL rpc code.

--b.

----------------------------------------------------------------
J. Bruce Fields (2):
      nfsd: fix krb5 handling of anonymous principals
      sunrpc: don't attempt to cancel unitialized work

 net/sunrpc/auth_gss/svcauth_gss.c |   12 ++++++++----
 net/sunrpc/xprtsock.c             |   15 ++++++++++-----
 2 files changed, 18 insertions(+), 9 deletions(-)
