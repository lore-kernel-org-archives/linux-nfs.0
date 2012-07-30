Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54038 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754408Ab2G3U7w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jul 2012 16:59:52 -0400
Date: Mon, 30 Jul 2012 16:59:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpc.gssd: don't call poll() twice a second
Message-ID: <20120730205949.GA21730@fieldses.org>
References: <20120727210247.GC6388@fieldses.org>
 <20120727230853.GA2707@umich.edu>
 <20120729174839.GK6388@fieldses.org>
 <5015C2AA.9020608@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5015C2AA.9020608@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 29, 2012 at 07:09:30PM -0400, Steve Dickson wrote:
> 
> 
> On 07/29/2012 01:48 PM, J. Bruce Fields wrote:
> > On Fri, Jul 27, 2012 at 07:08:53PM -0400, Jim Rees wrote:
> >> J. Bruce Fields wrote:
> >>
> >>   +	if (1 != write(pipefd[1], "!", 1))
> >>   +		printerr(2, "weird; maybe an interrupt?");
> >>
> >> Use Yoda conditions must we?
> > 
> > Yeah, yeah.  How about:
> > 
> > 	 static void something_changed(void)
> > 	 {
> > 	-	if (1 != write(pipefd[1], "!", 1))
> > 	-		printerr(2, "weird; maybe an interrupt?");
> > 	+	if (write(pipefd[1], "!", 1) != 1)
> > 	+		printerr(0, "%s writing to pipe", strerror(errno));
> > 	 }
> >  
> > ?
> Better... IMHO..  but what's going to mean when we see that in some log?

Beats me.

--b.
