From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: inotify and nfsd exported filesystem
Date: Tue, 22 Jan 2008 15:40:05 -0500
Message-ID: <20080122204005.GM24697@fieldses.org>
References: <120349239@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: devzero-S0/GAf8tV78@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47006 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752541AbYAVUkG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jan 2008 15:40:06 -0500
In-Reply-To: <120349239-S0/GAf8tV78@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 22, 2008 at 09:36:57PM +0100, devzero-S0/GAf8tV78@public.gmane.org wrote:
> i was only testing for IN_OPEN and IN_CLOSE_NOWRITE  ( http://inotify=
-tools.sourceforge.net/api/inotifytools_8h.html )

Something like CLOSE_NOWRITE is not in general going to be reliable,
because, for obvious performance reasons, the client doesn't necessaril=
y
always tell the server every time an application opens or closes a file=
=2E

> can do more in depth test tomorrow.

Thanks.

--b.

>=20
>=20
> > -----Urspr=C3=BCngliche Nachricht-----
> > Von: "J. Bruce Fields" <bfields@fieldses.org>
> > Gesendet: 22.01.08 21:29:42
> > An: devzero-S0/GAf8tV78@public.gmane.org
> > CC: linux-nfs@vger.kernel.org
> > Betreff: Re: inotify and nfsd exported filesystem
>=20
>=20
> >=20
> > On Tue, Jan 22, 2008 at 09:26:24PM +0100, devzero-S0/GAf8tV78@public.gmane.org wrote:
> > > hello !
> > >=20
> > > it seems that accessing a file via knfsd exported filesystem does=
n`t
> > > create an appropriate event with inotify-tools, i.e. i cannot "se=
e"
> > > that this file has been accessed.
> >=20
> > What do you mean by "accessing"--is it just reads that are missed?
> > Writes as well?  Other kinds of modications of the filesystem?
> >=20
> > --b.
> >=20
> > > no problems if acess that file on the same machine via userspace =
- but
> > > accessing from a remote box via nfs just fails.
> > >=20
> > > can somebody confirm this issue?
> > >=20
> > > is this by design or is this a bug?
> >=20
>=20
>=20
> _____________________________________________________________________=
____
> In 5 Schritten zur eigenen Homepage. Jetzt Domain sichern und gestalt=
en!=20
> Nur 3,99 EUR/Monat! http://www.maildomain.web.de/?mc=3D021114
>=20
