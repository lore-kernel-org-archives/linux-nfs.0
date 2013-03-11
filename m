Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41047 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750872Ab3CKOnn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Mar 2013 10:43:43 -0400
Date: Mon, 11 Mar 2013 10:43:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: ycnian@gmail.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: rmmove unused macro in nfsv4
Message-ID: <20130311144341.GA16309@fieldses.org>
References: <1362969806-23907-1-git-send-email-ycnian@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1362969806-23907-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 11, 2013 at 10:43:26AM +0800, ycnian@gmail.com wrote:
> From: Yanchuan Nian <ycnian@gmail.com>
> 
> lk_rflags is never used anywhere, and rflags is not defined in struct
> nfsd4_lock. Very sorry for my negligence in last version. Maybe I am tired.

Applying for 3.10, thanks.--b.

> 
> Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
> ---
>  fs/nfsd/xdr4.h |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index 0889bfb..326724a 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -184,7 +184,6 @@ struct nfsd4_lock {
>  #define lk_old_lock_stateid     v.old.lock_stateid
>  #define lk_old_lock_seqid       v.old.lock_seqid
>  
> -#define lk_rflags       u.ok.rflags
>  #define lk_resp_stateid u.ok.stateid
>  #define lk_denied       u.denied
>  
> -- 
> 1.7.4.4
> 
