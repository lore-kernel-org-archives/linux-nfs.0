Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33326 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752767AbdGLOwH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jul 2017 10:52:07 -0400
Received: by mail-it0-f65.google.com with SMTP id 188so2337351itx.0
        for <linux-nfs@vger.kernel.org>; Wed, 12 Jul 2017 07:52:07 -0700 (PDT)
Subject: Re: [RFC v3 14/42] NFS if we got partial copy ignore errors
To: Olga Kornievskaia <kolga@netapp.com>,
        Trond.Myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
References: <20170711164416.1982-1-kolga@netapp.com>
 <20170711164416.1982-15-kolga@netapp.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <910cad89-5ca7-4ebd-97b0-fe96284aebc7@gmail.com>
Date: Wed, 12 Jul 2017 10:52:04 -0400
MIME-Version: 1.0
In-Reply-To: <20170711164416.1982-15-kolga@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On 07/11/2017 12:43 PM, Olga Kornievskaia wrote:
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/nfs42proc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> index dba2b62..dfd43bc 100644
> --- a/fs/nfs/nfs42proc.c
> +++ b/fs/nfs/nfs42proc.c
> @@ -179,7 +179,8 @@ static int handle_async_copy(struct nfs42_copy_res *res,
>  out:
>  	*ret_count = copy->count;
>  	memcpy(&res->write_res.verifier, &copy->verf, sizeof(copy->verf));
> -	status = -copy->error;
> +	if (copy->count <= 0)
> +		status = -copy->error;

This is a pretty small change.  Can you squash this patch into patch 8
("NFS add support for asynchronous COPY") that way the code is correct from
the time it's added?

Thanks,
Anna

>  
>  	kfree(copy);
>  	return status;
> 
