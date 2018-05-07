Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:18748 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751923AbeEGNcy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 7 May 2018 09:32:54 -0400
Subject: Re: [PATCH v1 01/19] xprtrdma: Add proper SPDX tags for
 NetApp-contributed source
To: Chuck Lever <chuck.lever@oracle.com>
CC: <linux-rdma@vger.kernel.org>, <linux-nfs@vger.kernel.org>
References: <20180504192748.31688.3678.stgit@manet.1015granger.net>
 <20180504193432.31688.65935.stgit@manet.1015granger.net>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <4da36188-17d2-7b68-2974-80402c96359c@Netapp.com>
Date: Mon, 7 May 2018 09:27:16 -0400
MIME-Version: 1.0
In-Reply-To: <20180504193432.31688.65935.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

On 05/04/2018 03:34 PM, Chuck Lever wrote:
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  include/linux/sunrpc/rpc_rdma.h |    1 +
>  include/linux/sunrpc/xprtrdma.h |    1 +
>  net/sunrpc/xprtrdma/module.c    |    1 +
>  net/sunrpc/xprtrdma/rpc_rdma.c  |    1 +
>  net/sunrpc/xprtrdma/transport.c |    1 +
>  net/sunrpc/xprtrdma/verbs.c     |    1 +
>  net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
>  7 files changed, 7 insertions(+)
> 
> diff --git a/include/linux/sunrpc/rpc_rdma.h b/include/linux/sunrpc/rpc_rdma.h
> index 8f144db..92d182f 100644
> --- a/include/linux/sunrpc/rpc_rdma.h
> +++ b/include/linux/sunrpc/rpc_rdma.h
> @@ -1,3 +1,4 @@
> +/* SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause */
>  /*
>   * Copyright (c) 2015-2017 Oracle. All rights reserved.
>   * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
> diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
> index 5859563..86fc38f 100644
> --- a/include/linux/sunrpc/xprtrdma.h
> +++ b/include/linux/sunrpc/xprtrdma.h
> @@ -1,3 +1,4 @@
> +/* SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause */
>  /*
>   * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
>   *
> diff --git a/net/sunrpc/xprtrdma/module.c b/net/sunrpc/xprtrdma/module.c
> index a762d19..f338065 100644
> --- a/net/sunrpc/xprtrdma/module.c
> +++ b/net/sunrpc/xprtrdma/module.c
> @@ -1,3 +1,4 @@
> +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause

I'm not familiar with hte SPDX-License-Identifier tag.  Is there a reason it has to exist in a separate comment block at the top of the file instead of getting rolled in with the copyright stuff right below it?

Either way, can you use the C-style ("/* ... */") comments here (and in a few other places below) for consistency?

Thanks,
Anna

>  /*
>   * Copyright (c) 2015, 2017 Oracle.  All rights reserved.
>   */
> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
> index e8adad3..8f89e3f 100644
> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> @@ -1,3 +1,4 @@
> +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
>  /*
>   * Copyright (c) 2014-2017 Oracle.  All rights reserved.
>   * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> index cc1aad3..4717578 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -1,3 +1,4 @@
> +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
>  /*
>   * Copyright (c) 2014-2017 Oracle.  All rights reserved.
>   * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index c345d36..10f5032 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1,3 +1,4 @@
> +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
>  /*
>   * Copyright (c) 2014-2017 Oracle.  All rights reserved.
>   * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index cb41b12..e83ba758 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -1,3 +1,4 @@
> +/* SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause */
>  /*
>   * Copyright (c) 2014-2017 Oracle.  All rights reserved.
>   * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
> 
