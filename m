Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44767 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754689Ab2DPT6S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Apr 2012 15:58:18 -0400
Date: Mon, 16 Apr 2012 15:58:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: include cld.h in the headers_install target
Message-ID: <20120416195818.GA17415@fieldses.org>
References: <1334592422-26567-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1334592422-26567-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 16, 2012 at 12:07:02PM -0400, Jeff Layton wrote:
> The cld.h file contains the definition of the upcall format to talk
> with nfsdcld. When I added the file though, I neglected to add it
> to the headers-y target, so make headers_install wasn't installing it.

OK, thanks.  I do have one 3.4 bugfix to send in, so I'll throw this in
with that and send a pull request tomorrow.--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  include/linux/nfsd/Kbuild |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/nfsd/Kbuild b/include/linux/nfsd/Kbuild
> index b8d4001..5b7d84a 100644
> --- a/include/linux/nfsd/Kbuild
> +++ b/include/linux/nfsd/Kbuild
> @@ -1,3 +1,4 @@
> +header-y += cld.h
>  header-y += debug.h
>  header-y += export.h
>  header-y += nfsfh.h
> -- 
> 1.7.7.6
> 
