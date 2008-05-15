From: Jeff Layton <jlayton@redhat.com>
Subject: Re: NFS+GD issues on kernel 2.6.24, but not 2.6.22
Date: Thu, 15 May 2008 16:49:13 -0400
Message-ID: <20080515164913.7e161c30@tupile.poochiereds.net>
References: <2473b43f0805150706g5be9918cu3c77d9135cded912@mail.gmail.com>
	<20080515084610.4e5161bc@tupile.poochiereds.net>
	<2473b43f0805150855o59a14e34h82b20f847c53f392@mail.gmail.com>
	<1210876652.17301.3.camel@localhost>
	<2473b43f0805151315m3547bc17o57ca14c46a636671@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: "Adam Olsen" <arolsen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36291 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751702AbYEOUuD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 May 2008 16:50:03 -0400
In-Reply-To: <2473b43f0805151315m3547bc17o57ca14c46a636671-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 15 May 2008 14:15:51 -0600
"Adam Olsen" <arolsen@gmail.com> wrote:

> On Thu, May 15, 2008 at 12:37 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> >  Looks as if you've got a 32-bit application that doesn't like 64-bit
> >  inode numbers. Try booting with the kernel parameter
> >  'nfs.enable_ino64=0'.
> 
> Ok, tried that.  It's still a no go.
> 

I suggest some debugging of the actual application. Everything looks
fine from a system call standpoint. You'll need to debug the
application and figure out why it's not doing what you expect.

-- 
Jeff Layton <jlayton@redhat.com>
