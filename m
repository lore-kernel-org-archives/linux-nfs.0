From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [REGRESSION PATCH v2] NFS: let NFS_V4 and NFSD_V4 enforce
	CRYPTO
Date: Fri, 3 Sep 2010 22:24:37 +0200
Message-ID: <20100903202437.GA27767@pengutronix.de>
References: <20100830121022.GA14459@pengutronix.de> <1283331170-11440-1-git-send-email-u.kleine-koenig@pengutronix.de> <1283347024.3184.8.camel@heimdal.trondhjem.org> <20100901135041.GC11107@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Neil Brown <neilb@suse.de>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46442 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754040Ab0ICUYo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Sep 2010 16:24:44 -0400
In-Reply-To: <20100901135041.GC11107@pengutronix.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Trond,

On Wed, Sep 01, 2010 at 03:50:41PM +0200, Uwe Kleine-K=F6nig wrote:
> On Wed, Sep 01, 2010 at 09:17:04AM -0400, Trond Myklebust wrote:
> > On Wed, 2010-09-01 at 10:52 +0200, Uwe Kleine-K=F6nig wrote:
> > > Hello,
> > >=20
> > > here comes a v2 of the patch that improves the commit log with a =
more
> > > detailed analysis of the breakage introduced by df486a2
> > > (=3D v2.6.36-rc2~34^2~1 BTW) and additionally undoes the "default=
 y" for
> > > RPCSEC_GSS_KRB5.
> > >=20
> > > So compared to the state before df486a2 the changes are:
> > >=20
> > >         NFS_V4 selects CRYPTO
> > >         NFSD_V4 selects CRYPTO
> > > 	RPCSEC_GSS_KRB5 doesn't depend on EXPERIMENTAL anymore
> > > 	RPCSEC_GSS_KRB5 now depends on CRYPTO instead of selecting it
> > >=20
> > > Best regards
> > > Uwe
> > >=20
> > > ----------------------------->8----------------------------
> > >=20
> > > This is a follow up to
> > >=20
> > > 	df486a2 (NFS: Fix the selection of security flavours in Kconfig)
> > >=20
> > > Before df486a2 NFS_V4 selected RPCSEC_GSS_KRB5 but didn't enforce=
 the
> > > latter's dependency EXPERIMENTAL.  df486a2 removed RPCSEC_GSS_KRB=
5's
> > > dependency on EXPERIMENTAL but additionally let it depend on CRYP=
TO
> > > (instead of select CRYPTO before).  So it was still possible to h=
ave a
> > > config that has NFS_V4 but not RPCSEC_GSS_KRB5.  Moreover df486a2
> > > changed the dependency of NFS_V4 and NFSD_V4 on RPCSEC_GSS_KRB5 f=
rom
> >=20
> > As I said, the fix is to remove that dependency. I have a fix for t=
he
> > NFS client, but the server has more insidious dependencies on RPCSE=
C_GSS
> > due to a poorly designed SECINFO implementation.
> Yes, I still remember this, so I suggest to take my patch before 2.6.=
36
> and you can fix it in the merge window for 2.6.37, no?
ping

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
