Return-Path: <SRS0=1lTg=VO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 909EEC7618F
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Jul 2019 22:15:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 667EF20651
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Jul 2019 22:15:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728113AbfGQWPH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 17 Jul 2019 18:15:07 -0400
Received: from fieldses.org ([173.255.197.46]:59400 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726917AbfGQWPH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 Jul 2019 18:15:07 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 3A6041C95; Wed, 17 Jul 2019 18:15:07 -0400 (EDT)
Date:   Wed, 17 Jul 2019 18:15:07 -0400
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 4/8] NFSD add COPY_NOTIFY operation
Message-ID: <20190717221507.GP24608@fieldses.org>
References: <20190708192352.12614-1-olga.kornievskaia@gmail.com>
 <20190708192352.12614-5-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190708192352.12614-5-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Jul 08, 2019 at 03:23:48PM -0400, Olga Kornievskaia wrote:
> From: Olga Kornievskaia <kolga@netapp.com>
> 
> Introducing the COPY_NOTIFY operation.
> 
> Create a new unique stateid that will keep track of the copy
> state and the upcoming READs that will use that stateid. Keep
> it in the list associated with parent stateid.
> 
> Return single netaddr to advertise to the copy.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfsd/nfs4proc.c  | 71 +++++++++++++++++++++++++++++++++++----
>  fs/nfsd/nfs4state.c | 64 +++++++++++++++++++++++++++++++----
>  fs/nfsd/nfs4xdr.c   | 97 +++++++++++++++++++++++++++++++++++++++++++++++++++--
>  fs/nfsd/state.h     | 18 ++++++++--
>  fs/nfsd/xdr4.h      | 13 +++++++
>  5 files changed, 247 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index cfd8767..c39fa72 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -37,6 +37,7 @@
>  #include <linux/falloc.h>
>  #include <linux/slab.h>
>  #include <linux/kthread.h>
> +#include <linux/sunrpc/addr.h>
>  
>  #include "idmap.h"
>  #include "cache.h"
> @@ -1033,7 +1034,8 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
>  static __be32
>  nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		  stateid_t *src_stateid, struct file **src,
> -		  stateid_t *dst_stateid, struct file **dst)
> +		  stateid_t *dst_stateid, struct file **dst,
> +		  struct nfs4_stid **stid)
>  {
>  	__be32 status;
>  
> @@ -1050,7 +1052,7 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
>  
>  	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
>  					    dst_stateid, WR_STATE, dst, NULL,
> -					    NULL);
> +					    stid);

Doesn't this belong with the previous patch?

--b.
