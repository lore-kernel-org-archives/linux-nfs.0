Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:33124 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751836Ab3KPTPg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Nov 2013 14:15:36 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Weston Andros Adamson" <dros@netapp.com>
Subject: Re: [PATCH] NFSv4: fix getacl ERANGE for some ACL buffer sizes
Date: Sat, 16 Nov 2013 19:15:35 +0000
Message-ID: <E1BD19D4-40C6-456D-A6EE-73D3BA2F1E4B@netapp.com>
References: <1384527728-1487-1-git-send-email-dros@netapp.com>
In-Reply-To: <1384527728-1487-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm going to rethink this, as the server may return arbitrarily long bitmaps.

I'll probably just always allocate an extra page...

-dros

> On Nov 15, 2013, at 10:02 AM, "Weston Andros Adamson" <dros@netapp.com> wrote:
> 
> Besides storing the ACL buffer, the getacl decoder uses the inline
> pages for the attr bitmap and buffer length. __nfs4_get_acl_uncached
> must allocate enough page space for all of the data to be decoded.
> 
> This bug results in getxattr() returning ERANGE when the attr buffer
> length is close enough to the nearest PAGE_SIZE multiple that adding
> the extra bytes leaves too little room for the ACL buffer.
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> fs/nfs/nfs4proc.c | 7 ++++++-
> 1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 5ab33c0..006cba1 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4453,7 +4453,12 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
>        .rpc_argp = &args,
>        .rpc_resp = &res,
>    };
> -    unsigned int npages = DIV_ROUND_UP(buflen, PAGE_SIZE);
> +    /*
> +     * extra space needed for attr bitmap and length in getacl decoder.
> +     * 1 word for bitmap len, 3 words for bitmaps and 1 word for attr len.
> +     */
> +    unsigned int preamble_len = 20;
> +    unsigned int npages = DIV_ROUND_UP(preamble_len + buflen, PAGE_SIZE);
>    int ret = -ENOMEM, i;
> 
>    /* As long as we're doing a round trip to the server anyway,
> -- 
> 1.8.3.1 (Apple Git-46)
> 
