From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH -mmotm] nfs/cache_lib: fix sunrpc struct build error
Date: Fri, 21 Aug 2009 13:51:12 -0400
Message-ID: <1250877072.27154.10.camel@heimdal.trondhjem.org>
References: <200908210222.n7L2Musb015815@imap1.linux-foundation.org>
	 <20090821095756.390c102e.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	akpm <akpm@linux-foundation.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16637 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932472AbZHURvM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Aug 2009 13:51:12 -0400
In-Reply-To: <20090821095756.390c102e.randy.dunlap@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-08-21 at 09:57 -0700, Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Add header file for struct delayed_work:
> 
> In file included from fs/nfs/cache_lib.c:14:
> include/linux/sunrpc/rpc_pipe_fs.h:35: error: field 'queue_timeout' has incomplete type
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  include/linux/sunrpc/rpc_pipe_fs.h |    2 ++
>  1 file changed, 2 insertions(+)
> 
> --- mmotm-2009-0820-1918.orig/include/linux/sunrpc/rpc_pipe_fs.h
> +++ mmotm-2009-0820-1918/include/linux/sunrpc/rpc_pipe_fs.h
> @@ -3,6 +3,8 @@
>  
>  #ifdef __KERNEL__
>  
> +#include <linux/workqueue.h>
> +
>  struct rpc_pipe_msg {
>  	struct list_head list;
>  	void *data;

Thanks Randy! Bruce Fields beat you to this bug by a few hours, so I've
already applied his fix. It should hit linux-next et al today.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
