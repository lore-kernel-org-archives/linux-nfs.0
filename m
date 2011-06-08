Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11964 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753854Ab1FHAvZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 20:51:25 -0400
Subject: Re: [PATCH 2/3] NFS: Cleanup of the nfs_pageio code in preparation
 for a pnfs bugfix
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 07 Jun 2011 20:51:18 -0400
In-Reply-To: <4DEEC221.6040902@panasas.com>
References: <1307399551-17489-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1307399551-17489-2-git-send-email-Trond.Myklebust@netapp.com>
	 <4DEEC221.6040902@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1307494278.12587.1.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-06-07 at 20:28 -0400, Benny Halevy wrote: 
> On 2011-06-06 18:32, Trond Myklebust wrote:
> > We need to ensure that the layouts are set up before we can decide to
> > coalesce requests. To do so, we want to further split up the struct
> > nfs_pageio_descriptor operations into an initialisation callback, a
> > coalescing test callback, and a 'do i/o' callback.
> > 
> > This patch cleans up the existing callback methods before adding the
> > 'initialisation' callback.
> > 
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > +
> >  static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
> >  				  struct inode *inode, int ioflags)
> >  {
> >  	size_t wsize = NFS_SERVER(inode)->wsize;
> > +	const struct nfs_pageio_ops *ops;
> > +	ops = pnfs_get_write_ops(inode);
> > +	if (ops == NULL)
> > +		ops = &nfs_pageio_write_ops;
> >  
> > -	if (wsize < PAGE_CACHE_SIZE)
> > -		nfs_pageio_init(pgio, inode, nfs_flush_multi, wsize, ioflags);
> > -	else
> > -		nfs_pageio_init(pgio, inode, nfs_flush_one, wsize, ioflags);
> > +	nfs_pageio_init(pgio, inode, &nfs_pageio_write_ops, wsize, ioflags);
> 
> Trond, this should be:
> 	nfs_pageio_init(pgio, inode, ops, wsize, ioflags);
> 
> Benny

Yep. Fixed in the patch...

Thanks!
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

