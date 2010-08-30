From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [REGRESSION PATCH] NFS: let NFS_V4 and NFSD_V4 enforce CRYPTO
Date: Mon, 30 Aug 2010 10:26:18 +0200
Message-ID: <20100830082618.GA24402@pengutronix.de>
References: <20100825084912.GA10293@pengutronix.de> <1282727119-8295-1-git-send-email-u.kleine-koenig@pengutronix.de> <20100827061139.GA27851@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: linux-kernel@vger.kernel.org,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100827061139.GA27851@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[extending Cc: to contain Neil and linux-nfs]

On Fri, Aug 27, 2010 at 08:11:39AM +0200, Uwe Kleine-K=F6nig wrote:
> On Wed, Aug 25, 2010 at 11:05:19AM +0200, Uwe Kleine-K=F6nig wrote:
> > This is a follow up to
> >=20
> > 	df486a2 (NFS: Fix the selection of security flavours in Kconfig)
> >=20
> > which broke (among others) arm/mx1_defconfig.
> >=20
> > Moreover let NFS_V4 select RPCSEC_GSS_KRB5 again as it was before
> > df486a2.  This make the dependency more explicit than relying on th=
e no
> > prompt + default y if !(NFS_V4 || NFSD_V4).
> >=20
> > Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> ping
ping^2
>=20
> > ---
> >  fs/nfs/Kconfig     |    2 ++
> >  fs/nfsd/Kconfig    |    2 ++
> >  net/sunrpc/Kconfig |    2 +-
> >  3 files changed, 5 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> > index 6c2aad4..5b9f870 100644
> > --- a/fs/nfs/Kconfig
> > +++ b/fs/nfs/Kconfig
> > @@ -63,6 +63,8 @@ config NFS_V3_ACL
> >  config NFS_V4
> >  	bool "NFS client support for NFS version 4"
> >  	depends on NFS_FS
> > +	select CRYPTO # recursive select: RPCSEC_GSS_KRB5 depends on CRYP=
TO
> > +	select RPCSEC_GSS_KRB5
> >  	help
> >  	  This option enables support for version 4 of the NFS protocol
> >  	  (RFC 3530) in the kernel's NFS client.
> > diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> > index 95932f5..3678a16 100644
> > --- a/fs/nfsd/Kconfig
> > +++ b/fs/nfsd/Kconfig
> > @@ -69,6 +69,8 @@ config NFSD_V4
> >  	depends on NFSD && PROC_FS && EXPERIMENTAL
> >  	select NFSD_V3
> >  	select FS_POSIX_ACL
> > +	select CRYPTO # recursive select: RPCSEC_GSS_KRB5 depends on CRYP=
TO
> > +	select RPCSEC_GSS_KRB5
> >  	help
> >  	  This option enables support in your system's NFS server for
> >  	  version 4 of the NFS protocol (RFC 3530).
> > diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
> > index 3376d76..6b661e3 100644
> > --- a/net/sunrpc/Kconfig
> > +++ b/net/sunrpc/Kconfig
> > @@ -20,7 +20,7 @@ config SUNRPC_XPRT_RDMA
> >  config RPCSEC_GSS_KRB5
> >  	tristate
> >  	depends on SUNRPC && CRYPTO
> > -	prompt "Secure RPC: Kerberos V mechanism" if !(NFS_V4 || NFSD_V4)
> > +	prompt "Secure RPC: Kerberos V mechanism"
> >  	default y
> >  	select SUNRPC_GSS
> >  	select CRYPTO_MD5
> > --=20
> > 1.7.1

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
