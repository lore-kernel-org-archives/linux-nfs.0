Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:38480 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751167AbdGLOGi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jul 2017 10:06:38 -0400
Received: by mail-it0-f54.google.com with SMTP id k192so13605720ith.1
        for <linux-nfs@vger.kernel.org>; Wed, 12 Jul 2017 07:06:37 -0700 (PDT)
Subject: Re: [RFC v3 11/42] NFS test for intra vs inter COPY
To: Olga Kornievskaia <kolga@netapp.com>,
        Trond.Myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
References: <20170711164416.1982-1-kolga@netapp.com>
 <20170711164416.1982-12-kolga@netapp.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <bd9f4062-6c6d-d310-b4b9-812c1a1628b9@gmail.com>
Date: Wed, 12 Jul 2017 10:06:35 -0400
MIME-Version: 1.0
In-Reply-To: <20170711164416.1982-12-kolga@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On 07/11/2017 12:43 PM, Olga Kornievskaia wrote:
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/internal.h | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 3e24392..dcbcffb 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -7,6 +7,7 @@
>  #include <linux/security.h>
>  #include <linux/crc32.h>
>  #include <linux/nfs_page.h>
> +#include <linux/sunrpc/addr.h>
>  
>  #define NFS_MS_MASK (MS_RDONLY|MS_NOSUID|MS_NODEV|MS_NOEXEC|MS_SYNCHRONOUS)
>  
> @@ -766,3 +767,12 @@ static inline bool nfs_error_is_fatal(int err)
>  		return false;
>  	}
>  }
> +
> +static inline bool nfs42_files_from_same_server(struct file *in, struct file *out)
> +{
> +	struct nfs_client *c_in = (NFS_SERVER(file_inode(in)))->nfs_client;
> +	struct nfs_client *c_out = (NFS_SERVER(file_inode(out)))->nfs_client;
> +
> +	return rpc_cmp_addr((struct sockaddr *)&c_in->cl_addr,
> +				(struct sockaddr *)&c_out->cl_addr);
> +}

Can you move this to nfs42.h instead of internal.h?

Thanks,
Anna

> 
