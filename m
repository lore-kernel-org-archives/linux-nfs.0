From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS v3 cached directory content out of sync
Date: Tue, 25 Aug 2009 15:12:19 -0400
Message-ID: <1251227539.25372.35.camel@heimdal.trondhjem.org>
References: <d4098e2f0908211122y5d024dd1sd2f80356749315cc@mail.gmail.com>
	 <1250880591.27154.18.camel@heimdal.trondhjem.org>
	 <d4098e2f0908211208j55dee16fy146ddb8de81d8722@mail.gmail.com>
	 <1250962724.8143.29.camel@heimdal.trondhjem.org>
	 <d4098e2f0908221628kfa208c5wa3367f8fbde1c1c9@mail.gmail.com>
	 <d4098e2f0908240332k55ff2789r9aaa17cb5cd99cdf@mail.gmail.com>
	 <1251115893.6325.23.camel@heimdal.trondhjem.org>
	 <d4098e2f0908250901y359e51cewb1e22e7193922c52@mail.gmail.com>
	 <1251226809.25372.29.camel@heimdal.trondhjem.org>
	 <d4098e2f0908251206o34590902u9a69aed32142d67e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Stefan Egli <stefan.egli@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:56299 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751081AbZHYTMT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2009 15:12:19 -0400
In-Reply-To: <d4098e2f0908251206o34590902u9a69aed32142d67e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-08-25 at 21:06 +0200, Stefan Egli wrote:
> On Tue, Aug 25, 2009 at 9:00 PM, Trond Myklebust wrote:
> > Yes. The NFS client will cache mtime whether or not you do an 'ls'. I
> > suspect the only reason for the 'ls' in that launchpad bug report, is to
> > force an mtime update (and to fill the readdir cache).
> 
> Ok, interesting. I guess though that 'something' needs to read at least
> a file in that particular directory for the directory content to be
> cached, right? (i.e. either an 'ls' or some create/delete of a file?)

Every time you use a filename, the act of looking up that name is
cached. The parent directory's mtime is also cached. If it changes, then
the cached lookup is invalidated. If not, then the cached lookup is
assumed still valid (since the directory contents are not supposed to
have changed).


