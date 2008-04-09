From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: reconnect_path() breaks NFS server causing occasional EACCES
Date: Wed, 9 Apr 2008 16:11:24 +0200
Message-ID: <20080409141124.GA30864@janus>
References: <20080404102449.GA10209@janus> <20080407184346.GF3305@fieldses.org> <20080409133639.GA9588@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Frank van Maarseveen <frankvm@frankvm.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>,
	Neil Brown <neilb@suse.de>
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:47747 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750702AbYDIOL0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Apr 2008 10:11:26 -0400
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

The server exhibits non-posix behavior only occasionally and particularly
this "randomness" is bad. Random failure once every few days is hard to
figure out.

Whether we want to be posix compliant with directory handles is a separate
issue but I think we should. And we (mostly) are.

The proposed patch fixes the linux NFS server behavior to be consistent
over reboots and high memory pressure. It's not a security issue so I
don't see a downside.

-- 
Frank
