Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:56884 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755866AbaKTFsP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Nov 2014 00:48:15 -0500
Date: Wed, 19 Nov 2014 21:48:13 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        Benjamin Coddington <bcodding@redhat.com>,
        Tom Haynes <thomas.haynes@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Client never uses DATA_SYNC
Message-ID: <20141120054813.GA32361@infradead.org>
References: <alpine.LRH.2.11.1411041036320.20279@sh-el6.eng.rdu2.redhat.com>
 <CAHQdGtSowoYZDUb6jBbj8Q0g6LeNVHmOCNBoZdDU8CgCZFpOXA@mail.gmail.com>
 <20141105085317.GA18658@infradead.org>
 <20141105144133.GA3139@fieldses.org>
 <20141106201341.GD22638@fieldses.org>
 <20141107072637.GA25215@infradead.org>
 <20141118170210.GG7419@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141118170210.GG7419@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 18, 2014 at 12:02:10PM -0500, J. Bruce Fields wrote:
> On Thu, Nov 06, 2014 at 11:26:37PM -0800, Christoph Hellwig wrote:
> > Note that for filesystems natively implementing the change attribute
> > (btrfs, XFSv5 and ext4 with a mount option) there is no difference anyway,
> 
> Is there something special I have to do to get this on xfs?

You need to create a version 5 filesystem.  For this your need fairly
recent xfsprogs (e.g. RHEL7ish), and create the filesystem using

# mkfs.xf -m crc=1 /dev/device

You probably also want the untested patch below to proper initialize
the version on inodes read from disk:

diff --git a/fs/xfs/xfs_iops.c b/fs/xfs/xfs_iops.c
index ec6dcdc..c1e2700 100644
--- a/fs/xfs/xfs_iops.c
+++ b/fs/xfs/xfs_iops.c
@@ -1277,6 +1277,9 @@ xfs_setup_inode(
 	inode->i_ctime.tv_nsec	= ip->i_d.di_ctime.t_nsec;
 	xfs_diflags_to_iflags(inode, ip);
 
+	if (xfs_sb_version_hascrc(&ip->i_mount->m_sb))
+		 inode->i_version = ip->i_d.di_changecount;
+
 	ip->d_ops = ip->i_mount->m_nondir_inode_ops;
 	lockdep_set_class(&ip->i_lock.mr_lock, &xfs_nondir_ilock_class);
 	switch (inode->i_mode & S_IFMT) {
