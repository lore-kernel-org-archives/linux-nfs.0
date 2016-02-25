Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46358 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754253AbcBYBRP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Feb 2016 20:17:15 -0500
Date: Wed, 24 Feb 2016 20:17:12 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd bugfix for 4.5
Message-ID: <20160225011712.GA14213@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull an nfsd bugfix for 4.5 from

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.5-1

One fix for a bug that could cause a NULL write past the end of a buffer
in case of unusually long writes to some system interfaces used by
mountd and other nfs support utilities.

--b.

Stefan Hajnoczi (1):
      sunrpc/cache: fix off-by-one in qword_get()

 net/sunrpc/cache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
