From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: A new NFSv4 server...
Date: Fri, 4 Jan 2008 14:50:48 +0100
Message-ID: <20080104135048.GA27131@janus>
References: <477CD231.30603@garzik.org> <20080103163200.GB30029@fieldses.org> <477DC501.3060104@garzik.org> <477DD11B.40909@melbourne.sgi.com> <477DDA86.6020100@garzik.org> <Pine.LNX.4.64.0801040954070.5004@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Jeff Garzik <jeff@garzik.org>,
	NFS list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org
To: Peter =?iso-8859-15?Q?=C5strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:54441 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752035AbYADNuu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jan 2008 08:50:50 -0500
In-Reply-To: <Pine.LNX.4.64.0801040954070.5004-K9BqGu7AvB3wj5YHdwD3Ga2PxDmRETKR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 04, 2008 at 10:15:00AM +0100, Peter =C5strand wrote:
>=20
> [About v4]
>=20
>=20
> On Fri, 4 Jan 2008, Jeff Garzik wrote:
>=20
> > > > I really wish the entire wire protocol were scrapped and replac=
ed with
> > > > something more sane, and easier to parse.=20
> > > You had me worried there for a moment, I thought you might be the=
 first
> > > person to admit to liking the NFS4 protocol design.
>=20
> Couldn't agree more.=20
>=20
>=20
>=20
> > In my personal opinion, version 4 of NFS is a quantum-leap improvem=
ent over
> > previous versions.  While I used NFS v3 extensively, I always felt =
it was a
> > crappy protocol, and unworthy of serious development effort. That c=
hanged with
> > v4.
> ...
> > > > It's tempting to see what would arise from a clean-slate wire p=
rotocol
> > > > effort, something that is otherwise compatible with NFS 4.x ope=
rations,
> > > > objects, and data model.
> >=20
> > It's more like v4 is a vast relative improvement over prior NFS.  G=
iven the
> > huge number of NFS users and sites, IMO v4 is a huge improvement fo=
r Unix file
> > sharing overall.
>=20
> Many years ago, before NFSv4 was finished, I felt the same. I was wai=
ting=20
> for v4 and thought that everything would be so much better. I wanted =
to=20
> help and started the "pynfs" project. Today, I have a different opini=
on. I=20
> think v3 is a fairly good protocol, if you use it correctly. For exam=
ple,=20
> many people don't realize that you don't need the portmapper, that yo=
u can=20
> use a single well-known TCP port, that you can use RPCSEC_GSS and so=20
> forth, even with v3.=20

Somehow this reminds me of IPv4 vs. IPv6. IIRC some protocol features h=
ave
in a sense been "backported" to IPv4.

--=20
=46rank
