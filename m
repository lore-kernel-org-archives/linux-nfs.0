From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>
Subject: Re: A new NFSv4 server...
Date: Fri, 4 Jan 2008 10:15:00 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801040954070.5004@maggie.lkpg.cendio.se>
References: <477CD231.30603@garzik.org> <20080103163200.GB30029@fieldses.org>
 <477DC501.3060104@garzik.org> <477DD11B.40909@melbourne.sgi.com>
 <477DDA86.6020100@garzik.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-1449662124-1199436984=:5004"
Cc: NFS list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.cendio.se ([193.12.253.69]:62459 "EHLO mail.cendio.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753310AbYADJeL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2008 04:34:11 -0500
In-Reply-To: <477DDA86.6020100@garzik.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-1449662124-1199436984=:5004
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0801040956351.5004-K9BqGu7AvB3wj5YHdwD3Ga2PxDmRETKR@public.gmane.org>


[About v4]


On Fri, 4 Jan 2008, Jeff Garzik wrote:

> > > I really wish the entire wire protocol were scrapped and replaced wit=
h
> > > something more sane, and easier to parse.=20
> > You had me worried there for a moment, I thought you might be the first
> > person to admit to liking the NFS4 protocol design.

Couldn't agree more.=20



> In my personal opinion, version 4 of NFS is a quantum-leap improvement ov=
er
> previous versions.  While I used NFS v3 extensively, I always felt it was=
 a
> crappy protocol, and unworthy of serious development effort. That changed=
 with
> v4.
=2E..
> > > It's tempting to see what would arise from a clean-slate wire protoco=
l
> > > effort, something that is otherwise compatible with NFS 4.x operation=
s,
> > > objects, and data model.
>=20
> It's more like v4 is a vast relative improvement over prior NFS.  Given t=
he
> huge number of NFS users and sites, IMO v4 is a huge improvement for Unix=
 file
> sharing overall.

Many years ago, before NFSv4 was finished, I felt the same. I was waiting=
=20
for v4 and thought that everything would be so much better. I wanted to=20
help and started the "pynfs" project. Today, I have a different opinion. I=
=20
think v3 is a fairly good protocol, if you use it correctly. For example,=
=20
many people don't realize that you don't need the portmapper, that you can=
=20
use a single well-known TCP port, that you can use RPCSEC_GSS and so=20
forth, even with v3.=20


I think v4 has a few valuable improvements, but it comes with a very high=
=20
price. v3 has a minimalistic beauty which v4 lacks. For example, take a=20
look at the OPEN operation with 7 arguments, of which many are complex=20
data structures:

    (cfh), seqid, share_access, share_deny, owner, openhow, claim ->
    (cfh), stateid, cinfo, rflags, open_confirm, attrset delegation

Not pretty... =20



> Oh, certainly.  I was mainly thinking a replacement of the wire protocol =
would
> be an easier step for people to swallow than a new protocol.

I've been thinking of trying to put together something like NFS v3.5. Some=
=20
parts of v4 are nice, but the complexity is too high.=20


Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Wallenbergs gata 4
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-1449662124-1199436984=:5004--
