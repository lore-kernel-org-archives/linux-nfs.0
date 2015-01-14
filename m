Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:57847 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbbANJnm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 04:43:42 -0500
From: Christoph Hellwig <hch@lst.de>
To: Jens Axboe <axboe@fb.com>
Cc: David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: backing_dev_info cleanups & lifetime rule fixes V2
Date: Wed, 14 Jan 2015 10:42:29 +0100
Message-Id: <1421228561-16857-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The first 8 patches are unchanged from the series posted a week ago and
cleans up how we use the backing_dev_info structure in preparation for
fixing the life time rules for it.  The most important change is to
split the unrelated nommu mmap flags from it, but it also remove a
backing_dev_info pointer from the address_space (and thus the inode)
and cleans up various other minor bits.

The remaining patches sort out the issues around bdi_unlink and now
let the bdi life until it's embedding structure is freed, which must
be equal or longer than the superblock using the bdi for writeback,
and thus gets rid of the whole mess around reassining inodes to new
bdis.

Changes since V1:
 - various minor documentation updates based on Feedback from Tejun

