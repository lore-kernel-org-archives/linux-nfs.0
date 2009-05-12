From: Christoph Hellwig <hch@infradead.org>
Subject: Re: nfsd fixes for 2.6.30
Date: Tue, 12 May 2009 16:15:26 -0400
Message-ID: <20090512201526.GA20972@infradead.org>
References: <20090512192912.GH19164@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:54405 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752916AbZELUP0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 May 2009 16:15:26 -0400
In-Reply-To: <20090512192912.GH19164@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 12, 2009 at 03:29:12PM -0400, J. Bruce Fields wrote:
> The following nfsd fixes are available from the for-2.6.30 branch at:
> 
> 	git://linux-nfs.org/~bfields/linux.git for-2.6.30
> 
> (Note: I wasn't sure of the last one, "nfsd: silence lockdep warning":
> on the one hand, it's just a warning.  On the other hand, a lot of users
> may assume it's something more serious and freak out, just because
> there's a backtrace in it.  Should this have been saved for the next
> merge window?)

I think it's fine.  For non-lockdep builds the annotation doesn't change
anything, and for lockdep builds it fixes the false positive.

