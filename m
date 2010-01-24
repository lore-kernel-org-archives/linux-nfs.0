From: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Subject: RE: nfs client performance while server is down
Date: Sun, 24 Jan 2010 13:34:50 -0800
Message-ID: <7A24DF798E223B4C9864E8F92E8C93EC0527810C@SACMVEXC1-PRD.hq.netapp.com>
References: <d7f0b3a81001230745h18dbb14fi42f28adff0c45294@mail.gmail.com> <1f808b4a1001230757i2027d32dxb48482ea7bf8e4ee@mail.gmail.com> <d7f0b3a81001230827y52727993nf60210ae610643b7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <linux-nfs@vger.kernel.org>
To: "Whoop Whouzer" <tiredandnumb@gmail.com>,
	"Peter Chacko" <peterchacko35@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52281 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752015Ab0AXVez convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2010 16:34:55 -0500
In-Reply-To: <d7f0b3a81001230827y52727993nf60210ae610643b7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Perhaps something in your $PATH is in the NFS mount?  Do a network trac=
e and maybe you can see if, in fact, there are actually NFS operations =
being attempted that you weren't expecting.  Then try to figure out why=
=2E

  -Dan=20

> -----Original Message-----
> From: Whoop Whouzer [mailto:tiredandnumb@gmail.com]=20
> Sent: Saturday, January 23, 2010 8:28 AM
> To: Peter Chacko
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: nfs client performance while server is down
>=20
> I don't remember all the different set-ups I tried it on, but I just
> confirmed this with the following combinations:
>=20
> ubuntu server 10.04 (alpha 2) --> ubuntu desktop 9.10, ubuntu desktop
> 10.04 (alpha 2), fedora 12
> ubuntu server 9.10 --> ubuntu desktop 9.10, ubuntu desktop 10.04
> (alpha 2), fedora 12
>=20
> I'll be happy to test it on another client machine (distro) even
> another server (although it would require a little more time)
>=20
> Here are some examples on the bugreports I noticed and how they do no=
t
> seem to get solved:
> https://bugzilla.redhat.com/show_bug.cgi?id=3D175283
> https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/164120
>=20
> regards,
> Whoop
>=20
> On Sat, Jan 23, 2010 at 4:57 PM, Peter Chacko=20
> <peterchacko35@gmail.com> wrote:
> > Which client OS you observed this behavior ? =A0This has nothing to=
 do
> > NFS design, and its purely stateless...Its upto the client OS
> > implementation about aspects like how to deal with local=20
> IO, when NFS
> > share gets =A0disconnected..
> >
> > May be a VFS bug on the local OS you found this problem ..
> >
> > thanks
> >
> > On Sat, Jan 23, 2010 at 9:15 PM, Whoop Whouzer=20
> <tiredandnumb@gmail.com> wrote:
> >> Howdy,
> >>
> >> I was wondering why nfs is designed in such a way that the=20
> performance
> >> of an nfs client machine gets very bad when the nfs server=20
> is offline?
> >> This is even the case with a soft mount (either via mount=20
> or fstab).
> >> Just about every application that requires disk access (not talkin=
g
> >> about nfs share acces) gets really slow to unresponsive.=20
> For instance
> >> nautilus becomes unresponsive when displaying the contents of any
> >> folder on the local disk,
> >> playing movie files (stored on local disk) let totem or=20
> vlc get stuck
> >> on set intervals, even the terminal becomes unresponsive at times.
> >>
> >> I could understand that these problems would occur while=20
> accessing the
> >> nfs share directoiourry while the server is offline, but=20
> why for totally
> >> unrelated directories?
> >>
> >> I have experienced this behaviour on various distro's, and=20
> also found
> >> various bug reports on this issue, they don't seem to get solved a=
s
> >> this is viewed as nfs design.
> >> I see this as a flaw because clients are totally dependent on the
> >> server. This would be less of a deal if the entire home directory
> >> would be stored on nfs (although I even think some sort of
> >> synchronisation technology could and should be implemented in this
> >> case). It is a bit odd that (technically) one machine serving some
> >> "useless" files to a non-trivial directory on client=20
> machines can take
> >> down these client machines.
> >>
> >> For me the preferred functionality would be:
> >> *If an nfs server gets offline the client's nfs share becomes
> >> unaccessible, but local directories and applications (that only
> >> require local disk access) stay responsive.
> >> *If an nfs server gets online (after being offline while the clien=
t
> >> has not been restarted) the nfs share becomes reconnected.
> >>
> >> regards,
> >> Whoop
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe=20
> linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at =A0http://vger.kernel.org/majordomo-info.ht=
ml
> >>
> >
> --
> To unsubscribe from this list: send the line "unsubscribe=20
> linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
