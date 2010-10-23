From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH -next] nfs: include ratelimit.h, fix nfs4state build
 error
Date: Sat, 23 Oct 2010 10:09:06 -0400
Message-ID: <1287842947.3022.7.camel@heimdal.trondhjem.org>
References: <20101022152350.fc79e2b9.sfr@canb.auug.org.au>
	 <20101022161852.2ef2638c.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	akpm <akpm@linux-foundation.org>, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20101022161852.2ef2638c.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-10-22 at 16:18 -0700, Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> nfs4state.c uses interfaces from ratelimit.h.  It needs to include
> that header file to fix build errors:
> 
> fs/nfs/nfs4state.c:1195: warning: type defaults to 'int' in declaration of 'DEFINE_RATELIMIT_STATE'
> fs/nfs/nfs4state.c:1195: warning: parameter names (without types) in function declaration
> fs/nfs/nfs4state.c:1195: error: invalid storage class for function 'DEFINE_RATELIMIT_STATE'
> fs/nfs/nfs4state.c:1195: error: implicit declaration of function '__ratelimit'
> fs/nfs/nfs4state.c:1195: error: '_rs' undeclared (first use in this function)
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> Cc:	Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc:	linux-nfs@vger.kernel.org
> ---
>  fs/nfs/nfs4state.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> --- linux-next-20101022.orig/fs/nfs/nfs4state.c
> +++ linux-next-20101022/fs/nfs/nfs4state.c
> @@ -46,6 +46,7 @@
>  #include <linux/kthread.h>
>  #include <linux/module.h>
>  #include <linux/random.h>
> +#include <linux/ratelimit.h>
>  #include <linux/workqueue.h>
>  #include <linux/bitops.h>
>  

That one is my fault. Sorry, and thanks Randy! I've applied the fix to
the linux-next branch...

Cheers
  Trond
