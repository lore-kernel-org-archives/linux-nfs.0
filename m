From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>
Subject: Re: A new NFSv4 server...
Date: Fri, 4 Jan 2008 20:57:33 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801042055490.18738@maggie.lkpg.cendio.se>
References: <200801041528.KAA18776@snowhite.cis.uoguelph.ca>
 <20080104172142.GD17112@fieldses.org> <477E8E1C.9090205@garzik.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-1463249351-1199476653=:18738"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.cendio.se ([193.12.253.69]:63006 "EHLO mail.cendio.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753304AbYADT5f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2008 14:57:35 -0500
In-Reply-To: <477E8E1C.9090205@garzik.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-1463249351-1199476653=:18738
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 4 Jan 2008, Jeff Garzik wrote:

> > Ditto.  I think it'd be great to have a variety of client and server
> > implementations available over the net, but I've had no luck talking
> > anybody else into it.
>=20
> I think blanket public access wouldn't be as effective as passworded acce=
ss to
> a cluster, much like how people get accounts on kernel.org (which is an
> excellent model for shared-interest services).
>=20
> On the test cluster, I would want to be able to really stress my software=
,
> which to any normal firewall or casual observer would look like a DoS att=
empt.

I'm not afraid of stress-tests that looks like DoS attempts. What worries=
=20
me is that a writable export will be used for sharing warez or something=20
like that.=20

Rgds,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Wallenbergs gata 4
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-1463249351-1199476653=:18738--
