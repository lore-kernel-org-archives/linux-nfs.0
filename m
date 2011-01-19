Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29788 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752838Ab1ASXtk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jan 2011 18:49:40 -0500
Subject: Re: [PATCH] NFS: Fix "BUG at fs/aio.c:554!"
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Nick Piggin <npiggin@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wen.gang.wang@oracle.com
In-Reply-To: <AANLkTiknrso7mQbTiXNF3MLz+RPi52M1s+DV1XaxciO=@mail.gmail.com>
References: <20110119223543.30706.10304.stgit@matisse.1015granger.net>
	 <1295479517.22151.16.camel@heimdal.trondhjem.org>
	 <AANLkTikRX8nxh-gp=Fdr21dg-DLmUb2FxYXrM2A0hfN0@mail.gmail.com>
	 <1295479900.22151.19.camel@heimdal.trondhjem.org>
	 <AANLkTiknrso7mQbTiXNF3MLz+RPi52M1s+DV1XaxciO=@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 19 Jan 2011 18:49:36 -0500
Message-ID: <1295480976.22151.23.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-01-20 at 10:37 +1100, Nick Piggin wrote: 
> On Thu, Jan 20, 2011 at 10:31 AM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > On Thu, 2011-01-20 at 10:26 +1100, Nick Piggin wrote:
> >> On Thu, Jan 20, 2011 at 10:25 AM, Trond Myklebust
> 
> >> > Also, why is EIO the correct reply when no bytes were read/written? Why
> >> > shouldn't the VFS aio code be able to cope with a zero byte reply?
> >>
> >> What would it do?
> >
> > Just return that zero byte reply to userland.
> >
> > zero bytes is a valid reply for ordinary read() and write(), so why
> > should we have to do anything different for aio_read()/aio_write()?
> 
> It doesn't give userspace much to do. zero reply from read means
> EOF. Zero reply from write is pretty useless, I don't think we do it
> in the buffered write path -- we either ensure we write at least
> something or have a meaningful error to return.

zero reply from read means EOF _or_ user supplied a zero length buffer.

zero reply from write may also be useless, but it is a valid value. It
can simply mean the user supplied a zero length buffer.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

