Return-Path: <SRS0=3/9x=RL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 576BAC43381
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Mar 2019 19:29:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 281CA20857
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Mar 2019 19:29:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726484AbfCHT3r (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Mar 2019 14:29:47 -0500
Received: from fieldses.org ([173.255.197.46]:45044 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726422AbfCHT3r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Mar 2019 14:29:47 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 0ACCD1C82; Fri,  8 Mar 2019 14:29:47 -0500 (EST)
Date:   Fri, 8 Mar 2019 14:29:47 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     NeilBrown <neilb@suse.com>
Cc:     Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: allow nfsv3 readdir request to be larger.
Message-ID: <20190308192947.GA27011@fieldses.org>
References: <87lg1vs5eh.fsf@notabene.neil.brown.name>
 <20190304164725.GE13690@fieldses.org>
 <877ederyjm.fsf@notabene.neil.brown.name>
 <20190305214212.GC27437@fieldses.org>
 <87y35rr52t.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87y35rr52t.fsf@notabene.neil.brown.name>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Thanks!  Applied.

On Thu, Mar 07, 2019 at 09:49:46AM +1100, NeilBrown wrote:
> 
> nfsd currently reports the NFSv4 dtpref FSINFO parameter

(Just changed NFSv4 here to NFSv3.)--b.

> to be PAGE_SIZE, so NFS clients will typically ask for one
> page of directory entries at a time.  This is needlessly restrictive
> as nfsd can handle larger replies easily.
> 
> Also, a READDIR request (but not a READDIRPLUS request) has the count
> size clipped to PAGE_SIE, again unnecessary.
> 
> This patch lifts these limits so that larger readdir requests can be
> used.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/nfsd/nfs3proc.c | 2 +-
>  fs/nfsd/nfs3xdr.c  | 4 +++-
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
> index c9cf46e0c040..8f933e84cec1 100644
> --- a/fs/nfsd/nfs3proc.c
> +++ b/fs/nfsd/nfs3proc.c
> @@ -588,7 +588,7 @@ nfsd3_proc_fsinfo(struct svc_rqst *rqstp)
>  	resp->f_wtmax  = max_blocksize;
>  	resp->f_wtpref = max_blocksize;
>  	resp->f_wtmult = PAGE_SIZE;
> -	resp->f_dtpref = PAGE_SIZE;
> +	resp->f_dtpref = max_blocksize;
>  	resp->f_maxfilesize = ~(u32) 0;
>  	resp->f_properties = NFS3_FSF_DEFAULT;
>  
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index 83919116d5cb..93fea246f676 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -573,6 +573,8 @@ int
>  nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p)
>  {
>  	struct nfsd3_readdirargs *args = rqstp->rq_argp;
> +	u32 max_blocksize = svc_max_payload(rqstp);
> +
>  	p = decode_fh(p, &args->fh);
>  	if (!p)
>  		return 0;
> @@ -580,7 +582,7 @@ nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p)
>  	args->verf   = p; p += 2;
>  	args->dircount = ~0;
>  	args->count  = ntohl(*p++);
> -	args->count  = min_t(u32, args->count, PAGE_SIZE);
> +	args->count  = min_t(u32, args->count, max_blocksize);
>  	args->buffer = page_address(*(rqstp->rq_next_page++));
>  
>  	return xdr_argsize_check(rqstp, p);
> -- 
> 2.14.0.rc0.dirty
> 


