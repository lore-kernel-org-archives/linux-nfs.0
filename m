Return-Path: <SRS0=Htud=OG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CE93C43441
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Nov 2018 22:33:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1EF6F20851
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Nov 2018 22:33:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EF6F20851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726299AbeK1JdU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Nov 2018 04:33:20 -0500
Received: from fieldses.org ([173.255.197.46]:43630 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726277AbeK1JdU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Nov 2018 04:33:20 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id B32DE1E68; Tue, 27 Nov 2018 17:33:57 -0500 (EST)
Date:   Tue, 27 Nov 2018 17:33:57 -0500
From:   "J . Bruce Fields" <bfields@fieldses.org>
To:     Colin King <colin.king@canonical.com>
Cc:     Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: clean up indentation, increase indentation in
 switch statement
Message-ID: <20181127223357.GA15237@fieldses.org>
References: <20181103161253.3622-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181103161253.3622-1-colin.king@canonical.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Thanks, applying for 4.21.--b.

On Sat, Nov 03, 2018 at 04:12:53PM +0000, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Trivial fix to clean up indentation, add in missing tabs.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  fs/nfsd/nfs4state.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index f093fbe47133..eb129a6f9eae 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -6230,15 +6230,15 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		case NFS4_READ_LT:
>  		case NFS4_READW_LT:
>  			file_lock->fl_type = F_RDLCK;
> -		break;
> +			break;
>  		case NFS4_WRITE_LT:
>  		case NFS4_WRITEW_LT:
>  			file_lock->fl_type = F_WRLCK;
> -		break;
> +			break;
>  		default:
>  			dprintk("NFSD: nfs4_lockt: bad lock type!\n");
>  			status = nfserr_inval;
> -		goto out;
> +			goto out;
>  	}
>  
>  	lo = find_lockowner_str(cstate->clp, &lockt->lt_owner);
> -- 
> 2.19.1
