Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1027 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751282Ab1LOPNF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Dec 2011 10:13:05 -0500
Date: Thu, 15 Dec 2011 10:14:38 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/5] nfsd: add a header describing upcall for clname
 tracking daemon
Message-ID: <20111215101438.3b0db96f@barsoom.rdu.redhat.com>
In-Reply-To: <20111214215322.GC7623@fieldses.org>
References: <1323870891-3124-1-git-send-email-jlayton@redhat.com>
	<1323870891-3124-4-git-send-email-jlayton@redhat.com>
	<20111214215322.GC7623@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 14 Dec 2011 16:53:22 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Dec 14, 2011 at 08:54:49AM -0500, Jeff Layton wrote:
> > Add a new header that describes the clname tracking daemon upcall. The
> > daemon takes a versioned binary struct. Hopefully this should allow us
> > to revise the struct later if it becomes necessary.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  include/linux/nfsd/clstate.h |   59 ++++++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 59 insertions(+), 0 deletions(-)
> >  create mode 100644 include/linux/nfsd/clstate.h
> > 
> > diff --git a/include/linux/nfsd/clstate.h b/include/linux/nfsd/clstate.h
> > new file mode 100644
> > index 0000000..d571aa5
> > --- /dev/null
> > +++ b/include/linux/nfsd/clstate.h
> > @@ -0,0 +1,59 @@
> > +/*
> > + * fs/nfsd/clstate.h - data type and function declarations for clstate mgmt
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
> > +#ifndef _NFSD_CLSTATE_H
> > +#define _NFSD_CLSTATE_H
> > +
> > +/* latest upcall version available */
> > +#define CLSTATE_MAX_UPCALL_VERSION 1
> > +
> > +/* defined by RFC3530 */
> > +#define NFS4_OPAQUE_LIMIT 1024
> > +
> > +/*
> > + * Maximum length of an address string. We could use INET6_ADDRSTRLEN, but
> > + * the kernel and userspace definitions are different.
> > + */
> > +#define CLSTATE_MAX_ADDRESS_LEN 48
> > +
> > +enum clstate_command {
> > +	Cl_Create,		/* create a record for this cm_id */
> > +	Cl_Expire,		/* remove record for this cm_id */
> > +	Cl_NrToReclaim,		/* how many client records need reclaim? */
> 
> There will probably also be other information we want from userspace on
> startup, and this might be a good place to get it.  (For example, a boot
> iteration and/or node id for use in clientid's.)
> 

Yes, that was my original thinking in calling this a generic name like
"clstated". For now though, I'm just focusing on replacing the existing
functionality. We should be able to extend this later to do more things
without too much trouble though.

-- 
Jeff Layton <jlayton@redhat.com>
