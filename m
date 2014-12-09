Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35186 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751362AbaLITYK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 14:24:10 -0500
Date: Tue, 9 Dec 2014 14:24:07 -0500
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org, dros@netapp.com
Subject: Re: [PATCH 1/2] nfsd4: fix xdr4 inclusion of escaped char
Message-ID: <20141209192406.GN20526@fieldses.org>
References: <cover.1417985975.git.bcodding@redhat.com>
 <8ec7a52c7b6b5287e8bd87503834bae46377f3ef.1417985975.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8ec7a52c7b6b5287e8bd87503834bae46377f3ef.1417985975.git.bcodding@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 07, 2014 at 04:05:47PM -0500, Benjamin Coddington wrote:
> Fix a bug where nfsd4_encode_components_esc() includes the esc_end char as
> an additional string encoding.

Has it had this problem since the escaping was added by e7a0444aef4a
"mfsd" add addr escaping to fs_location hosts"?  I wonder why it wasn't
noticed then.  Maybe the client always just chooses the first entry and
doesn't care if there's a second entry for a host named "]".

--b.

> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfsd/nfs4xdr.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index eeea7a9..6c92a53 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1795,6 +1795,9 @@ static __be32 nfsd4_encode_components_esc(struct xdr_stream *xdr, char sep,
>  		}
>  		else
>  			end++;
> +		if (found_esc)
> +			end = next;
> +
>  		str = end;
>  	}
>  	pathlen = htonl(xdr->buf->len - pathlen_offset);
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
