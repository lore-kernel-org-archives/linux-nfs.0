Return-Path: <SRS0=hL3P=2J=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25B0BC43603
	for <linux-nfs@archiver.kernel.org>; Thu, 19 Dec 2019 22:46:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F1A5C24676
	for <linux-nfs@archiver.kernel.org>; Thu, 19 Dec 2019 22:46:22 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726930AbfLSWqW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 19 Dec 2019 17:46:22 -0500
Received: from fieldses.org ([173.255.197.46]:38796 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726830AbfLSWqW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Dec 2019 17:46:22 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 2237A1C7C; Thu, 19 Dec 2019 17:46:22 -0500 (EST)
Date:   Thu, 19 Dec 2019 17:46:22 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Aditya Pakki <pakki001@umn.edu>
Cc:     kjlu@umn.edu, Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: remove unnecessary assertion in nfsd4_encode_replay
Message-ID: <20191219224622.GF12026@fieldses.org>
References: <20191217225048.3411-1-pakki001@umn.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191217225048.3411-1-pakki001@umn.edu>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Thanks, applying.--b.

On Tue, Dec 17, 2019 at 04:50:47PM -0600, Aditya Pakki wrote:
> The replay variable is set in the only caller of nfsd4_encode_replay.
> The assertion is unnecessary and the patch removes this check.
> 
> Signed-off-by: Aditya Pakki <pakki001@umn.edu>
> ---
>  fs/nfsd/nfs4xdr.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index d2dc4c0e22e8..fb2433676376 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -4500,8 +4500,6 @@ nfsd4_encode_replay(struct xdr_stream *xdr, struct nfsd4_op *op)
>  	__be32 *p;
>  	struct nfs4_replay *rp = op->replay;
>  
> -	BUG_ON(!rp);
> -
>  	p = xdr_reserve_space(xdr, 8 + rp->rp_buflen);
>  	if (!p) {
>  		WARN_ON_ONCE(1);
> -- 
> 2.20.1
