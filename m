Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:53148 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054Ab0LWUHi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Dec 2010 15:07:38 -0500
Subject: Re: [PATCH 3/5] NFS: Add secinfo procedure
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4D1272B7.2020806@netapp.com>
Date: Thu, 23 Dec 2010 15:07:29 -0500
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <76208ECE-9DEB-48DE-A4E9-672EEBC7594C@oracle.com>
References: <4D1272B7.2020806@netapp.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 22, 2010, at 4:50 PM, Bryan Schumaker wrote:

> 
> This patch adds the nfs4 operation secinfo as a
> valid nfs rpc operation.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
> fs/nfs/nfs3proc.c       |    1 +
> fs/nfs/nfs4proc.c       |   35 +++++++++++++
> fs/nfs/nfs4xdr.c        |  129 +++++++++++++++++++++++++++++++++++++++++++++++
> fs/nfs/proc.c           |    1 +
> include/linux/nfs4.h    |    1 +
> include/linux/nfs_xdr.h |   34 ++++++++++++
> 6 files changed, 201 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
> index 2b0e7c8..1237e04 100644
> --- a/fs/nfs/nfs3proc.c
> +++ b/fs/nfs/nfs3proc.c
> @@ -885,4 +885,5 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
> 	.lock		= nfs3_proc_lock,
> 	.clear_acl_cache = nfs3_forget_cached_acls,
> 	.close_context	= nfs_close_context,
> +	.secinfo	= NULL,
> };

I believe the practice of setting global constant function pointer fields such as this one to NULL is frowned upon.  C ensures that's their default value.

> diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
> index 504dd25..36f482c 100644
> --- a/fs/nfs/proc.c
> +++ b/fs/nfs/proc.c
> @@ -740,4 +740,5 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
> 	.lock		= nfs_proc_lock,
> 	.lock_check_bounds = nfs_lock_check_bounds,
> 	.close_context	= nfs_close_context,
> +	.secinfo	= NULL,
> };

Ditto.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




