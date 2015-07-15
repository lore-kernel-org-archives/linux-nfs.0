Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35113 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753754AbbGOU7w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jul 2015 16:59:52 -0400
Date: Wed, 15 Jul 2015 16:59:51 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 04/14] nfsd: Fix a memory leak of struct file_lock
Message-ID: <20150715205951.GD21669@fieldses.org>
References: <55A384B1.8030207@gmail.com>
 <55A3854B.7010805@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A3854B.7010805@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying.--b.

On Mon, Jul 13, 2015 at 05:30:51PM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4state.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index e5e14fa..998166d 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3938,6 +3938,7 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
>  	if (!filp) {
>  		/* We should always have a readable file here */
>  		WARN_ON_ONCE(1);
> +		locks_free_lock(fl);
>  		return -EBADF;
>  	}
>  	fl->fl_file = filp;
> -- 
> 2.4.3
