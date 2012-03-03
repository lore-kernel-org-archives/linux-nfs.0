Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52954 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753254Ab2CCOJl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 3 Mar 2012 09:09:41 -0500
Message-ID: <4F522623.3070709@netapp.com>
Date: Sat, 03 Mar 2012 09:09:39 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@netapp.com>
CC: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] NFSv4: parse and display server implementation ids
References: <1329510026-30403-1-git-send-email-dros@netapp.com> <1329510026-30403-3-git-send-email-dros@netapp.com>
In-Reply-To: <1329510026-30403-3-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Dros,

On 02/17/2012 03:20 PM, Weston Andros Adamson wrote:

> Shows the implementation ids in /proc/self/mountstats.  This doesn't break
> the nfs-utils mountstats tool.
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
>  fs/nfs/client.c           |    1 +
>  fs/nfs/nfs4proc.c         |   21 +++++++++++++++++++++
>  fs/nfs/nfs4xdr.c          |   42 +++++++++++++++++++++++++++++++++++++-----
>  fs/nfs/super.c            |    8 ++++++++
>  include/linux/nfs_fs_sb.h |    2 ++
>  include/linux/nfs_xdr.h   |   15 +++++++--------
>  6 files changed, 76 insertions(+), 13 deletions(-)
> 

<snip>

> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index d05024a..5462225 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -809,6 +809,14 @@ static int nfs_show_stats(struct seq_file *m, struct dentry *root)
>  
>  	seq_printf(m, "\n\tage:\t%lu", (jiffies - nfss->mount_time) / HZ);
>  
> +	if (nfss->nfs_client && nfss->nfs_client->impl_id) {
> +		struct nfs41_impl_id *impl_id = nfss->nfs_client->impl_id;


"struct nfs41_impl_id" is only defined when CONFIG_NFS_V4_1 is enabled, so if I compile without NFS 4.1 enabled I get this error:

  CC [M]  fs/nfs/super.o
/home/bjschuma/linux/modules/fs/nfs/super.c: In function 'nfs_show_stats':
/home/bjschuma/linux/modules/fs/nfs/super.c:843:14: error: dereferencing pointer to incomplete type
/home/bjschuma/linux/modules/fs/nfs/super.c:843:29: error: dereferencing pointer to incomplete type
/home/bjschuma/linux/modules/fs/nfs/super.c:844:14: error: dereferencing pointer to incomplete type
/home/bjschuma/linux/modules/fs/nfs/super.c:844:37: error: dereferencing pointer to incomplete type
make[3]: *** [fs/nfs/super.o] Error 1

- Bryan

> +		seq_printf(m, "\n\timpl_id:\tname='%s',domain='%s',"
> +			   "date='%llu,%u'",
> +			   impl_id->name, impl_id->domain,
> +			   impl_id->date.seconds, impl_id->date.nseconds);
> +	}
> +
>  	seq_printf(m, "\n\tcaps:\t");
>  	seq_printf(m, "caps=0x%x", nfss->caps);
>  	seq_printf(m, ",wtmult=%u", nfss->wtmult);
