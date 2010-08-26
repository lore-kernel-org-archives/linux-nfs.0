Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:33931 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947Ab0HZKpm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Aug 2010 06:45:42 -0400
Date: Thu, 26 Aug 2010 06:45:41 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Harry Edmon <harry@uw.edu>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: Odd problem with Stale NFS file handle - NFS v3 server under
 2.6.35.x
Message-ID: <20100826104541.GA23693@infradead.org>
References: <4C7407D2.1040304@uw.edu>
 <20100825105320.GA17190@infradead.org>
 <4C75948D.4040400@uw.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C75948D.4040400@uw.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Aug 25, 2010 at 03:09:17PM -0700, Harry Edmon wrote:
> Christoph Hellwig wrote:
> >Are you running xfs on this machine?  If so can you please try
> >this patch:
> >
> >	http://git.kernel.org/?p=linux/kernel/git/dgc/xfsdev.git;a=commitdiff;h=4536f2ad8b330453d7ebec0746c4374eadd649b1
> >
> This looks very good so far.   I have been running it for 7 hours
> with no problems.  That is much longer than I was able to run before
> the patch.
> 
> I notice that this patch (along with other xfs patches) has been
> submitted for 2.6.36-rc3.   Do you plan to try to get this into
> 2.6.35.5+ (2.6.35.4 is already in testing)?

The commit was Cc'ed to the stable team, so it's expect that they will
pick it up.

