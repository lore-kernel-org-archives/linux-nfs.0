Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47301 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755273Ab1EXPQO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 11:16:14 -0400
Message-ID: <4DDBCBBA.5040700@panasas.com>
Date: Tue, 24 May 2011 18:16:10 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCHSET v6 0/26] pnfs for 2.6.40
References: <4DDA8C3D.5080706@panasas.com> <4DDAAC64.6050807@panasas.com>
In-Reply-To: <4DDAAC64.6050807@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-05-23 21:50, Boaz Harrosh wrote:
> On 05/23/2011 07:33 PM, Benny Halevy wrote:
> Benny Hi
> 
> I have a problem that the default wsize is very small 64K and
> I get small IOs. I found that the governing member right now
> is NFS_SERVER()->wsize
> 
> I did the below hack on My current code, but you took that away
> from me.
> 
> diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
> index ec40408..f7b09e1 100644
> --- a/fs/nfs/objlayout/objlayout.c
> +++ b/fs/nfs/objlayout/objlayout.c
> +	server->wsize = ((PAGE_SIZE - sizeof(struct bio)) / sizeof(struct bio_vec))
> +			* PAGE_SIZE * 2;
>  
> -	dprintk("%s: Return data=%p\n", __func__, data);
> +	dprintk("%s: Return data=%p wsize=0x%x\n", __func__, data, server->wsize);
>  	return 0;
>  }
> 
> What do you want that we do to replace this. The default 64K is to small.
> I don't mind that for pnfs it will be ~0 and the pg_test() will test
> for maxc_size as well. But then we'll also need the current size or the
> start_index
> 
> Boaz

How about this approach?

git diff --stat -p -M
 fs/nfs/pagelist.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index c80add6..3f5508b 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -293,7 +293,7 @@ static int nfs_pageio_do_add_request(struct
nfs_pageio_descriptor *desc,
 		if (desc->pg_bsize < PAGE_SIZE)
 			return 0;
 		newlen += desc->pg_count;
-		if (newlen > desc->pg_bsize)
+		if (newlen > desc->pg_bsize && !desc->pg_test)
 			return 0;
 		prev = nfs_list_entry(desc->pg_list.prev);
 		if (!nfs_can_coalesce_requests(prev, req, desc))
