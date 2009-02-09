From: Miklos Szeredi <mszeredi@suse.cz>
Subject: Re: [NLM] 2.6.27 broken
Date: Mon, 09 Feb 2009 21:18:37 +0100
Message-ID: <1234210717.4965.133.camel@tucsk>
References: <20081115132831.GA11329@janus>
	 <20081120222731.GA591@fieldses.org> <20081128112447.GA25340@janus>
	 <20081216173923.GE16388@fieldses.org> <1229456632.6023.1.camel@tucsk>
	 <20081216201610.GE18928@fieldses.org> <20090204233348.GD20917@fieldses.org>
	 <1233830829.4965.56.camel@tucsk> <20090205195203.GD9200@fieldses.org>
	 <1233919798.4965.63.camel@tucsk>  <20090209181036.GI10297@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:41579 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750751AbZBIUSk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Feb 2009 15:18:40 -0500
In-Reply-To: <20090209181036.GI10297@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-02-09 at 13:10 -0500, J. Bruce Fields wrote:
> On Fri, Feb 06, 2009 at 12:29:58PM +0100, Miklos Szeredi wrote:
> > On Thu, 2009-02-05 at 14:52 -0500, J. Bruce Fields wrote:
> > > On Thu, Feb 05, 2009 at 11:47:09AM +0100, Miklos Szeredi wrote:
> > > > But I think at least a comment in the code would be in order, or this
> > > > same mistake might be made again.  Also I think the original code flow
> > > > is somewhat illogical.
> > > 
> > > Yeah, I was literally just reverting the problematic lines of your
> > > previous commit.  I'd rather keep it that way for now, just as a clear
> > > separation between the revert/bugfix and the cleanup.
> > 
> > OK.
> > 
> > > > How about this (it's essentially the same patch just a bit rearranged,
> > > > the authorship is still yours of course ;)
> > > 
> > > ... but would happily queue up the cleanup for 2.6.30.
> > 
> > Cool.
> > 
> > > Actually, I find it strange to have just that single case which breaks,
> > > so that the code after the switch, which looks like it should be shared,
> > > actually just applies to one case.  I'd be inclined to just suck
> > > everything up to "out:" into the -EAGAIN case and then make all cases
> > > "goto out" (or, equivalently, break).
> > 
> > Yes, but it needs to be sucked into the FILE_LOCK_DEFERRED case as well.
> > It's just two lines and one of them is setting the error value, so it's
> > not real duplication.
> 
> Whoops, right, missed that; so, I'm applying the below, sending the
> fixup in now, and queuing up the cleanup for 2.6.30 (with the blame
> assigned back to you, hah--object or have me add your signed-off-by).

No objections :)

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>

BTW, one tip for stable patches: if you add a "Cc: stable@kernel.org"
line to the Signed-off-by block, then it will ease the patch's way into
the stable kernels as it will automatically be picked up by Greg's
scripts when it hits the mainline tree.

Thanks,
Miklos


