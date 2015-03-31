Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49656 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752095AbbCaUj2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2015 16:39:28 -0400
Date: Tue, 31 Mar 2015 16:39:26 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd bugfixes for 4.0
Message-ID: <20150331203926.GO6901@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd bugfixes from

	git://linux-nfs.org/~bfields/linux.git for-4.0

Two main issues:

	- We found that turning on pNFS by default (when it's configured
	  at build time) was too aggressive, so we want to switch the
	  default before the 4.0 release.

	- Recent client changes to increase open parallelism uncovered a
	  serious bug lurking in the server's open code.

Also fix a krb5/selinux regression.

The rest is mainly smaller pNFS fixes.

-b.

----------------------------------------------------------------
Christoph Hellwig (1):
      nfsd: require an explicit option to enable pNFS

J. Bruce Fields (1):
      nfsd: return correct lockowner when there is a race on hash insert

Jeff Layton (2):
      nfsd: return correct openowner when there is a race to put one in the hash
      sunrpc: make debugfs file creation failure non-fatal

Kinglong Mee (8):
      NFSD: restore trace event lost in mismerge
      NFSD: Check layout type when returning client layouts
      NFSD: Take care the return value from nfsd4_decode_stateid
      NFSD: Error out when register_shrinker() fail
      NFSD: Put exports after nfsd4_layout_verify fail
      NFSD: Printk blocklayout length and offset as format 0x%llx
      NFSD: Take care the return value from nfsd4_encode_stateid
      NFSD: Fix bad update of layout in nfsd4_return_file_layout

 fs/nfsd/blocklayout.c            |  2 +-
 fs/nfsd/blocklayoutxdr.c         |  6 ++---
 fs/nfsd/nfs4layouts.c            | 12 ++++++----
 fs/nfsd/nfs4proc.c               |  2 +-
 fs/nfsd/nfs4state.c              |  4 ++--
 fs/nfsd/nfs4xdr.c                | 20 ++++++++++++----
 fs/nfsd/nfscache.c               |  6 ++++-
 include/linux/sunrpc/debug.h     | 18 +++++++-------
 include/uapi/linux/nfsd/export.h |  2 +-
 net/sunrpc/clnt.c                |  4 +---
 net/sunrpc/debugfs.c             | 52 ++++++++++++++++++++++------------------
 net/sunrpc/sunrpc_syms.c         |  7 +-----
 net/sunrpc/xprt.c                |  7 +-----
 13 files changed, 78 insertions(+), 64 deletions(-)
