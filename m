Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 8bytes.org ([85.214.48.195]:57633 "EHLO
	h2027444.stratoserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761031Ab2FHQAe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jun 2012 12:00:34 -0400
Received: from localhost (localhost [127.0.0.1])
	by h2027444.stratoserver.net (Postfix) with SMTP id 13D6712B08E
	for <linux-nfs@vger.kernel.org>; Fri,  8 Jun 2012 18:00:32 +0200 (CEST)
Date: Fri, 8 Jun 2012 18:00:31 +0200
From: Joerg Roedel <joro@8bytes.org>
To: bjschuma@netapp.com
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Use the NFS_DEFAULT_VERSION for v2 and v3 mounts
Message-ID: <20120608160031.GY12795@8bytes.org>
References: <1339169576-27307-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1339169576-27307-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 08, 2012 at 11:32:56AM -0400, bjschuma@netapp.com wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> Older versions of nfs utils don't always pass a "vers=" mount option for
> NFS.  This chould lead to attempts at using NFS v0 due to a zeroed out
> nfs_parsed_mount_data struct.  I solve this by setting the default NFS
> version to NFS_DEFAULT_VERSION in the v2 and v3 cases (v4 has already been
> taken care of by a similar patch).
> 
> Reported-by: Joerg Roedel <joro@&bytes.org>

8bytes.org

> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfs/super.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index ff656c0..97a3b30 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1867,6 +1867,7 @@ static int nfs23_validate_mount_data(void *options,
>  	if (data == NULL)
>  		goto out_no_data;
>  
> +	args->version = NFS_DEFAULT_VERSION;
>  	switch (data->version) {
>  	case 1:
>  		data->namlen = 0;

Hmm, I still think that the revert-patch is a better solution. The
data-structure is allocated and initialized in
nfs_alloc_parsed_mount_data() so this function is the logical place to
also initialize the version-field with a meaningful value.

Regards,

	Joerg


