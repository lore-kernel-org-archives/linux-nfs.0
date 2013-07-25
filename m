Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36450 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756515Ab3GYTo0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Jul 2013 15:44:26 -0400
Date: Thu, 25 Jul 2013 15:44:25 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd fixes for 3.11
Message-ID: <20130725194425.GA17962@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull one more nfsd bugfix for 3.11:

  git://linux-nfs.org/~bfields/linux.git for-3.11

--b.

----------------------------------------------------------------
Harshula Jayasuriya (1):
      nfsd: nfsd_open: when dentry_open returns an error do not propagate as struct file

 fs/nfsd/vfs.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)
