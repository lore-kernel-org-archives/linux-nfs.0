From: devzero-S0/GAf8tV78@public.gmane.org
Subject: Re: inotify and nfsd exported filesystem
Date: Tue, 22 Jan 2008 21:36:57 +0100
Message-ID: <120349239@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fmmailgate04.web.de ([217.72.192.242]:49668 "EHLO
	fmmailgate04.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087AbYAVUg7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jan 2008 15:36:59 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

i was only testing for IN_OPEN and IN_CLOSE_NOWRITE  ( http://inotify-t=
ools.sourceforge.net/api/inotifytools_8h.html )

can do more in depth test tomorrow.


> -----Urspr=FCngliche Nachricht-----
> Von: "J. Bruce Fields" <bfields@fieldses.org>
> Gesendet: 22.01.08 21:29:42
> An: devzero-S0/GAf8tV78@public.gmane.org
> CC: linux-nfs@vger.kernel.org
> Betreff: Re: inotify and nfsd exported filesystem


>=20
> On Tue, Jan 22, 2008 at 09:26:24PM +0100, devzero-S0/GAf8tV78@public.gmane.org wrote:
> > hello !
> >=20
> > it seems that accessing a file via knfsd exported filesystem doesn`=
t
> > create an appropriate event with inotify-tools, i.e. i cannot "see"
> > that this file has been accessed.
>=20
> What do you mean by "accessing"--is it just reads that are missed?
> Writes as well?  Other kinds of modications of the filesystem?
>=20
> --b.
>=20
> > no problems if acess that file on the same machine via userspace - =
but
> > accessing from a remote box via nfs just fails.
> >=20
> > can somebody confirm this issue?
> >=20
> > is this by design or is this a bug?
>=20


_______________________________________________________________________=
__
In 5 Schritten zur eigenen Homepage. Jetzt Domain sichern und gestalten=
!=20
Nur 3,99 EUR/Monat! http://www.maildomain.web.de/?mc=3D021114

