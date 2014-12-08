Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53241 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754569AbaLHUrK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2014 15:47:10 -0500
Date: Mon, 8 Dec 2014 15:47:09 -0500
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [RFC PATCH 09/14] sunrpc: add basic support for workqueue-based
 services
Message-ID: <20141208204709.GA19437@fieldses.org>
References: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
 <1417544663-13299-10-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1417544663-13299-10-git-send-email-jlayton@primarydata.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 02, 2014 at 01:24:18PM -0500, Jeff Layton wrote:
> diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
> index fb78117b896c..08e01949bdc5 100644
> --- a/net/sunrpc/Kconfig
> +++ b/net/sunrpc/Kconfig
> @@ -71,3 +71,13 @@ config SUNRPC_XPRT_RDMA_SERVER
>  	  choose M here: the module will be called svcrdma.
>  
>  	  If unsure, say N.
> +
> +config SUNRPC_SVC_WORKQUEUE
> +	bool "Support for workqueue-based SUNRPC services"
> +	depends on SUNRPC
> +	default	n
> +	help
> +	  Traditional SUNRPC services have required a dedicated thread
> +	  to handle incoming requests. This option enables support for
> +	  queueing incoming reqests to a workqueue instead, eliminating
> +	  the need for a dedicated thread pool.

Minor point, but: If people don't want this, they can turn it off at
runtime.  It's annoying to test all the possible combination of build
options, and this doesn't seem likely to let people e.g. build a
significantly smaller kernel, so I wouldn't bother.

--b.
