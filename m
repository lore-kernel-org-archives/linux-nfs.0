Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:52128 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751559AbdF1Qhn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jun 2017 12:37:43 -0400
Date: Wed, 28 Jun 2017 17:37:40 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: clean up readv/writev helpers
Message-ID: <20170628163740.GI10672@ZenIV.linux.org.uk>
References: <20170527081654.15957-1-hch@lst.de>
 <20170527193239.GM390@ZenIV.linux.org.uk>
 <20170628143511.GA2359@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170628143511.GA2359@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 28, 2017 at 04:35:11PM +0200, Christoph Hellwig wrote:
> On Sat, May 27, 2017 at 08:32:39PM +0100, Al Viro wrote:
> > On Sat, May 27, 2017 at 11:16:44AM +0300, Christoph Hellwig wrote:
> > > Hi Al,
> > > 
> > > this series cleans up how we implement the various vectored read and write
> > > syscalls, as well as the internal iov_iter based APIs.  It then switches
> > > nfsd to use vfs_iter_read/write which cleans up nfsd.  Note that all
> > > exportable file systems already implement ->read_iter and ->write_iter
> > > anyway.
> > 
> > 1--5 and 7--10 applied.
> 
> Yet these changes don't seem to be in linux-next.  Where did you apply
> them to?

#work.read_write, as part of #work.uaccess.  I apologize for being late
with #for-next this cycle (putting it very mildly); hopefull I'll have
something working by tonight.  Hell, quite a bit is still a tangled mess
in local queues... ;-/
