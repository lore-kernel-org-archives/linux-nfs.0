Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:41305 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751114AbdAWMdu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Jan 2017 07:33:50 -0500
Date: Mon, 23 Jan 2017 13:33:48 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Christoph Hellwig <hch@lst.de>, bfields@redhat.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] nfsd: special case truncates some more
Message-ID: <20170123123348.GA28102@lst.de>
References: <1485104060-15209-1-git-send-email-hch@lst.de> <1485104060-15209-2-git-send-email-hch@lst.de> <1485174116.2786.7.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1485174116.2786.7.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 23, 2017 at 07:21:56AM -0500, Jeff Layton wrote:
> So if you only have ATTR_SIZE then you're going to end up having to do
> another notify_change to update the ctime? Can we get away with just
> calling vfs_truncate when only ATTR_SIZE is set and skipping the
> notify_change to update the ctime?

We probably could, but there are some fine details there:

For truncate(2) Posix require us to not updated the time stamps when
truncating and already zero length file to 0, but for ftruncate(2) and
O_TRUNC we do have to update the mtime and ctime.  The Linux VFS
communicates that difference by not setting ATTR_CTIME and ATTR_MTIME in
ia_valid for truncate(2), but expecting the fs to update them anyway.
(another reason for a proper truncate method to make this explicit).

I'll need to look at the exact NFS semantics in that area, but after
a bit of research I can probably come up with something that will work.
