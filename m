From: Neil Brown <neilb@suse.de>
Subject: Re: [REGRESSION PATCH] NFS: let NFS_V4 and NFSD_V4 enforce CRYPTO
Date: Mon, 30 Aug 2010 20:36:59 +1000
Message-ID: <20100830203659.3b9884f6@notabene>
References: <20100825084912.GA10293@pengutronix.de>
	<1282727119-8295-1-git-send-email-u.kleine-koenig@pengutronix.de>
	<20100827061139.GA27851@pengutronix.de>
	<20100830082618.GA24402@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	"J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Uwe =?UTF-8?B?S2xlaW5lLUvDtm5pZw==?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:58995 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754997Ab0H3KhK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 06:37:10 -0400
In-Reply-To: <20100830082618.GA24402@pengutronix.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 30 Aug 2010 10:26:18 +0200
Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de> wrote:

> [extending Cc: to contain Neil and linux-nfs]
>=20
> On Fri, Aug 27, 2010 at 08:11:39AM +0200, Uwe Kleine-K=C3=B6nig wrote=
:
> > On Wed, Aug 25, 2010 at 11:05:19AM +0200, Uwe Kleine-K=C3=B6nig wro=
te:

I would tend to wait more than 2 days between pings..


> > > This is a follow up to
> > >=20
> > > 	df486a2 (NFS: Fix the selection of security flavours in Kconfig)
> > >=20
> > > which broke (among others) arm/mx1_defconfig.
> > >=20
> > > Moreover let NFS_V4 select RPCSEC_GSS_KRB5 again as it was before
> > > df486a2.  This make the dependency more explicit than relying on =
the no
> > > prompt + default y if !(NFS_V4 || NFSD_V4).

Maybe if you said a little bit about how it broke?
And I'm not sure of the point of the "recursive dependency" comment bel=
ow...

I don't fully understand all the issues behind choosing between 'depend=
s' and
'select' (why isn't is 'selects' I wonder - that would be more consiste=
nt...)

But that patch seems to make sense to me.

NeilBrown


> > >=20
> > > Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix=
=2Ede>
> > ping
> ping^2
> >=20
> > > ---
> > >  fs/nfs/Kconfig     |    2 ++
> > >  fs/nfsd/Kconfig    |    2 ++
> > >  net/sunrpc/Kconfig |    2 +-
> > >  3 files changed, 5 insertions(+), 1 deletions(-)
> > >=20
> > > diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> > > index 6c2aad4..5b9f870 100644
> > > --- a/fs/nfs/Kconfig
> > > +++ b/fs/nfs/Kconfig
> > > @@ -63,6 +63,8 @@ config NFS_V3_ACL
> > >  config NFS_V4
> > >  	bool "NFS client support for NFS version 4"
> > >  	depends on NFS_FS
> > > +	select CRYPTO # recursive select: RPCSEC_GSS_KRB5 depends on CR=
YPTO
> > > +	select RPCSEC_GSS_KRB5
> > >  	help
> > >  	  This option enables support for version 4 of the NFS protocol
> > >  	  (RFC 3530) in the kernel's NFS client.
> > > diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> > > index 95932f5..3678a16 100644
> > > --- a/fs/nfsd/Kconfig
> > > +++ b/fs/nfsd/Kconfig
> > > @@ -69,6 +69,8 @@ config NFSD_V4
> > >  	depends on NFSD && PROC_FS && EXPERIMENTAL
> > >  	select NFSD_V3
> > >  	select FS_POSIX_ACL
> > > +	select CRYPTO # recursive select: RPCSEC_GSS_KRB5 depends on CR=
YPTO
> > > +	select RPCSEC_GSS_KRB5
> > >  	help
> > >  	  This option enables support in your system's NFS server for
> > >  	  version 4 of the NFS protocol (RFC 3530).
> > > diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
> > > index 3376d76..6b661e3 100644
> > > --- a/net/sunrpc/Kconfig
> > > +++ b/net/sunrpc/Kconfig
> > > @@ -20,7 +20,7 @@ config SUNRPC_XPRT_RDMA
> > >  config RPCSEC_GSS_KRB5
> > >  	tristate
> > >  	depends on SUNRPC && CRYPTO
> > > -	prompt "Secure RPC: Kerberos V mechanism" if !(NFS_V4 || NFSD_V=
4)
> > > +	prompt "Secure RPC: Kerberos V mechanism"
> > >  	default y
> > >  	select SUNRPC_GSS
> > >  	select CRYPTO_MD5
> > > --=20
> > > 1.7.1
>=20

