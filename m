Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16206 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751866Ab1LSMpN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Dec 2011 07:45:13 -0500
Date: Tue, 20 Dec 2011 07:45:00 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 4/5] nfsd: add a header describing upcall to nfsdcld
Message-ID: <20111220074500.5d4cf286@tlielax.poochiereds.net>
In-Reply-To: <4EEF2933.8090405@tonian.com>
References: <1323974606-16477-1-git-send-email-jlayton@redhat.com>
	<1323974606-16477-5-git-send-email-jlayton@redhat.com>
	<4EEF2933.8090405@tonian.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 19 Dec 2011 14:08:19 +0200
Benny Halevy <bhalevy@tonian.com> wrote:

> On 2011-12-15 20:43, Jeff Layton wrote:
> > The daemon takes a versioned binary struct. Hopefully this should allow
> > us to revise the struct later if it becomes necessary.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  include/linux/nfsd/cld.h |   57 ++++++++++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 57 insertions(+), 0 deletions(-)
> >  create mode 100644 include/linux/nfsd/cld.h
> > 
> > diff --git a/include/linux/nfsd/cld.h b/include/linux/nfsd/cld.h
> > new file mode 100644
> > index 0000000..d64a7e7
> > --- /dev/null
> > +++ b/include/linux/nfsd/cld.h
> > @@ -0,0 +1,57 @@
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
> > +#define CLD_MAX_UPCALL_VERSION 1
> > +
> > +/* defined by RFC3530 */
> > +#define NFS4_OPAQUE_LIMIT 1024
> > +
> > +enum cld_command {
> > +	Cld_Create,		/* create a record for this cm_id */
> > +	Cld_Expire,		/* remove record for this cm_id */
> > +	Cld_Allow,		/* is this cm_id allowed? */
> > +	Cld_GraceDone,		/* grace period is complete */
> > +	Cld_NrToReclaim,	/* how many client records need reclaim? */
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
> > +	uint32_t	cm_xid;			/* transaction id */
> > +	int16_t		cm_status;		/* return code */
> 
> How about swapping the xid and status members so they'd align better?
> 
> Benny
> 

Good catch. I'll fix that in the next iteration.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
