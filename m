Return-Path: <SRS0=PC44=YE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 548D8C47404
	for <linux-nfs@archiver.kernel.org>; Fri, 11 Oct 2019 16:49:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 32A72206CD
	for <linux-nfs@archiver.kernel.org>; Fri, 11 Oct 2019 16:49:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727125AbfJKQt2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 11 Oct 2019 12:49:28 -0400
Received: from fieldses.org ([173.255.197.46]:59046 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726728AbfJKQt2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 11 Oct 2019 12:49:28 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 4A6351C97; Fri, 11 Oct 2019 12:49:28 -0400 (EDT)
Date:   Fri, 11 Oct 2019 12:49:28 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1] nfsd: remove private bin2hex implementation
Message-ID: <20191011164928.GC19318@fieldses.org>
References: <20191011160258.8562-1-andriy.shevchenko@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191011160258.8562-1-andriy.shevchenko@linux.intel.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Thanks, applying.--b.

On Fri, Oct 11, 2019 at 07:02:58PM +0300, Andy Shevchenko wrote:
> Calling sprintf in a loop is not very efficient, and in any case,
> we already have an implementation of bin-to-hex conversion in lib/
> which we might as well use.
> 
> Note that original code used to nul-terminate the destination while
> bin2hex doesn't. That's why replace kmalloc() with kzalloc().
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
>  fs/nfsd/nfs4recover.c | 11 +++--------
>  1 file changed, 3 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index cdc75ad4438b..29dff4c6e752 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -1850,19 +1850,14 @@ nfsd4_umh_cltrack_upcall(char *cmd, char *arg, char *env0, char *env1)
>  static char *
>  bin_to_hex_dup(const unsigned char *src, int srclen)
>  {
> -	int i;
> -	char *buf, *hex;
> +	char *buf;
>  
>  	/* +1 for terminating NULL */
> -	buf = kmalloc((srclen * 2) + 1, GFP_KERNEL);
> +	buf = kzalloc((srclen * 2) + 1, GFP_KERNEL);
>  	if (!buf)
>  		return buf;
>  
> -	hex = buf;
> -	for (i = 0; i < srclen; i++) {
> -		sprintf(hex, "%2.2x", *src++);
> -		hex += 2;
> -	}
> +	bin2hex(buf, src, srclen);
>  	return buf;
>  }
>  
> -- 
> 2.23.0
