Return-Path: <SRS0=hdvH=EM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43A00C2D0A3
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Nov 2020 22:27:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 9115320704
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Nov 2020 22:27:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="MPHv9ZNT"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728844AbgKFW14 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 6 Nov 2020 17:27:56 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:34690 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728390AbgKFW1z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Nov 2020 17:27:55 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id BFA2CC0613CF
        for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2020 14:27:55 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id F25FCABE; Fri,  6 Nov 2020 17:27:54 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org F25FCABE
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1604701674;
        bh=yvqCdACdcoXjVmZYxXMnfr4m+atzyQ0jZFYerOaAOpY=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=MPHv9ZNTwAw8HoHAI4MJHTcMJaBoVbo1C3Z9kFW552d/ctwjv2YF54A8+/duDHFZl
         O7bE7vaQWlMBN9cpKIy8NED1Z+y4MrPNCAinQAEbxAvg5RLUHb1UyvHiamZb6a7H/6
         pUteF+DDSsrfa0ywA84/JzATJslgwZkkmA7gNV+A=
Date:   Fri, 6 Nov 2020 17:27:54 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: NFSv3 PATHCONF Reply is improperly formed
Message-ID: <20201106222754.GF26028@fieldses.org>
References: <160346406185.79082.5918603581435378646.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <160346406185.79082.5918603581435378646.stgit@klimt.1015granger.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Applied, thanks.--b.

On Fri, Oct 23, 2020 at 10:41:01AM -0400, Chuck Lever wrote:
> Commit cc028a10a48c ("NFSD: Hoist status code encoding into XDR
> encoder functions") missed a spot.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfsd/nfs3xdr.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index 9c23b6acf234..2277f83da250 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -1114,6 +1114,7 @@ nfs3svc_encode_pathconfres(struct svc_rqst *rqstp, __be32 *p)
>  {
>  	struct nfsd3_pathconfres *resp = rqstp->rq_resp;
>  
> +	*p++ = resp->status;
>  	*p++ = xdr_zero;	/* no post_op_attr */
>  
>  	if (resp->status == 0) {
> 
