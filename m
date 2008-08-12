From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfsd-related changes for 2.6.27
Date: Tue, 12 Aug 2008 16:04:23 -0400
Message-ID: <20080812200423.GA384@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	Neil Brown <neilb@suse.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41740 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750989AbYHLUE1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2008 16:04:27 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A few nfsd-related changes are ready in:

	git://linux-nfs.org/~bfields/linux.git for-2.6.27

One is a bugfix and the other two are completely trivial, so I assume
all are appropriate for 2.6.27.

--b.

Harvey Harrison (1):
      lockd: trivial sparse endian annotations

J. Bruce Fields (1):
      MAINTAINERS: mention lockd and sunrpc in nfs entries

Julia Lawall (1):
      fs/nfsd/export.c: Adjust error handling code involving auth_domain_put

 MAINTAINERS         |    4 ++--
 fs/lockd/svc4proc.c |    4 ++--
 fs/lockd/svcproc.c  |    4 ++--
 fs/nfsd/export.c    |    6 +++---
 4 files changed, 9 insertions(+), 9 deletions(-)
