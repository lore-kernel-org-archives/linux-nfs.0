Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38905 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754115Ab1JQWSM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Oct 2011 18:18:12 -0400
Date: Mon, 17 Oct 2011 18:18:11 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: bjschuma@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFSD: Added fault injection
Message-ID: <20111017221810.GG13368@fieldses.org>
References: <1318009468-19893-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1318009468-19893-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 07, 2011 at 01:44:26PM -0400, bjschuma@netapp.com wrote:
> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> index 10e6366..52fdd1c 100644
> --- a/fs/nfsd/Kconfig
> +++ b/fs/nfsd/Kconfig
> @@ -80,3 +80,13 @@ config NFSD_V4
>  	  available from http://linux-nfs.org/.
>  
>  	  If unsure, say N.
> +
> +config NFSD_FAULT_INJECTION
> +	bool "NFS server manual fault injection"
> +	depends on NFSD_V4 && DEBUG_KERNEL
> +	help
> +	  This option enables support for manually injectiong faults
						   ^^^^^^^^^^

> diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
> new file mode 100644
> index 0000000..9f6815b
> --- /dev/null
> +++ b/fs/nfsd/fault_inject.c
> @@ -0,0 +1,94 @@
> +/*
> + * Copyright (c) 2011 Bryan Schumaker <bjschuma@netapp.com>
> + *
> + * Uses debugfs to create fault injection points for client testing
> + */
> +
> +#include <linux/types.h>
> +#include <linux/fs.h>
> +#include <linux/debugfs.h>
> +#include <linux/module.h>
> +
> +#include "state.h"
> +#include "fault_inject.h"
> +
> +struct nfsd_fault_inject_op {
> +	char *action;
> +	char *item;
> +	char *file;
> +	int file_data;
> +	void (*func)(u64);
> +};
> +
> +#define INJECTION_OP(op_action, op_item, op_func)	\
> +{							\
> +	.action = op_action,				\
> +	.item   = op_item,				\
> +	.file   = op_action"_"op_item,			\
> +	.func   = op_func,				\
> +}
> +
> +static struct nfsd_fault_inject_op inject_ops[] = {
> +	INJECTION_OP("forget", "clients",     nfsd_forget_clients),
> +	INJECTION_OP("forget", "locks",       nfsd_forget_locks),
> +	INJECTION_OP("forget", "openowners",  nfsd_forget_openowners),
> +	INJECTION_OP("forget", "delegations", nfsd_forget_delegations),
> +	INJECTION_OP("recall", "delegations", nfsd_recall_delegations),

This is a little clever for my taste....  Could we just do

	static struct nfsd_fault_inject_op inject_ops[] = {
		{
			.file = "forget_client",
			.op = nfsd_forget_clients,
		},
		...
	}

and do away with the separate item and action fields?

I'd rather be sort of obvious and boring even if it's slightly less
compact.

> +};
> +
> +static long int NUM_INJECT_OPS = sizeof(inject_ops) / sizeof(struct nfsd_fault_inject_op);
> +static struct dentry *debug_dir;
> +
> +static int nfsd_inject_set(void *data, u64 val)
> +{
> +	int i;
> +	struct nfsd_fault_inject_op *op;
> +
> +	for (i = 0; i < NUM_INJECT_OPS; i++) {
> +		op = &inject_ops[i];
> +		if (&op->file_data == data) {

Huh, OK, so if I understand right, the contents of file_data doesn't
matter, you're just using a pointer to that field as a way to identify
the op array.

But then couldn't you just pass in a pointer to the op itself:

> +	for (i = 0; i < NUM_INJECT_OPS; i++) {
> +		op = &inject_ops[i];
> +		debugfs_create_file(op->file, mode, debug_dir, &op->file_data, &fops_nfsd);

like:

		debugfs_create_file(op->file, mode, debug_dir, op, &fops_nfsd);

and eliminate the file_data field?

Patches look OK otherwise on a quick skim, thanks.

--b.


> +	}
> +	return 0;
