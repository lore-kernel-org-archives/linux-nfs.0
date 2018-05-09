Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53398 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934932AbeEIUXY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 9 May 2018 16:23:24 -0400
Date: Wed, 9 May 2018 16:23:23 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 01/19] svcrdma: Add proper SPDX tags for
 NetApp-contributed source
Message-ID: <20180509202323.GA31959@fieldses.org>
References: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
 <20180507192655.4608.26260.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180507192655.4608.26260.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looking at the git history, it looks like others are taking this as an
opportunity to replace the existing boilerplate.  Could we do this here?
Looks like "BSD-3-Clause" does in fact refer to a license that's
word-for-word the same as the one included here (except for the name of
the copyright holder), so I wonder if we need it written out here any
more.

(Minor point, I'm applying this anyway and you can follow up with the
remval patch or not.)

--b.

On Mon, May 07, 2018 at 03:26:55PM -0400, Chuck Lever wrote:
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  include/linux/sunrpc/svc_rdma.h          |    1 +
>  net/sunrpc/xprtrdma/svc_rdma.c           |    1 +
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    1 +
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    1 +
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    1 +
>  5 files changed, 5 insertions(+)
> 
> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
> index 7337e12..88da0c9 100644
> --- a/include/linux/sunrpc/svc_rdma.h
> +++ b/include/linux/sunrpc/svc_rdma.h
> @@ -1,3 +1,4 @@
> +/* SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause */
>  /*
>   * Copyright (c) 2005-2006 Network Appliance, Inc. All rights reserved.
>   *
> diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
> index dd8a431..a490532 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma.c
> @@ -1,3 +1,4 @@
> +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
>  /*
>   * Copyright (c) 2005-2006 Network Appliance, Inc. All rights reserved.
>   *
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index 3d45015..9eae95d 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -1,3 +1,4 @@
> +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
>  /*
>   * Copyright (c) 2016, 2017 Oracle. All rights reserved.
>   * Copyright (c) 2014 Open Grid Computing, Inc. All rights reserved.
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index 649441d..79bd3a3 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -1,3 +1,4 @@
> +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
>  /*
>   * Copyright (c) 2016 Oracle. All rights reserved.
>   * Copyright (c) 2014 Open Grid Computing, Inc. All rights reserved.
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index 96cc8f6..3633254 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -1,3 +1,4 @@
> +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
>  /*
>   * Copyright (c) 2014 Open Grid Computing, Inc. All rights reserved.
>   * Copyright (c) 2005-2007 Network Appliance, Inc. All rights reserved.
