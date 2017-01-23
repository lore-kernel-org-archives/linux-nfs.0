Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47634 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750723AbdAWQ6d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Jan 2017 11:58:33 -0500
Date: Mon, 23 Jan 2017 11:58:33 -0500
To: Christoph Hellwig <hch@lst.de>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: setattr ATTR_SIZE vs the rest
Message-ID: <20170123165833.GD9493@fieldses.org>
References: <1485104060-15209-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1485104060-15209-1-git-send-email-hch@lst.de>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 22, 2017 at 05:54:19PM +0100, Christoph Hellwig wrote:
> I've got a report that there NFS clients that send SETATTR requests that
> mix size changes with uid/gid changes

That sounds a little weird.  Do you know anything about which clients,
or how common the behavior is?

> (see the recent pynfs patch for an
> artifical reproducer).  At least XFS and GFS2 are very unhappy with this,
> and other file systems also don't seem to handle the case correctly.

Does this cause a crash or corruption, or "just" fail to set the
attributes correctly?  (Just wondering how urgent the fix is....).

--b.

> 
> This patch splits the truncate processing in NFS out into a separate
> ->setattr call and uses the vfs_truncate helper for it, which also happens
> to shrink the NFSD code size by reusing more VFS boiler plate code.
> 
> I suspect in the mid-term we really should add a ->truncate method (different
> from the previous callback of the same name) to separate the two concepts
> clearly at the VFS level.
