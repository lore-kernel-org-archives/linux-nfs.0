Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43574 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751373Ab3KRRBl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Nov 2013 12:01:41 -0500
Date: Mon, 18 Nov 2013 12:01:32 -0500
To: Christoph Hellwig <hch@infradead.org>
Cc: Albert Fluegel <af@muc.de>, linux-nfs@vger.kernel.org
Subject: Re: Bugs / Patch in nfsd
Message-ID: <20131118170132.GD3203@fieldses.org>
References: <20131118124406.GA46678@colin.muc.de>
 <20131118130026.GA4153@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131118130026.GA4153@infradead.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 18, 2013 at 05:00:26AM -0800, Christoph Hellwig wrote:
> On Mon, Nov 18, 2013 at 01:44:06PM +0100, Albert Fluegel wrote:
> >  	*p++ = htonl(nfs3_ftypes[(stat->mode & S_IFMT) >> 12]);
> > -	*p++ = htonl((u32) stat->mode);
> > +	*p++ = htonl((u32) (stat->mode & (S_IRWXU | S_IRWXG | S_IRWXO | S_ISUID | S_ISGID | S_ISVTX)));
> 
> Should be S_IALLUGO instead of manually repeating the flags.  While this
> is a good practice and I'm in favour of it, I'd love to know what other
> value you see in the mode field.  Do you have a wireshark dump or a
> trace?

Just tracing a v3 mount I can confirm that S_IFDIR (0x4000, 040000)
gets set in GETATTR replies.

Which definitely looks wrong.  But we've been doing this forever (as far
as I can see nfs3xdr.c got added in 2.1.32, and the code was the same
way there), so I wonder if there's any undocumented lore about use of
these high bits.

Also if a client's actually behaving differently depending on how those
high bits are set, that might be worth reporting to the client
implementers, as it may represent an unintentional failure to sanitize
the returned bits.

Anyway, absent objections my default is to queue this up for 3.14 (using
S_IALLUGO).

--b.
