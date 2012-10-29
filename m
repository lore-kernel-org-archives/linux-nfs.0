Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43971 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933435Ab2J2WJz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Oct 2012 18:09:55 -0400
Date: Mon, 29 Oct 2012 18:09:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
Message-ID: <20121029220952.GA25655@fieldses.org>
References: <k6ebva$1kf$1@ultimate100.geggus.net>
 <20121026171549.GA11806@fieldses.org>
 <20121029094038.GA14836@geggus.net>
 <20121029150203.GB9502@fieldses.org>
 <20121029163323.GA24345@geggus.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121029163323.GA24345@geggus.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 29, 2012 at 05:33:23PM +0100, Sven Geggus wrote:
> J. Bruce Fields schrieb am Montag, den 29. Oktober um 16:02 Uhr:
> 
> > Re-adding linux-nfs to cc
> 
> OK
> 
> > I don't understand why the server is dropping requests instead of
> > returning errors.  I actually would have expected it to return BADVERF
> > to the DESTROY request and then accept the PUTROOTFH normally, which
> > might have allowed the mount to succeed despite the bizarre rpc.gssd
> > behavior.
> 
> Hm rpc.gssd is the one from debian nfs-utils 1.2.6 looking at their custom
> patches inside the debian package there is nothing which could cause this.
> 
> > I'd be curious to understand what changed on the server to make a
> > difference. 
> 
> Nothing but the kernel. I'm currently dual booting either 3.5.7 or 3.6.3
> vanilla kernels on the same system.
> 
> > Looking at a network trace from a successful mount with 3.5.7 might be
> > useful.
> 
> attached.

Thanks!

The sequence of events is pretty much what I described for the "bad"
trace, except that PUTROOTFH gets a succesful reply.

One other odd difference: in the "bad" case, the timing is a little
different: the socket gssd created doesn't get shut down in the same
way, and the PUTROOTFH comes more quickly on the heels of the FIN.
Which shouldn't make a difference.

Hm.

--b.
