Return-Path: <SRS0=iDPq=RH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D9A5C43381
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 16:47:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2AFE8206B6
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 16:47:27 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726181AbfCDQr0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Mar 2019 11:47:26 -0500
Received: from fieldses.org ([173.255.197.46]:39004 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726063AbfCDQr0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Mar 2019 11:47:26 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id C7F6649A; Mon,  4 Mar 2019 11:47:25 -0500 (EST)
Date:   Mon, 4 Mar 2019 11:47:25 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     NeilBrown <neilb@suse.com>
Cc:     Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix memory corruption caused by readdir
Message-ID: <20190304164725.GE13690@fieldses.org>
References: <87lg1vs5eh.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lg1vs5eh.fsf@notabene.neil.brown.name>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Mar 04, 2019 at 02:08:22PM +1100, NeilBrown wrote:
> (Note that the commit hash in the Fixes tag is from the 'history'
>  tree - this bug predates git).
> Fixes: eb229d253e6c ("[PATCH] kNFSd: fix two xdr-encode bugs for readdirplus reply")

It'd be nice to provide a URL for that.  The one I originally cloned one
seems to have disappeared.

> Cc: stable@vger.kernel.org (v2.6.12+)
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> Can I still get extra credit for fixing a bug that is 14.5 years old, if
> I'm the one who introduced it?

Good grief, yes!  Great fix.  Is that a record?

And how did it go undetected so long, and what caused it to surface just
now?

I once thought about converting this over to the xdr_stream api that
NFSv4 uses to hide the page-crossing logic now.  But I think it's better
to leave it alone.

--b.

> 
>  fs/nfsd/nfs3proc.c | 16 ++++++++++++++--
>  fs/nfsd/nfs3xdr.c  |  1 +
>  2 files changed, 15 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
> index 9eb8086ea841..c9cf46e0c040 100644
> --- a/fs/nfsd/nfs3proc.c
> +++ b/fs/nfsd/nfs3proc.c
> @@ -463,8 +463,19 @@ nfsd3_proc_readdir(struct svc_rqst *rqstp)
>  					&resp->common, nfs3svc_encode_entry);
>  	memcpy(resp->verf, argp->verf, 8);
>  	resp->count = resp->buffer - argp->buffer;
> -	if (resp->offset)
> -		xdr_encode_hyper(resp->offset, argp->cookie);
> +	if (resp->offset) {
> +		loff_t offset = argp->cookie;
> +
> +		if (unlikely(resp->offset1)) {
> +			/* we ended up with offset on a page boundary */
> +			*resp->offset = htonl(offset >> 32);
> +			*resp->offset1 = htonl(offset & 0xffffffff);
> +			resp->offset1 = NULL;
> +		} else {
> +			xdr_encode_hyper(resp->offset, offset);
> +		}
> +		resp->offset = NULL;
> +	}
>  
>  	RETURN_STATUS(nfserr);
>  }
> @@ -533,6 +544,7 @@ nfsd3_proc_readdirplus(struct svc_rqst *rqstp)
>  		} else {
>  			xdr_encode_hyper(resp->offset, offset);
>  		}
> +		resp->offset = NULL;
>  	}
>  
>  	RETURN_STATUS(nfserr);
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index 9b973f4f7d01..83919116d5cb 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -921,6 +921,7 @@ encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
>  		} else {
>  			xdr_encode_hyper(cd->offset, offset64);
>  		}
> +		cd->offset = NULL;
>  	}
>  
>  	/*
> -- 
> 2.14.0.rc0.dirty
> 


