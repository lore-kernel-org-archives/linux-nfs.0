Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:38514 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755811AbbLHEFI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2015 23:05:08 -0500
Date: Tue, 8 Dec 2015 04:05:04 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Christoph Hellwig <hch@lst.de>
Cc: tao.peng@primarydata.com, jeff.layton@primarydata.com,
        bfields@fieldses.org, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: [PATCH 1/4] locks: new locks_mandatory_area calling convention
Message-ID: <20151208040504.GA2791@ZenIV.linux.org.uk>
References: <1449143992-7415-1-git-send-email-hch@lst.de>
 <1449143992-7415-2-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1449143992-7415-2-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 03, 2015 at 12:59:49PM +0100, Christoph Hellwig wrote:
> Pass a loff_t end for the last byte instead of the 32-bit count
> parameter to allow full file clones even on 32-bit architectures.
> While we're at it also drop the pointless inode argument and simplify
> the read/write selection.

locks_mandatory_area() contains this:
        if (filp && !(filp->f_flags & O_NONBLOCK))
                sleep = true;
which is a strong hint that filp might be NULL.  And indeed it might -
        error = locks_verify_truncate(inode, NULL, length);
in vfs_truncate() and
        host_err = locks_verify_truncate(inode, NULL, iap->ia_size);
in nfsd_get_write_access().  Both are broken by that commit.

Where the hell would truncate(2) get struct file, anyway?  IOW, the inode
argument is _not_ pointless; re-added.
