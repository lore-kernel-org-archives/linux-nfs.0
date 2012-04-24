Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34642 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757282Ab2DXWDw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 18:03:52 -0400
Date: Tue, 24 Apr 2012 18:03:50 -0400
To: Neil Brown <neilb@suse.de>
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/6] v4set_root: force "fsid=0" for all exports of '/'
Message-ID: <20120424220350.GB26073@fieldses.org>
References: <20120424054003.20130.16209.stgit@notabene.brown>
 <20120424054638.20130.5981.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120424054638.20130.5981.stgit@notabene.brown>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 24, 2012 at 03:46:38PM +1000, Neil Brown wrote:
> When "fsid=0" is not explicitly given in /etc/exports,
> v4set_root creates a pseudo (NFSEXP_V4ROOT) export for '/'
> with fsid 0 so that an NFSv4 client can find the root.
> 
> However if '/' is explicitly exported to the client, then that
> explicit export must be used, and it will not have fsid=0.
> So we must impose fsid=0 on all exports of '/'.
> Without this, if '/' is exported to a client, that client will
> not be able to mount '/' with NFSv4.

I'd also like to teach the kernel to do lookups of "/" when it wants the
pseudoroot, and then try searching for an fsid=0 export only if "/"
doesn't work.  Long term I'd rather not have the reliance on the fsid=0
convention.  (Though maybe I'm being silly, as we're likely stuck with
it.)

Anyway, I'm fine with this patch regardless.

--b.

> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
> 
>  utils/mountd/v4root.c |    7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
> index 81f813b..b4fdcce 100644
> --- a/utils/mountd/v4root.c
> +++ b/utils/mountd/v4root.c
> @@ -192,6 +192,13 @@ v4root_set()
>  				 */
>  				continue;
>  
> +			if (strcmp(exp->m_export.e_path, "/") == 0 &&
> +			    !(exp->m_export.e_flags & NFSEXP_FSID)) {
> +				/* Force '/' to be exported as fsid == 0*/
> +				exp->m_export.e_flags |= NFSEXP_FSID;
> +				exp->m_export.e_fsid = 0;
> +			}
> +
>  			v4root_add_parents(exp);
>  			/* XXX: error handling! */
>  		}
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
