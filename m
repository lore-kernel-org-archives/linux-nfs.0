Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43460 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754593Ab2G3WKn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jul 2012 18:10:43 -0400
Date: Mon, 30 Jul 2012 18:10:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpc.gssd: don't call poll() twice a second
Message-ID: <20120730221039.GB21730@fieldses.org>
References: <20120727210247.GC6388@fieldses.org>
 <20120727230853.GA2707@umich.edu>
 <20120729174839.GK6388@fieldses.org>
 <5015C2AA.9020608@RedHat.com>
 <20120730205949.GA21730@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120730205949.GA21730@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 30, 2012 at 04:59:49PM -0400, J. Bruce Fields wrote:
> On Sun, Jul 29, 2012 at 07:09:30PM -0400, Steve Dickson wrote:
> > 
> > 
> > On 07/29/2012 01:48 PM, J. Bruce Fields wrote:
> > > On Fri, Jul 27, 2012 at 07:08:53PM -0400, Jim Rees wrote:
> > >> J. Bruce Fields wrote:
> > >>
> > >>   +	if (1 != write(pipefd[1], "!", 1))
> > >>   +		printerr(2, "weird; maybe an interrupt?");
> > >>
> > >> Use Yoda conditions must we?
> > > 
> > > Yeah, yeah.  How about:
> > > 
> > > 	 static void something_changed(void)
> > > 	 {
> > > 	-	if (1 != write(pipefd[1], "!", 1))
> > > 	-		printerr(2, "weird; maybe an interrupt?");
> > > 	+	if (write(pipefd[1], "!", 1) != 1)
> > > 	+		printerr(0, "%s writing to pipe", strerror(errno));
> > > 	 }
> > >  
> > > ?
> > Better... IMHO..  but what's going to mean when we see that in some log?
> 
> Beats me.

Looking at it a little more: actually, if gssd is slow to process these
events then in theory they could pile up, and we could eventually get
EAGAIN/WOUDBLOCK.

Which wouldn't be a problem, except that now we're modifying errno in a
signal handler.  So the signal handler should be saving and restoring
errno.

And also: I noticed one of the reasons gssd hasn't been completely
reliable for me is that we already have a printerr() in the signal
handler, and printerr() doesn't appear to be reentrant.

Eh, I'm leaning toward just using ppoll.  According to the man page that
requires kernel >= 2.6.16, glibc >= 2.4.  Is that OK?

--b.
