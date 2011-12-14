Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38340 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758227Ab1LNVxX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 16:53:23 -0500
Date: Wed, 14 Dec 2011 16:53:22 -0500
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/5] nfsd: add a header describing upcall for clname
 tracking daemon
Message-ID: <20111214215322.GC7623@fieldses.org>
References: <1323870891-3124-1-git-send-email-jlayton@redhat.com>
 <1323870891-3124-4-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1323870891-3124-4-git-send-email-jlayton@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 14, 2011 at 08:54:49AM -0500, Jeff Layton wrote:
> Add a new header that describes the clname tracking daemon upcall. The
> daemon takes a versioned binary struct. Hopefully this should allow us
> to revise the struct later if it becomes necessary.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  include/linux/nfsd/clstate.h |   59 ++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 59 insertions(+), 0 deletions(-)
>  create mode 100644 include/linux/nfsd/clstate.h
> 
> diff --git a/include/linux/nfsd/clstate.h b/include/linux/nfsd/clstate.h
> new file mode 100644
> index 0000000..d571aa5
> --- /dev/null
> +++ b/include/linux/nfsd/clstate.h
> @@ -0,0 +1,59 @@
> +/*
> + * fs/nfsd/clstate.h - data type and function declarations for clstate mgmt
> + *
> + * Copyright (c) 2011 Red Hat, Inc.
> + * Author(s): Jeff Layton <jlayton@redhat.com>
> + *
> + *  This program is free software; you can redistribute it and/or modify
> + *  it under the terms of the GNU General Public License as published by
> + *  the Free Software Foundation; either version 2 of the License, or
> + *  (at your option) any later version.
> + *
> + *  This program is distributed in the hope that it will be useful,
> + *  but WITHOUT ANY WARRANTY; without even the implied warranty of
> + *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + *  GNU General Public License for more details.
> + *
> + *  You should have received a copy of the GNU General Public License
> + *  along with this program; if not, write to the Free Software
> + *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> + */
> +
> +#ifndef _NFSD_CLSTATE_H
> +#define _NFSD_CLSTATE_H
> +
> +/* latest upcall version available */
> +#define CLSTATE_MAX_UPCALL_VERSION 1
> +
> +/* defined by RFC3530 */
> +#define NFS4_OPAQUE_LIMIT 1024
> +
> +/*
> + * Maximum length of an address string. We could use INET6_ADDRSTRLEN, but
> + * the kernel and userspace definitions are different.
> + */
> +#define CLSTATE_MAX_ADDRESS_LEN 48
> +
> +enum clstate_command {
> +	Cl_Create,		/* create a record for this cm_id */
> +	Cl_Expire,		/* remove record for this cm_id */
> +	Cl_NrToReclaim,		/* how many client records need reclaim? */

There will probably also be other information we want from userspace on
startup, and this might be a good place to get it.  (For example, a boot
iteration and/or node id for use in clientid's.)

--b.


> +	Cl_Allow,		/* is this cm_id allowed? */
> +	Cl_GraceDone		/* grace period is complete */
> +};
> +
> +/* message struct for communication with userspace */
> +struct clstate_msg {
> +	uint8_t		cm_vers;		/* upcall version */
> +	uint8_t		cm_cmd;			/* upcall command */
> +	uint32_t	cm_xid;			/* transaction id */
> +	int16_t		cm_status;		/* return code */
> +	uint16_t	cm_len;			/* length of cm_id */
> +	unsigned char	cm_addr[CLSTATE_MAX_ADDRESS_LEN]; /* server addr */
> +	union {
> +		int64_t		cm_gracetime;	/* grace period start time */
> +		unsigned char	cm_id[NFS4_OPAQUE_LIMIT]; /* client-provided */
> +	} __attribute__((packed)) cm_u;
> +} __attribute__((packed));
> +
> +#endif /* !_NFSD_CLSTATE_H */
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
