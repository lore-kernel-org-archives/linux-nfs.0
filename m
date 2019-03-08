Return-Path: <SRS0=3/9x=RL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F03DC10F09
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Mar 2019 21:10:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 693D020851
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Mar 2019 21:10:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726565AbfCHVKR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Mar 2019 16:10:17 -0500
Received: from fieldses.org ([173.255.197.46]:45212 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726298AbfCHVKR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Mar 2019 16:10:17 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 7E1FA1C82; Fri,  8 Mar 2019 16:10:16 -0500 (EST)
Date:   Fri, 8 Mar 2019 16:10:16 -0500
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org, linux-integrity@vger.kernel.org
Subject: Re: [PATCH v2 3/5] NFSD: Remove ima_file_check call
Message-ID: <20190308211016.GB27011@fieldses.org>
References: <20190307151838.11306.94183.stgit@manet.1015granger.net>
 <20190307152854.11306.84006.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190307152854.11306.84006.stgit@manet.1015granger.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Mar 07, 2019 at 10:28:54AM -0500, Chuck Lever wrote:
> The NFS server needs to allow NFS clients to perform their own
> attestation and measurement.

Can we really remove this call?

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfsd/vfs.c |    6 ------
>  1 file changed, 6 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 3c00072..524c6e5 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -802,12 +802,6 @@ static int nfsd_open_break_lease(struct inode *inode, int access)
>  		goto out_nfserr;
>  	}
>  
> -	host_err = ima_file_check(file, may_flags);
> -	if (host_err) {
> -		fput(file);
> -		goto out_nfserr;
> -	}
> -
>  	if (may_flags & NFSD_MAY_64BIT_COOKIE)
>  		file->f_mode |= FMODE_64BITHASH;
>  	else
