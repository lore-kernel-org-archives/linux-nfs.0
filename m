From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>
Subject: Re: A new NFSv4 server...
Date: Fri, 4 Jan 2008 20:58:11 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801042027520.18738@maggie.lkpg.cendio.se>
References: <477CD231.30603@garzik.org> <Pine.LNX.4.64.0801031332060.18129@maggie.lkpg.cendio.se>
 <477E5B4F.6010305@garzik.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-895943480-1199474950=:18738"
Cc: NFS list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.cendio.se ([193.12.253.69]:63007 "EHLO mail.cendio.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753308AbYADT6N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2008 14:58:13 -0500
In-Reply-To: <477E5B4F.6010305@garzik.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-895943480-1199474950=:18738
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0801042057591.18738-K9BqGu7AvB3wj5YHdwD3Ga2PxDmRETKR@public.gmane.org>

On Fri, 4 Jan 2008, Jeff Garzik wrote:

> P.S.  cvsps, the util git-cvsimport uses, doesn't seem to like the unfs3 =
CVS
> repository.  Any ideas?

Seems to work for me. I tested with:

$ cvs -d :pserver:anonymous-D0yiLyI4lD89hKwg4ls7rsugMpMbD5Xr@public.gmane.org:/cvsroot/unfs3 co unfs3
$ cd unfs3
$ cvsps=20

Using cvsps version 2.1.=20


Rgds,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Wallenbergs gata 4
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-895943480-1199474950=:18738--
