Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:42949 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750705AbdAWPgS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Jan 2017 10:36:18 -0500
Date: Mon, 23 Jan 2017 16:36:15 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Christoph Hellwig <hch@lst.de>, bfields@redhat.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] nfsd: special case truncates some more
Message-ID: <20170123153615.GA32201@lst.de>
References: <1485104060-15209-1-git-send-email-hch@lst.de> <1485104060-15209-2-git-send-email-hch@lst.de> <1485174116.2786.7.camel@poochiereds.net> <20170123123348.GA28102@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20170123123348.GA28102@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 23, 2017 at 01:33:48PM +0100, Christoph Hellwig wrote:
> I'll need to look at the exact NFS semantics in that area, but after
> a bit of research I can probably come up with something that will work.

Here is my first attempt.  As vfs_truncate will add the ctime and mtime
updates when needed it just leaves handling that quirk to vfs_truncate
and then exits early if no other attributes are set.

Unfortunately at least the Linux client always seems to also request
a mtime update with a size update.  We could keep the

	if (iap->ia_size != i_size_read(inode))

check from the old code and remove ATTR_MTIME, but these racy checks
outside i_rwsem make me feel a bit uneasy.  Jeff, Bruce - any opinion
if we should add something like this:

	/* vfs_truncate will update ctime and mtime if the size changes */
	if (iap->ia_size != i_size_read(inode))
		iap->ia_valid &= ATTR_MTIME;

back to nfsd_setattr?  This would avoid the additional setattr call,
but make me feel dirty :)

---
