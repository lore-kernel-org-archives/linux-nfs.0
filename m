From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [pnfs] [PATCH 3/5] pnfsd: DLM file layout only support read iomode
 layouts
Date: Sun, 07 Feb 2010 11:26:02 +0200
Message-ID: <4B6E872A.7090304@panasas.com>
References: <1265389813-6823-1-git-send-email-andros@netapp.com>	<1265389813-6823-2-git-send-email-andros@netapp.com>	<1265389813-6823-3-git-send-email-andros@netapp.com> <1265389813-6823-4-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:48930 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751619Ab0BGJ0G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Feb 2010 04:26:06 -0500
In-Reply-To: <1265389813-6823-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/05/2010 07:10 PM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> In a DLM cluster, writing to a node other than the node where the open call
> occurred and where meta data is cached will have performance implications when
> the write causes meta data changes that need to be propagated to the open call
> node.
> 
> DlM clusters support only LAYOUTIOMODE4_READ layouts. Writes will go through
> the MDS.
> 
> Return NFS4ERR_BADIOMODE for LAYOUTGET requests with LAYOUTIOMODE4_RW iomode.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/nfs4pnfsd.c   |    2 ++
>  fs/nfsd/nfs4pnfsdlm.c |    5 +++++
>  2 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
> index 3951e02..e1ecf81 100644
> --- a/fs/nfsd/nfs4pnfsd.c
> +++ b/fs/nfsd/nfs4pnfsd.c
> @@ -881,6 +881,8 @@ nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *lgp,
>  		case -ENOENT:
>  			status = nfserr_stale;
>  			break;
> +		case nfserr_badiomode:
> +			break;

2 questions:

- Why In this patch? - The first patch already fixes up what is allowed
  and what is not. It is more clear to establish protocol in one place
  so we can review.

- Why only this one? Why not all the nfserr_xxx allowed/make-sense, in
  a layoutget operation?

In my opinion we should only allow nfserr_xxx constants and be done with it
It should not be hard to fix all users.

Boaz
>  		default:
>  			status = nfserr_layoutunavailable;
>  		}
> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
> index 293bf95..8cc7c84 100644
> --- a/fs/nfsd/nfs4pnfsdlm.c
> +++ b/fs/nfsd/nfs4pnfsdlm.c
> @@ -28,6 +28,7 @@
>  #include <linux/nfsd/nfs4layoutxdr.h>
>  
>  #include "nfsfh.h"
> +#include "nfsd.h"
>  
>  #define NFSDDBG_FACILITY                NFSDDBG_PROC
>  
> @@ -331,6 +332,10 @@ static int nfsd4_pnfs_dlm_layoutget(struct inode *inode,
>  
>  	dprintk("%s: LAYOUT_GET\n", __func__);
>  
> +	/* DLM exported file systems only support layouts for READ */
> +	if (res->lg_seg.iomode == IOMODE_RW)
> +		return nfserr_badiomode;
> +
>  	index = dlm_ino_hash(inode);
>  	dprintk("%s first stripe index %d i_ino %lu\n", __func__, index,
>  		inode->i_ino);

