Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41016 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751310AbbCTQVr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Mar 2015 12:21:47 -0400
Date: Fri, 20 Mar 2015 12:21:47 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>
Subject: [GIT] nfsd bugfix for 4.0
Message-ID: <20150320162147.GF2036@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull the following nfsd bugfix for 4.0:

  git://linux-nfs.org/~bfields/linux.git for-4.0

This is a fix for a crash easily triggered by 4.1 activity to a server
built with CONFIG_NFSD_PNFS.

There are some more bugfixes queued up that I intend to pass along next
week, but this is the most critical.

--b.

----------------------------------------------------------------
Christoph Hellwig (1):
      Subject: nfsd: don't recursively call nfsd4_cb_layout_fail

 fs/nfsd/nfs4layouts.c | 2 --
 1 file changed, 2 deletions(-)

