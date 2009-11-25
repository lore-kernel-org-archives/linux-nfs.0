From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 5/5] vfs: nfsctl.c unused nfsd #includes
Date: Wed, 25 Nov 2009 15:13:15 -0500
Message-ID: <20091125201315.GH32502@fieldses.org>
References: <4B0C1EB7.50508@panasas.com> <4B0C201C.4040400@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	linux-parisc <linux-parisc@vger.kernel.org>,
	sparclinux <sparclinux@vger.kernel.org>,
	linux-s390 <linux-s390@vger.kernel.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39060 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753423AbZKYUMZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Nov 2009 15:12:25 -0500
In-Reply-To: <4B0C201C.4040400@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 24, 2009 at 08:04:12PM +0200, Boaz Harrosh wrote:
> 
> Only linux/nfsd/syscall.h is actually used. Remove the
> other nfsd #includes, so they can be moved to source
> directory.

I guess I'll take this one too.

The arch-specific ones I'm assuming are someone else's problem unless I
hear otherwise.

--b.

> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfsctl.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsctl.c b/fs/nfsctl.c
> index 8f9a205..d3854d9 100644
> --- a/fs/nfsctl.c
> +++ b/fs/nfsctl.c
> @@ -7,8 +7,6 @@
>  #include <linux/types.h>
>  #include <linux/file.h>
>  #include <linux/fs.h>
> -#include <linux/sunrpc/svc.h>
> -#include <linux/nfsd/nfsd.h>
>  #include <linux/nfsd/syscall.h>
>  #include <linux/cred.h>
>  #include <linux/sched.h>
> -- 
> 1.6.5.2
> 
> 
