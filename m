From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: config delegation lease time
Date: Mon, 26 Jul 2010 13:27:05 -0400
Message-ID: <1280165225.2869.20.camel@heimdal.trondhjem.org>
References: <AANLkTikMa7FzBewHyZ=7Pxrf=EmKU3jb8y9hrO+QhfWd@mail.gmail.com>
	 <1279935504.5268.23.camel@heimdal.trondhjem.org>
	 <AANLkTikb+8LuFFDrSW5AE+ZKYuR_tP94wKb5UoJHiwro@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Yudong Gao <stgyd@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:50669 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750848Ab0GZR1K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Jul 2010 13:27:10 -0400
In-Reply-To: <AANLkTikb+8LuFFDrSW5AE+ZKYuR_tP94wKb5UoJHiwro-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

That would be the source code. I'm not aware of any other documentation
for these particular options.

Cheers
  Trond

On Mon, 2010-07-26 at 10:14 -0700, Yudong Gao wrote:
> I see. Thanks a lot for the pointer, Trond!
> 
> Is there a through document about all the available configurations?
> 
> Thanks!
> 
> best,
> 
> Yudong
> 
> On Fri, Jul 23, 2010 at 6:38 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> > On Fri, 2010-07-23 at 17:29 -0700, Yudong Gao wrote:
> >> Hi,
> >>
> >> I am trying to change the delegation lease time in NFS4.1, but I can
> >> not find any documentation talking about this.
> >>
> >> Do I need to change the source code directly to change the lease time?
> >
> > Change the contents of /proc/fs/nfsd/nfsv4leasetime on the server.
> >
> > Trond
> >
> >



