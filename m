Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:49776 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751492AbdF1OfN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Jun 2017 10:35:13 -0400
Date: Wed, 28 Jun 2017 16:35:11 +0200
From: Christoph Hellwig <hch@lst.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Christoph Hellwig <hch@lst.de>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: clean up readv/writev helpers
Message-ID: <20170628143511.GA2359@lst.de>
References: <20170527081654.15957-1-hch@lst.de> <20170527193239.GM390@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170527193239.GM390@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 27, 2017 at 08:32:39PM +0100, Al Viro wrote:
> On Sat, May 27, 2017 at 11:16:44AM +0300, Christoph Hellwig wrote:
> > Hi Al,
> > 
> > this series cleans up how we implement the various vectored read and write
> > syscalls, as well as the internal iov_iter based APIs.  It then switches
> > nfsd to use vfs_iter_read/write which cleans up nfsd.  Note that all
> > exportable file systems already implement ->read_iter and ->write_iter
> > anyway.
> 
> 1--5 and 7--10 applied.

Yet these changes don't seem to be in linux-next.  Where did you apply
them to?
