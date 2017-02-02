Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45926 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752467AbdBBRlL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Feb 2017 12:41:11 -0500
From: Jan Kara <jack@suse.cz>
To: <linux-fsdevel@vger.kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-block@vger.kernel.org,
        Jan Kara <jack@suse.cz>, linux-mtd@lists.infradead.org,
        linux-nfs@vger.kernel.org, Petr Vandrovec <petr@vandrovec.name>,
        linux-nilfs@vger.kernel.org, cluster-devel@redhat.com,
        osd-dev@open-osd.org, codalist@TELEMANN.coda.cs.cmu.edu,
        linux-afs@lists.infradead.org, ecryptfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
        lustre-devel@lists.lustre.org
Subject: [PATCH 0/24 RFC] fs: Convert all embedded bdis into separate ones
Date: Thu,  2 Feb 2017 18:33:58 +0100
Message-Id: <20170202173422.3240-1-jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

this patch series converts all embedded occurences of struct backing_dev_info
to use standalone dynamically allocated structures. This makes bdi handling
unified across all bdi users and generally removes some boilerplate code from
filesystems setting up their own bdi. It also allows us to remove some code
from generic bdi implementation.

The patches were only compile-tested for most filesystems (I've tested
mounting only for NFS & btrfs) so fs maintainers please have a look whether
the changes look sound to you.

This series is based on top of bdi fixes that were merged into linux-block
git tree.

								Honza
