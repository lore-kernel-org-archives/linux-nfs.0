Return-Path: <SRS0=p/Fe=QB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49A74C282C3
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 00:46:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 106E5218B0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 00:46:59 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726271AbfAYAq6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 24 Jan 2019 19:46:58 -0500
Received: from fieldses.org ([173.255.197.46]:58502 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726015AbfAYAq6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 24 Jan 2019 19:46:58 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 0CE691C84; Thu, 24 Jan 2019 19:46:58 -0500 (EST)
Date:   Thu, 24 Jan 2019 19:46:58 -0500
To:     Trond Myklebust <trondmy@gmail.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: Fix error return values for
 nfsd4_clone_file_range()
Message-ID: <20190125004658.GB3953@fieldses.org>
References: <20190121205838.18680-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190121205838.18680-1-trond.myklebust@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Jan 21, 2019 at 03:58:38PM -0500, Trond Myklebust wrote:
> If the parameter 'count' is non-zero, nfsd4_clone_file_range() will
> currently clobber all errors returned by vfs_clone_file_range() and
> replace them with EINVAL.

Oops, thanks for the fix.  I'm still a little confused, though:

> 
> Fixes: 42ec3d4c0218 ("vfs: make remap_file_range functions take and...")
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> Cc: stable@vger.kernel.org # v4.20+
> ---
>  fs/nfsd/vfs.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 9824e32b2f23..7dc98e14655d 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -557,9 +557,11 @@ __be32 nfsd4_clone_file_range(struct file *src, u64 src_pos, struct file *dst,
>  	loff_t cloned;
>  
>  	cloned = vfs_clone_file_range(src, src_pos, dst, dst_pos, count, 0);
> +	if (cloned < 0)
> +		return nfserrno(cloned);
>  	if (count && cloned != count)
> -		cloned = -EINVAL;
> -	return nfserrno(cloned < 0 ? cloned : 0);
> +		return nfserrno(-EINVAL);
> +	return 0;

I still don't understand the cloned != count case.  I thought clone was
supposed to be all-or-nothing and atomic, can it really return a short
copy?  And how is that inval, shouldn't that be serverfault?

--b.

>  }
>  
>  ssize_t nfsd_copy_file_range(struct file *src, u64 src_pos, struct file *dst,
> -- 
> 2.20.1
