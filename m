Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34434 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966493Ab2JZVG6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Oct 2012 17:06:58 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Peter Staubach <pstaubach@exagrid.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/2] fix nfsd stable write implementation
Date: Fri, 26 Oct 2012 17:06:55 -0400
Message-Id: <1351285617-20450-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Peter pointed out to me that the nfs server is implementing stable
writes by setting the O_SYNC flag.  I can't see why we couldn't write
and then sync instead, but I don't know this stuff as well as I should;
does the following look reasonable to people?

--b.

J. Bruce Fields (2):
  nfsd: assume writeable exportabled filesystems have f_sync
  nfsd: use vfs_fsync_range(), not O_SYNC, for stable writes

 fs/nfsd/vfs.c |   26 ++++++--------------------
 1 file changed, 6 insertions(+), 20 deletions(-)

-- 
1.7.9.5

