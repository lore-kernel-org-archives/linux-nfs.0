Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:34394 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755152AbdELSb3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 14:31:29 -0400
Received: by mail-qk0-f178.google.com with SMTP id k74so54847392qke.1
        for <linux-nfs@vger.kernel.org>; Fri, 12 May 2017 11:31:28 -0700 (PDT)
Message-ID: <1494613886.4227.6.camel@redhat.com>
Subject: Re: [PATCH 18/33] nfsd4: const-ify nfs_cb_version4
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@lst.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Date: Fri, 12 May 2017 14:31:26 -0400
In-Reply-To: <20170512161701.22468-19-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
         <20170512161701.22468-19-hch@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-05-12 at 18:16 +0200, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/nfs4callback.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index ac10f78c0fb3..b45083c0f9ae 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -706,7 +706,7 @@ static const struct rpc_procinfo nfs4_cb_procedures[] = {
>  };
>  
>  static unsigned int nfs4_cb_counts[ARRAY_SIZE(nfs4_cb_procedures)];
> -static struct rpc_version nfs_cb_version4 = {
> +static const struct rpc_version nfs_cb_version4 = {
>  /*
>   * Note on the callback rpc program version number: despite language in rfc
>   * 5661 section 18.36.3 requiring servers to use 4 in this field, the

Reviewed-by: Jeff Layton <jlayton@redhat.com>
