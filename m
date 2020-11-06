Return-Path: <SRS0=hdvH=EM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 583A6C2D0A3
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Nov 2020 22:28:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E70FE2071A
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Nov 2020 22:28:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="wrUNvOc3"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728755AbgKFW2Y (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 6 Nov 2020 17:28:24 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:34762 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729247AbgKFW2X (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Nov 2020 17:28:23 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id B995EC0613CF
        for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2020 14:28:22 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id 6964F6191; Fri,  6 Nov 2020 17:28:22 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 6964F6191
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1604701702;
        bh=SdETyRDru9VYUMDOupbouJfa75TtDzmmSf5uu43Duv0=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=wrUNvOc3SYwwUb4kQPur30MW5lp61th689TzoTKlSIYBG8LbgGZn/SjS+UomhYaeC
         X884c4dNNBqG49UktEOPrgEjI6FWnbG86hcxSy4mzOO5y2oiQa5CX8/an+Q4UK8nbC
         qWdfiPsijcpMMjZvowd+/9JC0pE5PHYHlXu0IoH4=
Date:   Fri, 6 Nov 2020 17:28:22 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: MKNOD should return NFSERR_BADTYPE instead of
 NFSERR_INVAL
Message-ID: <20201106222822.GH26028@fieldses.org>
References: <160346407256.79082.7549570817445542217.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <160346407256.79082.7549570817445542217.stgit@klimt.1015granger.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

And, applied.  I should see about sending a pull request Monday....--b.

On Fri, Oct 23, 2020 at 10:41:12AM -0400, Chuck Lever wrote:
> A late paragraph of RFC 1813 Section 3.3.11 states:
> 
> | ... if the server does not support the target type or the
> | target type is illegal, the error, NFS3ERR_BADTYPE, should
> | be returned. Note that NF3REG, NF3DIR, and NF3LNK are
> | illegal types for MKNOD.
> 
> The Linux NFS server incorrectly returns NFSERR_INVAL in these
> cases.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfsd/nfs3proc.c |    6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
> index 14468613d150..a633044b0dc1 100644
> --- a/fs/nfsd/nfs3proc.c
> +++ b/fs/nfsd/nfs3proc.c
> @@ -316,10 +316,6 @@ nfsd3_proc_mknod(struct svc_rqst *rqstp)
>  	fh_copy(&resp->dirfh, &argp->fh);
>  	fh_init(&resp->fh, NFS3_FHSIZE);
>  
> -	if (argp->ftype == 0 || argp->ftype >= NF3BAD) {
> -		resp->status = nfserr_inval;
> -		goto out;
> -	}
>  	if (argp->ftype == NF3CHR || argp->ftype == NF3BLK) {
>  		rdev = MKDEV(argp->major, argp->minor);
>  		if (MAJOR(rdev) != argp->major ||
> @@ -328,7 +324,7 @@ nfsd3_proc_mknod(struct svc_rqst *rqstp)
>  			goto out;
>  		}
>  	} else if (argp->ftype != NF3SOCK && argp->ftype != NF3FIFO) {
> -		resp->status = nfserr_inval;
> +		resp->status = nfserr_badtype;
>  		goto out;
>  	}
>  
> 
