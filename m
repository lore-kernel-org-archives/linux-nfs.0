From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS+GD issues on kernel 2.6.24, but not 2.6.22
Date: Thu, 15 May 2008 13:04:43 -0700
Message-ID: <1210881883.7796.3.camel@localhost>
References: <2473b43f0805150706g5be9918cu3c77d9135cded912@mail.gmail.com>
	 <20080515084610.4e5161bc@tupile.poochiereds.net>
	 <2473b43f0805150855o59a14e34h82b20f847c53f392@mail.gmail.com>
	 <1210876652.17301.3.camel@localhost>
	 <2473b43f0805151300q19d23bddy612e1978864669de@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: Adam Olsen <arolsen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:43167 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752861AbYEOUEt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 May 2008 16:04:49 -0400
In-Reply-To: <2473b43f0805151300q19d23bddy612e1978864669de-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-05-15 at 14:00 -0600, Adam Olsen wrote:
> On Thu, May 15, 2008 at 12:37 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> >  Looks as if you've got a 32-bit application that doesn't like 64-bit
> >  inode numbers. Try booting with the kernel parameter
> >  'nfs.enable_ino64=0'.
> 
> Sorry if this is a dumb question, but is that going to hurt me in the
> long run?  This filesystem has the capability of being rather huge
> (it's currently at 27TB).

Some applications (e.g. backup apps) may gripe at the fact that the
inode numbers are no longer guaranteed to be unique, but the only
alternative solution to that would be to convert your apps to be 64-bit
safe.

  Trond

