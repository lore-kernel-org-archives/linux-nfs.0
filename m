From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: reconnect_path() breaks NFS server causing occasional EACCES
Date: Wed, 9 Apr 2008 12:24:46 -0400
Message-ID: <20080409162446.GD32475@fieldses.org>
References: <20080404102449.GA10209@janus> <20080407184346.GF3305@fieldses.org> <20080409133639.GA9588@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>,
	Neil Brown <neilb@suse.de>
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60533 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758617AbYDIQYu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Apr 2008 12:24:50 -0400
In-Reply-To: <20080409133639.GA9588@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 09, 2008 at 03:36:39PM +0200, Christoph Hellwig wrote:
> On Mon, Apr 07, 2008 at 02:43:46PM -0400, J. Bruce Fields wrote:
> > Anyone who depends on the "x" bit to control access to objects in an
> > nfs-exported filesystem is already in trouble.  We could do so for
> > directories (at the expense of non-posix-like behavior such as what
> > you've seen), but we probably can't for files.  So I'm inclined to think
> > this is the right thing to do.
> > 
> > The "DON'T USE THIS FUNCTION EVER, thanks." suggests we should at least
> > consult the person who added that comment (cc'd) before adding a call to
> > lookup_one_noperm().  (And if we decide to do this, we should make a
> > note of this in that comment.)
> 
> That function really shouldn't be used and we should obey the x bit.
> And yes, due to NFSs staleless file handles this will lead to non-posix
> behaviour which is expected.  The same will happen with other nfs
> servers aswell.

Any references for that behavior?  Well, we can do some tests, I guess.

--b.
