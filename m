Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60622 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755338AbdCJRg2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Mar 2017 12:36:28 -0500
Date: Fri, 10 Mar 2017 12:36:26 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Dmitry V. Levin" <ldv@altlinux.org>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] uapi: fix linux/nfsd/cld.h userspace compilation errors
Message-ID: <20170310173626.GG29791@fieldses.org>
References: <20170301001203.GA11188@altlinux.org>
 <20170309210051.GH3929@fieldses.org>
 <20170309223114.GA19081@altlinux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170309223114.GA19081@altlinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 10, 2017 at 01:31:14AM +0300, Dmitry V. Levin wrote:
> On Thu, Mar 09, 2017 at 04:00:51PM -0500, J. Bruce Fields wrote:
> > Why aren't the unitX_t types OK here?
> 
> unitX_t types are not OK here because no UAPI header defines them,
> include/uapi/linux/types.h defines only their __uX/__sX analogues.
> 
> For this reason most of UAPI headers use types provided by
> <linux/types.h>, see e.g. include/uapi/linux/nfsd/nfsfh.h
> 
> There are few exceptions to this rule when headers are made portable
> between linux and other operating systems.
> 
> > Anyway, assuming this is right I'll apply for 4.12.  (I'm assuming it's
> > not urgent since this file's always been this way.)
> 
> This should be safe to apply for 4.11 as well, but it's surely not urgent.

OK, thanks.--b.

> 
> > --b.
> > 
> > On Wed, Mar 01, 2017 at 03:12:03AM +0300, Dmitry V. Levin wrote:
> > > Include <linux/types.h> and consistently use types it provides
> > > to fix the following linux/nfsd/cld.h userspace compilation errors:
> > > 
> > > /usr/include/linux/nfsd/cld.h:40:2: error: unknown type name 'uint16_t'
> > >   uint16_t cn_len;    /* length of cm_id */
> > > /usr/include/linux/nfsd/cld.h:46:2: error: unknown type name 'uint8_t'
> > >   uint8_t  cm_vers;  /* upcall version */
> > > /usr/include/linux/nfsd/cld.h:47:2: error: unknown type name 'uint8_t'
> > >   uint8_t  cm_cmd;   /* upcall command */
> > > /usr/include/linux/nfsd/cld.h:48:2: error: unknown type name 'int16_t'
> > >   int16_t  cm_status;  /* return code */
> > > /usr/include/linux/nfsd/cld.h:49:2: error: unknown type name 'uint32_t'
> > >   uint32_t cm_xid;   /* transaction id */
> > > /usr/include/linux/nfsd/cld.h:51:3: error: unknown type name 'int64_t'
> > >    int64_t  cm_gracetime; /* grace period start time */
> > > 
> > > Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
> > > ---
> > >  include/uapi/linux/nfsd/cld.h | 14 ++++++++------
> > >  1 file changed, 8 insertions(+), 6 deletions(-)
> > > 
> > > diff --git a/include/uapi/linux/nfsd/cld.h b/include/uapi/linux/nfsd/cld.h
> > > index f14a9ab..ec26027 100644
> > > --- a/include/uapi/linux/nfsd/cld.h
> > > +++ b/include/uapi/linux/nfsd/cld.h
> > > @@ -22,6 +22,8 @@
> > >  #ifndef _NFSD_CLD_H
> > >  #define _NFSD_CLD_H
> > >  
> > > +#include <linux/types.h>
> > > +
> > >  /* latest upcall version available */
> > >  #define CLD_UPCALL_VERSION 1
> > >  
> > > @@ -37,18 +39,18 @@ enum cld_command {
> > >  
> > >  /* representation of long-form NFSv4 client ID */
> > >  struct cld_name {
> > > -	uint16_t	cn_len;				/* length of cm_id */
> > > +	__u16		cn_len;				/* length of cm_id */
> > >  	unsigned char	cn_id[NFS4_OPAQUE_LIMIT];	/* client-provided */
> > >  } __attribute__((packed));
> > >  
> > >  /* message struct for communication with userspace */
> > >  struct cld_msg {
> > > -	uint8_t		cm_vers;		/* upcall version */
> > > -	uint8_t		cm_cmd;			/* upcall command */
> > > -	int16_t		cm_status;		/* return code */
> > > -	uint32_t	cm_xid;			/* transaction id */
> > > +	__u8		cm_vers;		/* upcall version */
> > > +	__u8		cm_cmd;			/* upcall command */
> > > +	__s16		cm_status;		/* return code */
> > > +	__u32		cm_xid;			/* transaction id */
> > >  	union {
> > > -		int64_t		cm_gracetime;	/* grace period start time */
> > > +		__s64		cm_gracetime;	/* grace period start time */
> > >  		struct cld_name	cm_name;
> > >  	} __attribute__((packed)) cm_u;
> > >  } __attribute__((packed));
> > > -- 
> > > ldv
> 
> -- 
> ldv


