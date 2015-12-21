Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44672 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751737AbbLUUWc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Dec 2015 15:22:32 -0500
Date: Mon, 21 Dec 2015 15:22:30 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd fix for 4.4
Message-ID: <20151221202230.GC7869@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull an nfsd change for 4.4:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.4-1

Just one fix for a NFSv4 callback bug introduced in 4.4.

----------------------------------------------------------------
Jeff Layton (1):
      nfsd: don't hold ls_mutex across a layout recall

 fs/nfsd/nfs4layouts.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
