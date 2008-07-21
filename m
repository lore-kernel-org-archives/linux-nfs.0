From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] mount: enable retry for nfs23 to set the correct
	protocol for mount.
Date: Mon, 21 Jul 2008 13:40:27 -0400
Message-ID: <1216662027.7649.15.camel@localhost>
References: <18556.40594.897682.204554@notabene.brown>
	 <76bd70e30807150811p56feb02bo6e4a366d5577b398@mail.gmail.com>
	 <18559.53893.95829.499988@notabene.brown>
	 <76bd70e30807190909n12b9f70an87ccb62198c3a7d@mail.gmail.com>
	 <18562.57287.656749.540603@notabene.brown>
	 <76bd70e30807201828t70d5b1d0m4c242c5c8864c3bb@mail.gmail.com>
	 <18563.63821.501053.402741@notabene.brown>
	 <76bd70e30807202143q51820814n5a5a0bc0976f9763@mail.gmail.com>
	 <18564.10115.809293.243948@notabene.brown>
	 <76bd70e30807210832l188bd3adl92762d5856bbaa5e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chucklever@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:45332 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751099AbYGURkd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jul 2008 13:40:33 -0400
In-Reply-To: <76bd70e30807210832l188bd3adl92762d5856bbaa5e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-07-21 at 11:32 -0400, Chuck Lever wrote:

> I will have to look at it again.  My version of this fix, at least,
> made the kernel use TCP for mountd and NFS if "proto=tcp" is
> specified, UDP for both if "proto=udp" is specified, and TCP for NFS
> and UDP for mountd if none were specified.  This is exactly how the
> legacy mount command starts off.
> 
> If Trond's version of the fix doesn't do that, then that is a behavior
> regression.

A regression w.r.t. what, exactly?

In the binary mount case, we certainly _always_ used TCP to talk to
mountd, when specifying NFS-over-TCP.

I don't remember seeing a public discussion as to why we should change
the default to using UDP when talking to mountd for the NFS-over-TCP
case, or even whether or not it is a safe to assume that we can. Will
the text mount retry using mountproto=tcp if mountproto=udp fails? If it
doesn't, then that would be a regression w.r.t. previously working
binary setups...

Trond

