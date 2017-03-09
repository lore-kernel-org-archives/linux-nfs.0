Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from vmicros1.altlinux.org ([194.107.17.57]:41456 "EHLO
        vmicros1.altlinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751623AbdCIWbR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Mar 2017 17:31:17 -0500
Date: Fri, 10 Mar 2017 01:31:14 +0300
From: "Dmitry V. Levin" <ldv@altlinux.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] uapi: fix linux/nfsd/cld.h userspace compilation errors
Message-ID: <20170309223114.GA19081@altlinux.org>
References: <20170301001203.GA11188@altlinux.org> <20170309210051.GH3929@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=x-unknown;
        protocol="application/pgp-signature"; boundary="huq684BweRXVnRxX"
In-Reply-To: <20170309210051.GH3929@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 09, 2017 at 04:00:51PM -0500, J. Bruce Fields wrote:
> Why aren't the unitX_t types OK here?

unitX_t types are not OK here because no UAPI header defines them,
include/uapi/linux/types.h defines only their __uX/__sX analogues.

For this reason most of UAPI headers use types provided by
<linux/types.h>, see e.g. include/uapi/linux/nfsd/nfsfh.h

There are few exceptions to this rule when headers are made portable
between linux and other operating systems.

> Anyway, assuming this is right I'll apply for 4.12.  (I'm assuming it's
> not urgent since this file's always been this way.)

This should be safe to apply for 4.11 as well, but it's surely not urgent.

> --b.
>=20
> On Wed, Mar 01, 2017 at 03:12:03AM +0300, Dmitry V. Levin wrote:
> > Include <linux/types.h> and consistently use types it provides
> > to fix the following linux/nfsd/cld.h userspace compilation errors:
> >=20
> > /usr/include/linux/nfsd/cld.h:40:2: error: unknown type name 'uint16_t'
> >   uint16_t cn_len;    /* length of cm_id */
> > /usr/include/linux/nfsd/cld.h:46:2: error: unknown type name 'uint8_t'
> >   uint8_t  cm_vers;  /* upcall version */
> > /usr/include/linux/nfsd/cld.h:47:2: error: unknown type name 'uint8_t'
> >   uint8_t  cm_cmd;   /* upcall command */
> > /usr/include/linux/nfsd/cld.h:48:2: error: unknown type name 'int16_t'
> >   int16_t  cm_status;  /* return code */
> > /usr/include/linux/nfsd/cld.h:49:2: error: unknown type name 'uint32_t'
> >   uint32_t cm_xid;   /* transaction id */
> > /usr/include/linux/nfsd/cld.h:51:3: error: unknown type name 'int64_t'
> >    int64_t  cm_gracetime; /* grace period start time */
> >=20
> > Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
> > ---
> >  include/uapi/linux/nfsd/cld.h | 14 ++++++++------
> >  1 file changed, 8 insertions(+), 6 deletions(-)
> >=20
> > diff --git a/include/uapi/linux/nfsd/cld.h b/include/uapi/linux/nfsd/cl=
d.h
> > index f14a9ab..ec26027 100644
> > --- a/include/uapi/linux/nfsd/cld.h
> > +++ b/include/uapi/linux/nfsd/cld.h
> > @@ -22,6 +22,8 @@
> >  #ifndef _NFSD_CLD_H
> >  #define _NFSD_CLD_H
> > =20
> > +#include <linux/types.h>
> > +
> >  /* latest upcall version available */
> >  #define CLD_UPCALL_VERSION 1
> > =20
> > @@ -37,18 +39,18 @@ enum cld_command {
> > =20
> >  /* representation of long-form NFSv4 client ID */
> >  struct cld_name {
> > -	uint16_t	cn_len;				/* length of cm_id */
> > +	__u16		cn_len;				/* length of cm_id */
> >  	unsigned char	cn_id[NFS4_OPAQUE_LIMIT];	/* client-provided */
> >  } __attribute__((packed));
> > =20
> >  /* message struct for communication with userspace */
> >  struct cld_msg {
> > -	uint8_t		cm_vers;		/* upcall version */
> > -	uint8_t		cm_cmd;			/* upcall command */
> > -	int16_t		cm_status;		/* return code */
> > -	uint32_t	cm_xid;			/* transaction id */
> > +	__u8		cm_vers;		/* upcall version */
> > +	__u8		cm_cmd;			/* upcall command */
> > +	__s16		cm_status;		/* return code */
> > +	__u32		cm_xid;			/* transaction id */
> >  	union {
> > -		int64_t		cm_gracetime;	/* grace period start time */
> > +		__s64		cm_gracetime;	/* grace period start time */
> >  		struct cld_name	cm_name;
> >  	} __attribute__((packed)) cm_u;
> >  } __attribute__((packed));
> > --=20
> > ldv

--=20
ldv

--huq684BweRXVnRxX
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYwdeyAAoJEAVFT+BVnCUIE7gP/3iZ3AUtyWd3WVkoR0GkfjVZ
A9u3MZEzT3F5Gt7SSNclMSzPb3NVQDflaJI1JGLUgrDQOOCJD6/hMyFQVfRBEzFz
hX21olHvERQrxACs2II1ar8LpD//GQhjRofdee1Av4annRaGazsSSidmmR1WDl13
FJ6M2MoAPbh1clDKjWHZJZC62PDqFv6sXtSG5y5/Qr+eFD/U8aTDu4rV8gnSbdqD
YjFDY+xyo9eOsJsZp4RVqA2AvLdfv7eVQ7HQgPl0/GydEY1ZW+kKZj5KkIe4HmhA
RHgRhihNZvAG/fPY+f4F5Yti9/kg40uWRZtClrwlge9sfPxNUFgW4we+9Zbxrs0Z
muHte7gLTLElpKGmEqtd6Si9cKRePFrS5s7jLJ+irgeglLifbXjm6thfTDM5wuhV
8r20Wx1CDvQoyBbwbqpXLz9xy2hqc0QIGX32ySC/9jHHlFHIrC11Fw2ZqeH8MXl1
Jq9mivKHJ412+sxySX8u5CDHb3aRn3AHa+UgH8tCTyTYSHR/WUrMP8+9GwyWActw
VfUJqYzsHHpATtzKjf4zGHhV1jQpbg+oz8MlWLPfYWBjGlhqQd1iOjApf9qZ81oE
b9XNmOV5piANE4PWYyoReBVuMMr1P1pBiPILhds9bXyocgwy4e04SxLFHjfbXqW6
5wpNLlFpbMm63wHcE77+
=2vxp
-----END PGP SIGNATURE-----

--huq684BweRXVnRxX--
