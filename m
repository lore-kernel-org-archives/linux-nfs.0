Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:33350 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725Ab1DOENT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Apr 2011 00:13:19 -0400
Date: Fri, 15 Apr 2011 00:13:14 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org, pbadari@us.ibm.com,
        chuck.lever@oracle.com
Subject: Re: [PATCH] BZ#694309: nfs: use unstable writes for groups of small
 DIO writes
Message-ID: <20110415041314.GA27874@infradead.org>
References: <1302785008-30477-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1302785008-30477-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Apr 14, 2011 at 08:43:28AM -0400, Jeff Layton wrote:
> Currently, the client uses FILE_SYNC whenever it's writing less than or
> equal data to the wsize with O_DIRECT. This is a problem though if we
> have a bunch of small iovec's batched up in a single writev call. The
> client will iterate over them and do a single FILE_SYNC WRITE for each.
> 
> Instead, change the code to do unstable writes when we'll need to do
> multiple WRITE RPC's in order to satisfy the request. While we're at
> it, optimize away the allocation of commit_data when we aren't going
> to use it anyway.
> 
> I tested this with a program that allocates 256 page-sized and aligned
> chunks of data into an array of iovecs, opens a file with O_DIRECT, and
> then passes that into a writev call 128 times. Without this patch, it
> took 5m16s to run on my (admittedly crappy) test rig. With this patch,
> it finished in 7.5s.
> 
> Trond, would it be reasonable to take this patch as a stopgap measure
> until your overhaul of the O_DIRECT code is finished?

To me your patch looks like a good quick fix for this issue.  I'm
not actually sure how Trond's re-architecture is supposed to look like
given that pagecache writeback and DIO writes are pretty fundamentally
driven, but I can't image a design that wouldn't allow for a similar
quirk on when to use stable writes and when not.

