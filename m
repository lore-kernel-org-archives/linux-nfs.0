Return-Path: <SRS0=hAdq=OX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C986C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Dec 2018 14:45:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 226FC20675
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Dec 2018 14:45:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729808AbeLNOpd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 Dec 2018 09:45:33 -0500
Received: from fieldses.org ([173.255.197.46]:38478 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729691AbeLNOpd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Dec 2018 09:45:33 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 33F4A1C27; Fri, 14 Dec 2018 09:45:33 -0500 (EST)
Date:   Fri, 14 Dec 2018 09:45:33 -0500
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] NFSD remove OP_CACHEME from 4.2 op_flags
Message-ID: <20181214144533.GA8696@fieldses.org>
References: <20181204190921.61662-1-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204190921.61662-1-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Thanks, applying for 4.21.--b.

On Tue, Dec 04, 2018 at 02:09:21PM -0500, Olga Kornievskaia wrote:
> From: Olga Kornievskaia <kolga@netapp.com>
> 
> OP_CACHEME is only for the 4.0 operations.
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfsd/nfs4proc.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 238c4b7..60c4650 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -3010,25 +3010,25 @@ static inline u32 nfsd4_seek_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>  	/* NFSv4.2 operations */
>  	[OP_ALLOCATE] = {
>  		.op_func = nfsd4_allocate,
> -		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
> +		.op_flags = OP_MODIFIES_SOMETHING,
>  		.op_name = "OP_ALLOCATE",
>  		.op_rsize_bop = nfsd4_only_status_rsize,
>  	},
>  	[OP_DEALLOCATE] = {
>  		.op_func = nfsd4_deallocate,
> -		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
> +		.op_flags = OP_MODIFIES_SOMETHING,
>  		.op_name = "OP_DEALLOCATE",
>  		.op_rsize_bop = nfsd4_only_status_rsize,
>  	},
>  	[OP_CLONE] = {
>  		.op_func = nfsd4_clone,
> -		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
> +		.op_flags = OP_MODIFIES_SOMETHING,
>  		.op_name = "OP_CLONE",
>  		.op_rsize_bop = nfsd4_only_status_rsize,
>  	},
>  	[OP_COPY] = {
>  		.op_func = nfsd4_copy,
> -		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
> +		.op_flags = OP_MODIFIES_SOMETHING,
>  		.op_name = "OP_COPY",
>  		.op_rsize_bop = nfsd4_copy_rsize,
>  	},
> -- 
> 1.8.3.1
