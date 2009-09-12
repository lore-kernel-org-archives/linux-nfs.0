From: Pacho Ramos <pacho-wnk7FUYfzmtu2DZcH3qp6zJQgOOX0AMFMQBsIrBqeMw@public.gmane.org>
Subject: Re: umount -a -f -t nfs doesn't work when a file has been written
 and "-l" option is needed
Date: Sat, 12 Sep 2009 18:25:28 +0200
Message-ID: <1252772728.32258.1.camel@localhost>
References: <20090912150107.GE5858@ZenIV.linux.org.uk>
Reply-To: pacho-wnk7FUYfzmtu2DZcH3qp6zJQgOOX0AMFMQBsIrBqeMw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp01.jazztel.es ([62.14.3.170]:45576 "EHLO smtp01.jazztel.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753553AbZILQZb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 Sep 2009 12:25:31 -0400
In-Reply-To: <20090912150107.GE5858@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

El s=C3=A1b, 12-09-2009 a las 16:01 +0100, Al Viro escribi=C3=B3:
> > > Seems that I need to run "umount -l" for being able to unmount it=
, even
> > > when I expected that "-f" should be enough.
> > Hopefully you will be rebooting soon since kernel structures (ala t=
he
> > super block) are not cleaned up with 'umount -l'. Which could make =
the
> > system somewhat unstable.=20
>=20
> Um...  Not really.  The damn thing is detached from the namespace and
> left alone until it's not busy anymore.  At that point it's hit with =
the
> rest of umount() (i.e. with filesystem driver being told to shut it d=
own).
>=20
> So it won't go away in that case, but you shouldn't get any instabili=
ty from
> that - from the VFS POV nothing nasty has happened, from the NFS clie=
nt
> code POV... well, it's not being unmounted yet, as far as NFS code ca=
res.
> Just a mounted fs from a stuck server...

OK :-)

Anyway, I am running this just before halting system , to prevent
suffering the hang when powering off my computer ;-)

Thanks!

