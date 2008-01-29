From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: atimes not updated over NFS
Date: Tue, 29 Jan 2008 15:09:01 -0500
Message-ID: <20080129200901.GI28032@fieldses.org>
References: <20080121210230.GA22046@janus> <20080121210925.GQ17468@fieldses.org> <20080122171717.GD24697@fieldses.org> <20080129025940.GI16785@fieldses.org> <20080129041411.GC1190@fieldses.org> <20080129083402.GN15220@kernel.dk> <20080129182721.GB28032@fieldses.org> <20080129183042.GH15220@kernel.dk> <20080129194508.GG28032@fieldses.org> <20080129195155.GS15220@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Andre Majorel <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>, linux-nfs@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33026 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750815AbYA2UJQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jan 2008 15:09:16 -0500
In-Reply-To: <20080129195155.GS15220@kernel.dk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 29, 2008 at 08:51:55PM +0100, Jens Axboe wrote:
> On Tue, Jan 29 2008, J. Bruce Fields wrote:
> > Hm.  It's still missing a case.  I've confirmed that the following fixes
> > the problem.  (Or maybe it would be better to have them "goto" a common
> > out with the file_accessed() check?)
> 
> Indeed it is, insert standard disclaimer here on the evil of multiple
> returns. So can we agree that this then fixes both cases?

Yep, thanks!  And I ran one more test just to make sure.  Looks fine.

--b.
> 
> diff --git a/fs/splice.c b/fs/splice.c
> index 0a0b79b..1577a73 100644
> --- a/fs/splice.c
> +++ b/fs/splice.c
> @@ -1031,7 +1031,11 @@ ssize_t splice_direct_to_actor(struct file *in, struct splice_desc *sd,
>  			goto out_release;
>  	}
>  
> +done:
>  	pipe->nrbufs = pipe->curbuf = 0;
> +	if (bytes > 0)
> +		file_accessed(in);
> +
>  	return bytes;
>  
>  out_release:
> @@ -1047,16 +1051,11 @@ out_release:
>  			buf->ops = NULL;
>  		}
>  	}
> -	pipe->nrbufs = pipe->curbuf = 0;
> -
> -	/*
> -	 * If we transferred some data, return the number of bytes:
> -	 */
> -	if (bytes > 0)
> -		return bytes;
>  
> -	return ret;
> +	if (!bytes)
> +		bytes = ret;
>  
> +	goto done;
>  }
>  EXPORT_SYMBOL(splice_direct_to_actor);
>  
> 
> -- 
> Jens Axboe
> 
