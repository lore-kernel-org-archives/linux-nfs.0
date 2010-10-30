From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: nfsd changes for 2.6.37
Date: Sat, 30 Oct 2010 23:40:48 +0200
Message-ID: <201010302340.48311.arnd@arndb.de>
References: <20101026164549.GD19445@fieldses.org> <20101027145929.GA5788@infradead.org> <20101030212500.GE480@fieldses.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Cc: Christoph Hellwig <hch@infradead.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Bryan Schumaker <bjschuma@netapp.com>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101030212500.GE480@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Saturday 30 October 2010, J. Bruce Fields wrote:
> We still need to do this part.  I just did the minimum required to fix
> the problem--I figure splitting out a separate ->delete_lease method
> (which I agree would be cleaner) could wait till the next merge window.
> 
> Patches follow, tested on top of the merge of Arnd's patches; if they
> look OK they can go in, or I can commit them on top of a few pending
> nfsd fixes and send another pull request.

All four patches look good AFAICT.

Thanks for the follow-up!

	Arnd
