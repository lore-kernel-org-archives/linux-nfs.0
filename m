Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:49094 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753318AbcFQLbL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jun 2016 07:31:11 -0400
Date: Fri, 17 Jun 2016 04:31:10 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: odd sillyrename bug in 4.6 / 4.7-rc
Message-ID: <20160617113110.GA8864@infradead.org>
References: <20160616150146.GA14015@infradead.org>
 <20160616172952.GA17604@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160616172952.GA17604@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 16, 2016 at 01:29:52PM -0400, J. Bruce Fields wrote:
> On Thu, Jun 16, 2016 at 08:01:47AM -0700, Christoph Hellwig wrote:
> > I've run into an odd bug when testing the clone / reflink functionality,
> > and managed to isolate a testcase not relying on clones.  The issue is
> > that after a lot of direct I/O hitting ENOSPC on a NFS mount I run
> > into a silly rename that never gets cleaned up after cleaning up the
> > directory.
> 
> I have a redhat bug for what sounds like the same behavior.  I spent
> some time looking at it but I don't think I got anywere.
> 
> 	https://bugzilla.redhat.com/show_bug.cgi?id=1132610
> 
> (But you probably can't see that right now; I'll see if I can open it.)

I can't see it indeed.
