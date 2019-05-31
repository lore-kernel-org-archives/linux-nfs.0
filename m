Return-Path: <SRS0=b6pt=T7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B180C04AB6
	for <linux-nfs@archiver.kernel.org>; Fri, 31 May 2019 13:36:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4881F24AEC
	for <linux-nfs@archiver.kernel.org>; Fri, 31 May 2019 13:36:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726330AbfEaNgu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 31 May 2019 09:36:50 -0400
Received: from fieldses.org ([173.255.197.46]:42040 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726037AbfEaNgu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 31 May 2019 09:36:50 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 9BA5E1C1B; Fri, 31 May 2019 09:36:49 -0400 (EDT)
Date:   Fri, 31 May 2019 09:36:49 -0400
From:   "J . Bruce Fields" <bfields@fieldses.org>
To:     Geert Uytterhoeven <geert+renesas@glider.be>
Cc:     Jeff Layton <jlayton@kernel.org>, Jiri Kosina <trivial@kernel.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] [trivial] nfsd: Spelling s/EACCESS/EACCES/
Message-ID: <20190531133649.GA1251@fieldses.org>
References: <20190527122132.5617-1-geert+renesas@glider.be>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527122132.5617-1-geert+renesas@glider.be>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Thanks, applying for 5.3.--b.

On Mon, May 27, 2019 at 02:21:32PM +0200, Geert Uytterhoeven wrote:
> The correct spelling is EACCES:
> 
> include/uapi/asm-generic/errno-base.h:#define EACCES 13 /* Permission denied */
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> ---
>  fs/nfsd/vfs.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index fc24ee47eab51ad4..c85783e536d595de 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -404,7 +404,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
>  	/*
>  	 * If utimes(2) and friends are called with times not NULL, we should
>  	 * not set NFSD_MAY_WRITE bit. Otherwise fh_verify->nfsd_permission
> -	 * will return EACCESS, when the caller's effective UID does not match
> +	 * will return EACCES, when the caller's effective UID does not match
>  	 * the owner of the file, and the caller is not privileged. In this
>  	 * situation, we should return EPERM(notify_change will return this).
>  	 */
> -- 
> 2.17.1
