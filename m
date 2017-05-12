Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:34754 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755287AbdELSZF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 14:25:05 -0400
Received: by mail-qt0-f178.google.com with SMTP id l7so12724185qte.1
        for <linux-nfs@vger.kernel.org>; Fri, 12 May 2017 11:25:05 -0700 (PDT)
Message-ID: <1494613503.4227.4.camel@redhat.com>
Subject: Re: [PATCH 16/33] nfs: use ARRAY_SIZE() in the nfsacl_version3
 declaration
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@lst.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Date: Fri, 12 May 2017 14:25:03 -0400
In-Reply-To: <20170512161701.22468-17-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
         <20170512161701.22468-17-hch@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-05-12 at 18:16 +0200, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/nfs3xdr.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
> index a017ec5c7a9d..85ff1187e637 100644
> --- a/fs/nfs/nfs3xdr.c
> +++ b/fs/nfs/nfs3xdr.c
> @@ -2611,8 +2611,7 @@ static struct rpc_procinfo	nfs3_acl_procedures[] = {
>  static unsigned int nfs3_acl_counts[ARRAY_SIZE(nfs3_acl_procedures)];
>  const struct rpc_version nfsacl_version3 = {
>  	.number			= 3,
> -	.nrprocs		= sizeof(nfs3_acl_procedures)/
> -				  sizeof(nfs3_acl_procedures[0]),
> +	.nrprocs		= ARRAY_SIZE(nfs3_acl_procedures),
>  	.procs			= nfs3_acl_procedures,
>  	.counts			= nfs3_acl_counts,
>  };

Reviewed-by: Jeff Layton <jlayton@redhat.com>
