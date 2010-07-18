Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:49107 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753512Ab0GRJJv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Jul 2010 05:09:51 -0400
Date: Sun, 18 Jul 2010 05:09:48 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Jim Rees <rees@umich.edu>
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] pnfs-block: Add support for simple rpc pipefs
Message-ID: <20100718090948.GB24960@infradead.org>
References: <cover.1279221394.git.rees@umich.edu>
 <abe8b56a1428b4a5b8372d619fb65b7986b8e501.1279221394.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <abe8b56a1428b4a5b8372d619fb65b7986b8e501.1279221394.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> --- /dev/null
> +++ b/include/linux/sunrpc/simple_rpc_pipefs.h
> @@ -0,0 +1,112 @@
> +/*
> + *  linux/fs/gfs2/simple_rpc_pipefs.h

There's a reason why these kind of filename comments are useless, and
you have just proven it.

> +#include <linux/fs.h>
> +#include <linux/list.h>
> +#include <linux/mount.h>
> +#include <linux/sched.h>
> +#include <linux/sunrpc/clnt.h>
> +#include <linux/sunrpc/rpc_pipe_fs.h>

Do you actually need all these in a header?  I suspect many could go
away in favour of forward declarations.

> +typedef struct pipefs_hdr {
> +	u32 msgid;
> +	u8  type;
> +	u8  flags;
> +	u16 totallen; /* length of entire message, including hdr itself */
> +	u32 status;
> +} pipefs_hdr_t;

> +typedef struct pipefs_list {
> +	struct list_head list;
> +	spinlock_t list_lock;
> +} pipefs_list_t;

Please do not add typedefs for your structures.

