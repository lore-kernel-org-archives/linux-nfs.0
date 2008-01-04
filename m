From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>
Subject: Re: A new NFSv4 server...
Date: Fri, 4 Jan 2008 10:15:11 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801031332060.18129@maggie.lkpg.cendio.se>
References: <477CD231.30603@garzik.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-844506634-1199363527=:18129"
Cc: NFS list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.cendio.se ([193.12.253.69]:62460 "EHLO mail.cendio.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753640AbYADJeL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2008 04:34:11 -0500
In-Reply-To: <477CD231.30603@garzik.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-844506634-1199363527=:18129
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0801031459002.20565-K9BqGu7AvB3wj5YHdwD3Ga2PxDmRETKR@public.gmane.org>


[About your implementation]

> In case some developers are interested...  I'm poking at a from-scratch
> userland NFSv4 server, as a side project.

Cool! Being one of the unfs3 developers, I believe that userland NFS=20
servers are very useful.=20


> In the first step down this long path, I've created an NFSv4 userland ser=
ver
> from scratch.  Currently it merely serves data straight from RAM, but the=
 long

Do you know about the n4 project
(http://cvs.samba.org/cgi-bin/cvsweb/n4/) ? It was abandon many years
ago, but might have some usefulness.=20


> term goal is to permit modular storage backends.  Thus you could implemen=
t a
> simple RAM backend, an sqlite-based backend or a complex distributed stor=
age
> backend.

unfs3 has a basic modular backend system. I wonder if it would be
possible to merge your server with unfs3, and still have something
that's readable. If you are interested, take a look at
http://cvs.lysator.liu.se/viewcvs/viewcvs.cgi/unfs3/?root=3Dunfs3.


Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Wallenbergs gata 4
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-844506634-1199363527=:18129--
