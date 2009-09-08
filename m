From: Pacho Ramos <pacho-wnk7FUYfzmtu2DZcH3qp6zJQgOOX0AMFMQBsIrBqeMw@public.gmane.org>
Subject: Re: umount -a -f -t nfs doesn't work when a file has been written
 and "-l" option is needed
Date: Tue, 08 Sep 2009 19:54:38 +0200
Message-ID: <1252432478.30628.5.camel@localhost>
References: <1252139498.14467.12.camel@localhost>
	 <4AA65ECF.2070701@RedHat.com>
Reply-To: pacho-wnk7FUYfzmtu2DZcH3qp6zJQgOOX0AMFMQBsIrBqeMw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp02.jazztel.es ([62.14.3.171]:35285 "EHLO smtp02.jazztel.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751978AbZIHRyk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Sep 2009 13:54:40 -0400
In-Reply-To: <4AA65ECF.2070701-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

El mar, 08-09-2009 a las 09:40 -0400, Steve Dickson escribi=C3=B3:
> On 09/05/2009 04:31 AM, Pacho Ramos wrote:
> > I suffer the following problem with nfs since a lot of time, now, I=
 am
> > using nfs-utils-1.2.0, but older versions were affected too.
> >=20
> > When I write a file on a mounted nfs filesystem and server goes dow=
n, I
> > am unable to umount it even with "-f" option, it simply hangs. On t=
he
> > other hand, if no file was written (for example, it was simply read=
)
> > there is no problem and "umount -f" works as expected.
> I believe 'umount -f' waits for all the async or sync (I can't rememb=
er)
> RPC tasks to complete before returning... That's the reason for the h=
ang.
>=20
> >=20
> > Seems that I need to run "umount -l" for being able to unmount it, =
even
> > when I expected that "-f" should be enough.
> Hopefully you will be rebooting soon since kernel structures (ala the
> super block) are not cleaned up with 'umount -l'. Which could make th=
e
> system somewhat unstable.=20
>=20
> >=20
> > Is this the proper behavior or something is going wrong?
> Its the known behaviour... whether its correct or not is up to
> interpretation... ;-) Meaning, 'umount -f' probably should
> not hang waiting for I/O to finish, but error-ing on the "lets=20
> do everything we can not to corrupt data" is not a bad stand either..=
=2E
>=20
> steved.
>=20

Thanks a lot for the info :-)

