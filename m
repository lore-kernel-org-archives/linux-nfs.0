Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:43437 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755248AbbHYQFf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2015 12:05:35 -0400
Subject: Re: [PATCH RFC 04/11] nfs42: remove unused declaration
To: Peng Tao <tao.peng@primarydata.com>, <linux-nfs@vger.kernel.org>
References: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
 <1440516829-116041-5-git-send-email-tao.peng@primarydata.com>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>, <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <55DC924A.7050702@Netapp.com>
Date: Tue, 25 Aug 2015 12:05:30 -0400
MIME-Version: 1.0
In-Reply-To: <1440516829-116041-5-git-send-email-tao.peng@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tao,

On 08/25/2015 11:33 AM, Peng Tao wrote:
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> ---
>  fs/nfs/nfs42.h | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
> index ff66ae7..814c125 100644
> --- a/fs/nfs/nfs42.h
> +++ b/fs/nfs/nfs42.h
> @@ -17,7 +17,5 @@ int nfs42_proc_deallocate(struct file *, loff_t, loff_t);
>  loff_t nfs42_proc_llseek(struct file *, loff_t, int);
>  int nfs42_proc_layoutstats_generic(struct nfs_server *,
>  				   struct nfs42_layoutstat_data *);
> -/* nfs4.2xdr.h */
> -extern struct rpc_procinfo nfs4_2_procedures[];

Same thing here.  Maybe submit both patches together as a cleanup patch series?

Thanks,
Anna

>  
>  #endif /* __LINUX_FS_NFS_NFS4_2_H */
> 

