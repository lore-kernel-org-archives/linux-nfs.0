Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:47271 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895Ab2E1L0l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 07:26:41 -0400
Message-ID: <4FC360D2.4030006@panasas.com>
Date: Mon, 28 May 2012 14:26:10 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: <tao.peng@emc.com>, Sorin Faibish <sfaibish@emc.com>
CC: <Trond.Myklebust@netapp.com>, <bergwolf@gmail.com>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] pnfsblock: bail out unaligned DIO
References: <1338096780-2763-1-git-send-email-bergwolf@gmail.com>  <1338096780-2763-4-git-send-email-bergwolf@gmail.com> <1338136717.3044.13.camel@lade.trondhjem.org> <F19688880B763E40B28B2B462677FBF805F0BADF36@MX09A.corp.emc.com>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805F0BADF36@MX09A.corp.emc.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/28/2012 05:30 AM, tao.peng@emc.com wrote:

>> -----Original Message-----
>> From: Myklebust, Trond [mailto:Trond.Myklebust@netapp.com]

<>

>> Also, why do you consider it to be direct i/o specific? If the
>> application is using byte range locking, and the locks aren't page/block
>> aligned then you are in the same position of having to deal with partial
>> page writes even in the read/write from page cache situation.


> You are right about byte range locking + buffered IO, and it should
> be fixed in pg_test with bellow patch and it could be a stable
> candidate. 


What?? please explain. It sounds like you are saying that there is a
very *serious* bug in current block-layout.

>From my experiment I know that lots and lots of IO is done none-paged
aligned even in buffered IO. Actually NFS goes to great length not to do
the usual read-modify-write per page, but keeps the byte range that
was written per page and only RPCs the exact offset-length of the modification.
Because by definition NFS is byte aligned IO, not "blocks" or "sectors".

Please explain what happens now. Is it a data corruption? Or just
performance slowness.

I don't understand. Don't you do the proper read-copy-modify-write that's
mandated by block layout RFC? byte aligned? And what are sectors and PAGES
got to do with it? I thought all IO must be "block" aligned.

In objects-layout we have even worse alignment constrains with raid5
(stripe_size alignment). It was needed to do a (very simple BTW)
read-modify-write. Involving not just partial pages but also full pages read.
BTW we read into the page-cache the surrounding pages, so not to read them multiple
times.

> It is different from DIO case because for DIO we have to
> be sure each page is blocksize aligned. And it can't easily be done
> in pg_test because in pg_test we only have one nfs_page to test
> against.
> 

<snip>

> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index 7ae8a60..a84a0da 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -925,6 +925,18 @@ nfs4_blk_get_deviceinfo(struct nfs_server *server, const struct nfs_fh *fh,
>  	return rv;
>  }
>  
> +static bool
> +bl_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
> +	   struct nfs_page *req)
> +{
> +	/* Bail out page unligned IO */
> +	if (req->wb_offset || req->wb_pgbase ||
> +	    req->wb_bytes != PAGE_CACHE_SIZE)
> +		return false;
> +


This is very serious. Not many applications will currently pass
this test. (And hence will not do direct IO)

What happens today without this patch?

> +	return pnfs_generic_pg_test(pgio, prev, req);
> +}
> +


<>

Thanks
Boaz
