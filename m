Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55777 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757386Ab1KJGaN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 01:30:13 -0500
Received: by mail-fx0-f46.google.com with SMTP id n18so168697fag.19
        for <linux-nfs@vger.kernel.org>; Wed, 09 Nov 2011 22:30:12 -0800 (PST)
Message-ID: <4EBB6F71.9030603@tonian.com>
Date: Thu, 10 Nov 2011 08:30:09 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SQUASHME: Compile warning in pnfs-all-3.1-2011-10-31-1
References: <4EB82384.7080106@panasas.com>
In-Reply-To: <4EB82384.7080106@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-11-07 20:29, Boaz Harrosh wrote:
> 
> Fix this:
> fs/nfsd/nfs4pnfsd.c: In function 'cl_has_file_layout':
> fs/nfsd/nfs4pnfsd.c:1093:20: warning: unused variable 'stid' [-Wunused-variable]
> 
> Was something forgotten? or It's really not needed any longer?

It isn't needed anymore post f2ed73ef28b85cb2abc9da6ca98a03daf4b36d0d
which searches for clientid on the nfs4_file's fi_layout_states list.

Thanks!

Benny

> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfsd/nfs4pnfsd.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
> index d2860c9..ca5c18a 100644
> --- a/fs/nfsd/nfs4pnfsd.c
> +++ b/fs/nfsd/nfs4pnfsd.c
> @@ -1090,7 +1090,6 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
>  static bool
>  cl_has_file_layout(struct nfs4_client *clp, struct nfs4_file *fp, stateid_t *lsid)
>  {
> -	struct nfs4_stid *stid;
>  	struct nfs4_layout_state *ls;
>  
>  	spin_lock(&layout_lock);
