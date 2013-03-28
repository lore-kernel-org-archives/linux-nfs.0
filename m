Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34250 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757131Ab3C1QOr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Mar 2013 12:14:47 -0400
Date: Thu, 28 Mar 2013 12:14:44 -0400
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 13/14] NFSD: Server implementation of MAC Labeling
Message-ID: <20130328161444.GF7080@fieldses.org>
References: <1364478845-29796-1-git-send-email-SteveD@redhat.com>
 <1364478845-29796-14-git-send-email-SteveD@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1364478845-29796-14-git-send-email-SteveD@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 28, 2013 at 09:54:04AM -0400, Steve Dickson wrote:
> From: David Quigley <dpquigl@davequigley.com>
> 
> This patch adds the ability to encode and decode file labels on the server for
> the purpose of sending them to the client and also to process label change
> requests from the client.
> 
> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
> ---
>  fs/nfsd/nfs4proc.c |  41 +++++++++++++++++++
>  fs/nfsd/nfs4xdr.c  | 116 ++++++++++++++++++++++++++++++++++++++++++++++++++---
>  fs/nfsd/nfsd.h     |   6 ++-
>  fs/nfsd/vfs.c      |  29 ++++++++++++++
>  fs/nfsd/vfs.h      |   2 +
>  fs/nfsd/xdr4.h     |   3 ++
>  6 files changed, 191 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index ae73175..bb17589 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -42,6 +42,36 @@
>  #include "current_stateid.h"
>  #include "netns.h"
>  
> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> +#include <linux/security.h>
> +
> +static inline void
> +nfsd4_security_inode_setsecctx(struct svc_fh *resfh, struct nfs4_label *label, u32 *bmval)
> +{
> +	struct inode *inode = resfh->fh_dentry->d_inode;
> +	int status;
> +
> +	mutex_lock(&inode->i_mutex);
> +	status = security_inode_setsecctx(resfh->fh_dentry,
> +		label->label, label->len);
> +	mutex_unlock(&inode->i_mutex);
> +
> +	if (status)
> +		/*
> +		 * We should probably fail the whole open at this point,
> +		 * but we've already created or opened the file, so it's 
> +		 * too late; So this seems the least of evils:
> +		 */
> +		bmval[2] &= ~FATTR4_WORD2_SECURITY_LABEL;

Is there any way to avoid this?

How does the vfs open code handle this?  It has to be able to set a
security contexts atomically on open(O_CREAT), doesn't it?

--b.
