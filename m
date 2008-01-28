From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 020/100] nfsd: select CONFIG_PROC_FS in nfsv4 and gss server cases
Date: Mon, 28 Jan 2008 13:07:05 -0500
Message-ID: <DA5779D5-8037-4640-9571-87E041262988@oracle.com>
References: <20080125231521.GG25141@fieldses.org> <1201303040-7779-1-git-send-email-bfields@citi.umich.edu> <1201303040-7779-2-git-send-email-bfields@citi.umich.edu> <1201303040-7779-3-git-send-email-bfields@citi.umich.edu> <1201303040-7779-4-git-send-email-bfields@citi.umich.edu> <1201303040-7779-5-git-send-email-bfields@citi.umich.edu> <1201303040-7779-6-git-send-email-bfields@citi.umich.edu> <1201303040-7779-7-git-send-email-bfields@citi.umich.edu> <1201303040-7779-8-git-send-email-bfields@citi.umich.edu> <1201303040-7779-9-git-send-email-bfields@citi.umich.edu> <1201303040-7779-10-git-send-email-bfields@citi.umich.edu> <1201303040-7779-11-git-send-email-bfields@citi.umich.edu> <1201303040-7779-12-git-send-email-bfields@citi.umich.edu> <1201303040-7779-13-git-send-email-bfields@citi.umi
 ch.edu> <1201303040-7779-14-git-send-email-bfields@citi.umich.edu> <1201303040-7779-15-git-send-email-bfields@citi.umich.edu> <1201303040-7779-16-git-send-email-bfields@citi.umich.edu> <120!
 1303040-7779-17-git-send-email-bfields@citi.umich.edu> <1201303040-7779-18-git-send-email-bfields@citi.umich.edu> <1201303040-7779-19-git-send-email-bfields@citi.umich.edu> <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:27524 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909AbYA1SHm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2008 13:07:42 -0500
In-Reply-To: <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 25, 2008, at 6:16 PM, J. Bruce Fields wrote:
> The server depends on upcalls under /proc to support nfsv4 and gss.
>
> Acked-by: NeilBrown <neilb@suse.de>
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/Kconfig |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 487236c..e81fcd6 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -1679,6 +1679,8 @@ config NFSD
>  	select CRYPTO_MD5 if NFSD_V4
>  	select CRYPTO if NFSD_V4
>  	select FS_POSIX_ACL if NFSD_V4
> +	select PROC_FS if NFSD_V4
> +	select PROC_FS if SUNRPC_GSS
>  	help
>  	  If you want your Linux box to act as an NFS *server*, so that  
> other
>  	  computers on your local network which support NFS can access  
> certain

I'm no Kconfig guru... but wouldn't this be better expressed as a  
"depends" clause?

i.e. CONFIG_NFSD_V4 and SUNRPC_GSS should depend on PROC_FS --  
otherwise, someone might deselect PROC_FS, then select NFSV4 or GSS,  
and get a surprise.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
