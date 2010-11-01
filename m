Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43744 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751931Ab0KARY7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Nov 2010 13:24:59 -0400
Date: Mon, 1 Nov 2010 13:24:40 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Arnd Bergmann <arnd@arndb.de>, Bryan Schumaker <bjschuma@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/4] locks: fix leaks on setlease errors
Message-ID: <20101101172440.GC2340@fieldses.org>
References: <20101030212500.GE480@fieldses.org>
 <1288474276-14288-2-git-send-email-bfields@redhat.com>
 <20101031111057.GA23760@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101031111057.GA23760@infradead.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Oct 31, 2010 at 07:10:57AM -0400, Christoph Hellwig wrote:
> On Sat, Oct 30, 2010 at 05:31:14PM -0400, J. Bruce Fields wrote:
> > We're depending on setlease to free the passed-in lease on failure.
> 
> But we would be much better to just free it in the caller.  I'ts much
> more natural - caller allocates, caller frees, and it's also simpler.
> 
> I'll send a patch to do so shortly, together with sorting out the
> remaining nfs4d lock_manager_operations abuses.  I think we're set with
> that for 2.6.37, the setlease split can wait once we've sorted out the
> lock freeing issue.

I also have patches that get rid of fl_release_private, fl_mylease, and
(almost done) fl_change.

Unless you've a better suggestion I'll probably send them out for review
and then queue them up with other nfsd changes for 2.6.38.

--b.
