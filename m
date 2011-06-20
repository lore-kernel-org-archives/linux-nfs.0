Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52125 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752422Ab1FTU1e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jun 2011 16:27:34 -0400
Date: Mon, 20 Jun 2011 16:27:31 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd bugfixes for 3.0
Message-ID: <20110620202731.GB18369@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The for-2.6.40 branch at

  git://linux-nfs.org/~bfields/linux.git for-2.6.40

has some bugfixes that would be appropriate for 3.0.

(Yeah, yeah, so my branch naming is obsolete.)

--b.

Casey Bodley (1):
      nfsd: link returns nfserr_delay when breaking lease

J. Bruce Fields (2):
      nfsd: fix dependency of nfsd on auth_rpcgss
      nfsd4: fix break_lease flags on nfsd open

Randy Dunlap (1):
      nfsd: v4 support requires CRYPTO

 fs/nfsd/Kconfig                          |    1 +
 fs/nfsd/nfsctl.c                         |   19 ++++++-------------
 fs/nfsd/vfs.c                            |   19 ++++++++++++-------
 include/linux/sunrpc/gss_krb5_enctypes.h |    4 ++++
 net/sunrpc/auth_gss/gss_krb5_mech.c      |    3 ++-
 5 files changed, 25 insertions(+), 21 deletions(-)
 create mode 100644 include/linux/sunrpc/gss_krb5_enctypes.h
