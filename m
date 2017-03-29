Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33865 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756081AbdC2K4d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 29 Mar 2017 06:56:33 -0400
From: Jan Kara <jack@suse.cz>
To: <linux-fsdevel@vger.kernel.org>
Cc: linux-block@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        Jan Kara <jack@suse.cz>, linux-mtd@lists.infradead.org,
        linux-nfs@vger.kernel.org, Petr Vandrovec <petr@vandrovec.name>,
        linux-nilfs@vger.kernel.org, cluster-devel@redhat.com,
        osd-dev@open-osd.org, codalist@coda.cs.cmu.edu,
        linux-afs@lists.infradead.org, ecryptfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
        lustre-devel@lists.lustre.org
Subject: [PATCH 0/25 v2] fs: Convert all embedded bdis into separate ones
Date: Wed, 29 Mar 2017 12:55:58 +0200
Message-Id: <20170329105623.18241-1-jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

this is the second revision of the patch series which converts all embedded
occurences of struct backing_dev_info to use standalone dynamically allocated
structures. This makes bdi handling unified across all bdi users and generally
removes some boilerplate code from filesystems setting up their own bdi. It
also allows us to remove some code from generic bdi implementation.

The patches were only compile-tested for most filesystems (I've tested
mounting only for NFS & btrfs) so fs maintainers please have a look whether
the changes look sound to you.

This series is based on top of bdi fixes that were merged into linux-block
git tree into for-next branch. I have pushed out the result as a branch to

git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-fs.git bdi

Changes since v1:
* Added some acks
* Added further FUSE cleanup patch
* Added removal of unused argument to bdi_register()
* Fixed up some compilation failures spotted by 0-day testing

								Honza
