Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33509 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751704AbdEQMrN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 17 May 2017 08:47:13 -0400
Received: by mail-pf0-f196.google.com with SMTP id f27so1656175pfe.0
        for <linux-nfs@vger.kernel.org>; Wed, 17 May 2017 05:47:13 -0700 (PDT)
Date: Wed, 17 May 2017 20:47:10 +0800
From: Eryu Guan <guaneryu@gmail.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Trond.Myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] NFS fix COMMIT after COPY
Message-ID: <20170517124710.GJ1946@eguan.usersys.redhat.com>
References: <20170516160015.20582-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170516160015.20582-1-kolga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 16, 2017 at 12:00:15PM -0400, Olga Kornievskaia wrote:
> Fix a typo in the commit e092693443b995c8e3a565a73b5fdb05f1260f9b
> "NFS append COMMIT after synchronous COPY"
> 
> Reported-by: Eryu Guan <eguan@redhat.com>
> Fixes: e092693443b ("NFS append COMMIT after synchronous COPY")
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>

Thanks! This did fix the hang for me.

Tested-by: Eryu Guan <eguan@redhat.com>

> ---
>  fs/nfs/nfs42proc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> index 929d09a..319a47d 100644
> --- a/fs/nfs/nfs42proc.c
> +++ b/fs/nfs/nfs42proc.c
> @@ -177,7 +177,7 @@ static ssize_t _nfs42_proc_copy(struct file *src,
>  	if (status)
>  		goto out;
>  
> -	if (!nfs_write_verifier_cmp(&res->write_res.verifier.verifier,
> +	if (nfs_write_verifier_cmp(&res->write_res.verifier.verifier,
>  				    &res->commit_res.verf->verifier)) {
>  		status = -EAGAIN;
>  		goto out;
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
