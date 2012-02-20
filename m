Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e5.ny.us.ibm.com ([32.97.182.145]:58193 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752863Ab2BTPGT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Feb 2012 10:06:19 -0500
Received: from /spool/local
	by e5.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Mon, 20 Feb 2012 10:06:18 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 2F36738C805C
	for <linux-nfs@vger.kernel.org>; Mon, 20 Feb 2012 10:02:23 -0500 (EST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1KF2LTH287910
	for <linux-nfs@vger.kernel.org>; Mon, 20 Feb 2012 10:02:21 -0500
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1KF1iwO020641
	for <linux-nfs@vger.kernel.org>; Mon, 20 Feb 2012 08:01:45 -0700
Date: Mon, 20 Feb 2012 10:01:20 -0500
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 13/13] NFS: Request fh_expire_type attribute in "server
 caps" operation
Message-ID: <20120220150117.GA3954@Gelgoog.pok.ibm.com>
References: <20120215213336.3254.98936.stgit@ellison.1015granger.net>
 <20120215213634.3254.25758.stgit@ellison.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120215213634.3254.25758.stgit@ellison.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 15, 2012 at 04:36:34PM -0500, Chuck Lever wrote:
> The fh_expire_type file attribute is a filesystem wide attribute that
> consists of flags that indicate what characteristics file handles
> on this FSID have.
> 
> Our client won't support volatile file handles, but it should find
> out at mount time whether the server is going to play shenanighans
> with file handles during a migration.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfs/nfs4proc.c         |    1 +
>  fs/nfs/nfs4xdr.c          |   26 ++++++++++++++++++++++++++
>  include/linux/nfs_fs_sb.h |    3 +++
>  include/linux/nfs_xdr.h   |    1 +
>  4 files changed, 31 insertions(+), 0 deletions(-)
> 
<snip>
> index 6532d7b..f07d966 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -144,6 +144,9 @@ struct nfs_server {
>  	u32			acl_bitmask;	/* V4 bitmask representing the ACEs
>  						   that are supported on this
>  						   filesystem */
> +	u32			fh_expire_type;	/* V4 bitmask representing file
> +						   handle volatility type for
> +						   this filesystem */
>  	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
>  	struct rpc_wait_queue	roc_rpcwaitq;
>  	void			*pnfs_ld_data;	/* per mount point data */
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index d609631..ff74d94 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -973,6 +973,7 @@ struct nfs4_server_caps_res {
>  	u32				acl_bitmask;
>  	u32				has_links;
>  	u32				has_symlinks;
> +	u32				fh_expire_type;
>  	struct nfs4_sequence_res	seq_res;
>  };

I had a similar patch in my volatile file handle tree, 
(http://www.spinics.net/lists/linux-nfs/msg26069.html) but in my commit I used 
fs_info instead of server caps. If I remember the spec correctly, it says that
the attribute is set per file system, that's why I put it in fs_info. I'm just
curious why you used server caps, not that it really makes a difference.

-Matt Treinish


