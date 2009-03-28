From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 02/47] sunrpc: add cl_private field to struct rpc_clnt
Date: Fri, 27 Mar 2009 20:05:52 -0400
Message-ID: <20090328000552.GJ18222@fieldses.org>
References: <49CC40E5.2080506@panasas.com> <1238122908-6967-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>,
	Trond Myklebust <trond@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:54987 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994AbZC1AFy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2009 20:05:54 -0400
In-Reply-To: <1238122908-6967-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 27, 2009 at 06:01:48AM +0300, Benny Halevy wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Note: the NFSv4.1 client also uses (and declares) this pointer.

OK.  Ack from trond?

--b.

> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  include/linux/sunrpc/clnt.h |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index c39a210..928c547 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -53,6 +53,7 @@ struct rpc_clnt {
>  	char			cl_pathname[30];/* Path in rpc_pipe_fs */
>  	struct vfsmount *	cl_vfsmnt;
>  	struct dentry *		cl_dentry;	/* inode */
> +	void			*cl_private;	/* private data */
>  	struct rpc_clnt *	cl_parent;	/* Points to parent of clones */
>  	struct rpc_rtt		cl_rtt_default;
>  	struct rpc_timeout	cl_timeout_default;
> -- 
> 1.6.2.1
> 
