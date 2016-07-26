Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41020 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757109AbcGZUTs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jul 2016 16:19:48 -0400
Date: Tue, 26 Jul 2016 16:19:47 -0400
To: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
Cc: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] Prevent rqstp->rq_pages[RPCSVC_MAXPAGES] overrun
Message-ID: <20160726201947.GA8387@fieldses.org>
References: <28fb2e47-48ce-1af7-3135-15ca9b4e1726@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <28fb2e47-48ce-1af7-3135-15ca9b4e1726@jp.fujitsu.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for the report.

On Tue, Jul 26, 2016 at 11:38:11AM +0900, Seiichi Ikarashi wrote:
> If over-"RPCSVC_MAXPAGES" pages are sent from file system through pipe_buffer,
> nfsd_splice_actor() corrupts struct svc_rqst and results in kernel panic. It
> actually occurred with a parallel distributed file system. It needs boundary
> checking.

This check might be useful as defensive programming, but the bug was
elsewhere.

In theory this should be prevented by the "maxcount" calculations in
nfsd4_encode_read().

What version of the kernel did you see this happen on?  What was the
client, and what was it doing?  Any other hints on reproducing?

--b.

> 
> v2: Fix semicolon-missing bug.
> 
> Signed-off-by: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
> 
> ---
>  fs/nfsd/vfs.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 6fbd81e..43393f3 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -811,12 +811,20 @@ nfsd_splice_actor(struct pipe_inode_info *pipe, struct pipe_buffer *buf,
>  	size = sd->len;
>  
>  	if (rqstp->rq_res.page_len == 0) {
> +		if (rqstp->rq_next_page > &rqstp->rq_pages[RPCSVC_MAXPAGES-1]) {
> +			WARN_ON(1);
> +			return -ENOMEM;
> +		}
>  		get_page(page);
>  		put_page(*rqstp->rq_next_page);
>  		*(rqstp->rq_next_page++) = page;
>  		rqstp->rq_res.page_base = buf->offset;
>  		rqstp->rq_res.page_len = size;
>  	} else if (page != pp[-1]) {
> +		if (rqstp->rq_next_page > &rqstp->rq_pages[RPCSVC_MAXPAGES-1]) {
> +			WARN_ON(1);
> +			return -ENOMEM;
> +		}
>  		get_page(page);
>  		if (*rqstp->rq_next_page)
>  			put_page(*rqstp->rq_next_page);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
