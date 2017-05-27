Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:53922 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750732AbdE0Tcm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 May 2017 15:32:42 -0400
Date: Sat, 27 May 2017 20:32:39 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: clean up readv/writev helpers
Message-ID: <20170527193239.GM390@ZenIV.linux.org.uk>
References: <20170527081654.15957-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170527081654.15957-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 27, 2017 at 11:16:44AM +0300, Christoph Hellwig wrote:
> Hi Al,
> 
> this series cleans up how we implement the various vectored read and write
> syscalls, as well as the internal iov_iter based APIs.  It then switches
> nfsd to use vfs_iter_read/write which cleans up nfsd.  Note that all
> exportable file systems already implement ->read_iter and ->write_iter
> anyway.

1--5 and 7--10 applied.
