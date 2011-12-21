Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51413 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751481Ab1LUVdi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Dec 2011 16:33:38 -0500
Date: Wed, 21 Dec 2011 16:33:12 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: bfields@fieldses.org, steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 4/5] nfsd: add a header describing upcall to nfsdcld
Message-ID: <20111221163312.3405c1f3@tlielax.poochiereds.net>
In-Reply-To: <46975244-4C42-4DC9-832B-E3597B8013FD@oracle.com>
References: <1324499696-10318-1-git-send-email-jlayton@redhat.com>
	<1324499696-10318-5-git-send-email-jlayton@redhat.com>
	<46975244-4C42-4DC9-832B-E3597B8013FD@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 21 Dec 2011 15:45:01 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Dec 21, 2011, at 3:34 PM, Jeff Layton wrote:
> 
> > The daemon takes a versioned binary struct. Hopefully this should allow
> > us to revise the struct later if it becomes necessary.
> 
> This breaks the pattern of using text-based up- and downcalls in NFSD.  I assume this is binary because nfs_client_id4 is a string of opaque bytes?
> 

That's the main reason. We could, of course encode that string in hex or
something, and decode it on the other end. No one has presented a
strong argument for doing it that way as of yet though.

If anyone feels strongly about that, then it would be helpful to have
them pipe up now and state why they do...

> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > include/linux/nfsd/cld.h |   56 ++++++++++++++++++++++++++++++++++++++++++++++
> > 1 files changed, 56 insertions(+), 0 deletions(-)
> > create mode 100644 include/linux/nfsd/cld.h
> > 
> > diff --git a/include/linux/nfsd/cld.h b/include/linux/nfsd/cld.h
> > new file mode 100644
> > index 0000000..d97d678
> > --- /dev/null
> > +++ b/include/linux/nfsd/cld.h
> > @@ -0,0 +1,56 @@
> > +/*
> > + * fs/nfsd/cld.h - upcall description for nfsdcld communication
> > + *
> > + * Copyright (c) 2011 Red Hat, Inc.
> > + * Author(s): Jeff Layton <jlayton@redhat.com>
> > + *
> > + *  This program is free software; you can redistribute it and/or modify
> > + *  it under the terms of the GNU General Public License as published by
> > + *  the Free Software Foundation; either version 2 of the License, or
> > + *  (at your option) any later version.
> > + *
> > + *  This program is distributed in the hope that it will be useful,
> > + *  but WITHOUT ANY WARRANTY; without even the implied warranty of
> > + *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> > + *  GNU General Public License for more details.
> > + *
> > + *  You should have received a copy of the GNU General Public License
> > + *  along with this program; if not, write to the Free Software
> > + *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> > + */
> > +
> > +#ifndef _NFSD_CLD_H
> > +#define _NFSD_CLD_H
> > +
> > +/* latest upcall version available */
> > +#define CLD_UPCALL_VERSION 1
> > +
> > +/* defined by RFC3530 */
> > +#define NFS4_OPAQUE_LIMIT 1024
> > +
> > +enum cld_command {
> > +	Cld_Create,		/* create a record for this cm_id */
> > +	Cld_Expire,		/* expire record for this cm_id */
> > +	Cld_Allow,		/* is this cm_id allowed? */
> > +	Cld_GraceDone,		/* grace period is complete */
> > +};
> > +
> > +/* representation of long-form NFSv4 client ID */
> > +struct cld_name {
> > +	uint16_t	cn_len;				/* length of cm_id */
> > +	unsigned char	cn_id[NFS4_OPAQUE_LIMIT];	/* client-provided */
> > +} __attribute__((packed));
> > +
> > +/* message struct for communication with userspace */
> > +struct cld_msg {
> > +	uint8_t		cm_vers;		/* upcall version */
> > +	uint8_t		cm_cmd;			/* upcall command */
> > +	int16_t		cm_status;		/* return code */
> > +	uint32_t	cm_xid;			/* transaction id */
> > +	union {
> > +		int64_t		cm_gracetime;	/* grace period start time */
> > +		struct cld_name	cm_name;
> > +	} __attribute__((packed)) cm_u;
> > +} __attribute__((packed));
> > +
> > +#endif /* !_NFSD_CLD_H */
> > -- 
> > 1.7.1
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Jeff Layton <jlayton@redhat.com>
