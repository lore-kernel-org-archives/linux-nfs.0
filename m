Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43803 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751817Ab0KASfH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Nov 2010 14:35:07 -0400
Date: Mon, 1 Nov 2010 14:34:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Arnd Bergmann <arnd@arndb.de>, Bryan Schumaker <bjschuma@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/4] locks: fix leaks on setlease errors
Message-ID: <20101101183457.GF2340@fieldses.org>
References: <20101030212500.GE480@fieldses.org>
 <1288474276-14288-2-git-send-email-bfields@redhat.com>
 <20101031111057.GA23760@infradead.org>
 <20101101172440.GC2340@fieldses.org>
 <20101101174122.GA12604@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101101174122.GA12604@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Nov 01, 2010 at 01:41:22PM -0400, Christoph Hellwig wrote:
> On Mon, Nov 01, 2010 at 01:24:40PM -0400, J. Bruce Fields wrote:
> > I also have patches that get rid of fl_release_private, fl_mylease, and
> > (almost done) fl_change.
> > 
> > Unless you've a better suggestion I'll probably send them out for review
> > and then queue them up with other nfsd changes for 2.6.38.
> 
> Sounds good.  I was also wondering if we can get rid of ->setlease
> entirely.  The file_lock_operations should be enough abstraction to
> reject the leases in theory, but I need to look into it a bit more.

Note that cifs has a real lease operation now.  No idea how it works or
if it's really correct.

--b.
