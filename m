From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] nfs: avoid possible deadlock bug when setting up
 delegation.
Date: Thu, 20 May 2010 09:47:15 -0400
Message-ID: <1274363235.2949.4.camel@heimdal.trondhjem.org>
References: <20100520054216.GA27457@vmware>
	 <1274360236.2949.1.camel@heimdal.trondhjem.org>
	 <AANLkTilrfrlhyJ7G8jy6X9emrGIGnEAxFjqlYns8K0OT@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Benny Halevy <bhalevy@panasas.com>
To: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:55173 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753365Ab0ETNrU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 May 2010 09:47:20 -0400
In-Reply-To: <AANLkTilrfrlhyJ7G8jy6X9emrGIGnEAxFjqlYns8K0OT-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-05-20 at 21:20 +0800, Tao Guo wrote: 
> On Thu, May 20, 2010 at 8:57 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> > On Thu, 2010-05-20 at 13:42 +0800, Tao Guo wrote:
> >> Unlock clp->cl_lock before taking inode->i_lock when setting up
> >> delegation to avoid possible deadlock bug.
> >
> > What deadlock? inode->i_lock should always be the innermost lock, so it
> > should always be safe to take it while already holding the nfs_client
> > lock.
> here is: http://marc.info/?l=linux-nfs&m=127424502009958&w=2
> >

That would be a pnfs bug... Please fix it so that it adheres to the
locking rules in mainline.

Trond

