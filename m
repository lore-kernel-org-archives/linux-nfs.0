Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59029 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932139Ab2HURrn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 13:47:43 -0400
Date: Tue, 21 Aug 2012 13:47:40 -0400
To: Jeff Layton <jlayton@redhat.com>
Cc: Sven Geggus <lists@fuchsschwanzdomain.de>, linux-nfs@vger.kernel.org
Subject: Re: NFS4ERR_DELAY
Message-ID: <20120821174740.GC15958@fieldses.org>
References: <k0vgkt$mm0$1@ultimate100.geggus.net>
 <k0vjq7$o7l$1@ultimate100.geggus.net>
 <20120821064100.701ec6e9@corrin.poochiereds.net>
 <k100a0$sm1$1@ultimate100.geggus.net>
 <20120821090706.3833fdf6@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120821090706.3833fdf6@corrin.poochiereds.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 21, 2012 at 09:07:06AM -0400, Jeff Layton wrote:
> On Tue, 21 Aug 2012 12:52:16 +0000 (UTC)
> Sven Geggus <lists@fuchsschwanzdomain.de> wrote:
> > The NFS-server is providing the home for the user on both machines.
> > 
> > The ssh is now getting delayed for up to 1 minute because the NFS server
> > does not allow for the .Xauthority file to be deleted immediately.
> > 
> > It is probably worth to mention, that I'm currently experimenting with
> > btrfs on the server. Is there a chance that this bug will disapper when I
> > change the underlaying filesystem of the server to ext4?
> > 
> > Sven
> > 
> 
> You asked for hints on how to debug it, and I gave one. The server will
> often return NFS4ERR_DELAY when it's waiting for a delegation recall to
> complete. I'd make sure that that's all working as expected.

Yep.  There's a recent regression which could cause this; could you try:

	https://lkml.org/lkml/2012/8/16/531

?

--b.
