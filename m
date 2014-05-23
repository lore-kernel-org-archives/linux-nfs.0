Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f44.google.com ([209.85.219.44]:49613 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbaEWBV5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 May 2014 21:21:57 -0400
Received: by mail-oa0-f44.google.com with SMTP id o6so4925048oag.31
        for <linux-nfs@vger.kernel.org>; Thu, 22 May 2014 18:21:57 -0700 (PDT)
Message-ID: <537EA2A2.2040907@gmail.com>
Date: Fri, 23 May 2014 09:21:38 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
CC: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 01/52] nfsd4: READ, READDIR, etc., are idempotent
References: <1400787148-25941-1-git-send-email-bfields@redhat.com> <1400787148-25941-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-2-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/23/2014 03:31, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> OP_MODIFIES_SOMETHING flags operations that we should be careful not to
> initiate without being sure we have the buffer space to encode a reply.
> 
> None of these ops fall into that category.
> 
> We could probably remove a few more, but this isn't a very important
> problem at least for ops whose reply size is easy to estimate.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfs4proc.c | 13 +++----------
>  1 file changed, 3 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index ac83778..4c4cd96 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1665,38 +1665,31 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  	[OP_PUTFH] = {
>  		.op_func = (nfsd4op_func)nfsd4_putfh,
>  		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
> -				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING
> -				| OP_CLEAR_STATEID,
> +				| OP_IS_PUTFH_LIKE | OP_CLEAR_STATEID,
>  		.op_name = "OP_PUTFH",
>  		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
>  	},
>  	[OP_PUTPUBFH] = {
>  		.op_func = (nfsd4op_func)nfsd4_putrootfh,
>  		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
> -				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING
> -				| OP_CLEAR_STATEID,
> +				| OP_IS_PUTFH_LIKE | OP_CLEAR_STATEID,
>  		.op_name = "OP_PUTPUBFH",
>  		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
>  	},
>  	[OP_PUTROOTFH] = {
>  		.op_func = (nfsd4op_func)nfsd4_putrootfh,
>  		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
> -				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING
> -				| OP_CLEAR_STATEID,
> +				| OP_IS_PUTFH_LIKE | OP_CLEAR_STATEID,
>  		.op_name = "OP_PUTROOTFH",
>  		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
>  	},
>  	[OP_READ] = {
>  		.op_func = (nfsd4op_func)nfsd4_read,
> -		.op_flags = OP_MODIFIES_SOMETHING,
> -		.op_name = "OP_READ",

Should not delete op_name.

>  		.op_rsize_bop = (nfsd4op_rsize)nfsd4_read_rsize,
>  		.op_get_currentstateid = (stateid_getter)nfsd4_get_readstateid,
>  	},
>  	[OP_READDIR] = {
>  		.op_func = (nfsd4op_func)nfsd4_readdir,
> -		.op_flags = OP_MODIFIES_SOMETHING,
> -		.op_name = "OP_READDIR",

Same as above.

Because "[PATCH 03/52] nfsd4: fill in some missing op_name's" re-adds them.

thanks,
Kinglong Mee
