From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [NFS] Re: broken umount -f
Date: Tue, 14 Jan 2003 07:56:12 -0800
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D551E8@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: =?iso-8859-1?Q?=27Peter_=C5strand=27?= <peter@cendio.se>
List-ID: <nfs.lists.sourceforge.net>

"umount -f" doesn't end pending RPCs.  if there are processes
with pending RPCs, then they are stuck and you will have to
reboot.  "intr" may allow some of these processes to be killed
before trying the "umount."

however, if there are no outstanding RPCs on the client, but
the server is not available, umount -f works as advertised.

> -----Original Message-----
> From: Peter =C5strand [mailto:peter@cendio.se]=20
> Sent: Monday, January 13, 2003 4:45 AM
> To: Trond Myklebust
> Cc: nfs@lists.sourceforge.net; linux-kernel@vger.kernel.org
> Subject: [NFS] Re: broken umount -f
>=20
>=20
> >>For as long as I remember, umount -f has been broken. I got=20
> a reminder=20
> >>of this fact today when we took an older NFS server out of=20
> use. I had=20
> >>to reboot almost all machines that had mounts from this server. Not=
=20
> >>nice.
>=20
> ...
>=20
> > AFAICS It works for me.
> >=20
> > Are you using the 'intr' mount option,
>=20
> Yes, as often I can. But IMHO, it should be possible to=20
> unmount an unreachable NFS fs even if it wasn't mounted with=20
> "intr". Otherwise we have a quite silly "sysadmin trap".
>=20
> >and are you remembering to kill
> > those processes that are actually using the mount point first?
>=20
> One some machines, I killed more or less everything. It=20
> didn't help. One some other machines, I couldn't kill so=20
> blindly. Remember, both "lsof" and "fuser" hangs.
>=20
> Also, as far as I understand, Solaris 8 does not require that=20
> you kill all processes before unmounting, if you use the "-f"=20
> flag (processes will get EIO). Would it be possible to=20
> implement this feature in Linux? That would be really nice.
>=20
> Regards, Peter
>=20
>=20
> >>For as long as I remember, umount -f has been broken. I got=20
> a reminder=20
> >>of this fact today when we took an older NFS server out of=20
> use. I had=20
> >>to reboot almost all machines that had mounts from this server. Not=
=20
> >>nice.
> >>
> >>Anyone knows why -f does not work? When I try, I get:
> >>
> >># umount -f /import/applix Cannot MOUNTPROG RPC: RPC: Port mapper=20
> >>failure - RPC: Unable to receive umount2: Device or resource busy
> >>umount: /import/applix: device is busy
> >>
> >>lsof and fuser hangs, as do "df" and "du". Really frustrating. It's=
=20
> >>not even possible to cleanly reboot the system, since=20
> RedHats shutdown=20
> >>scripts wants to unmount NFS fs's.
> >>
> >>I'm not exactly sure I understand what -f is supposed to do. Is it=20
> >>correct that it is supposed to unmount without contacting the NFS=20
> >>server? I assume that I still have to make sure no=20
> processes are using=20
> >>the FS? Would it be possible to add a "-9" flag (or something like=20
> >>that) that kills off all processes that uses the NFS fs=20
> automatically?
> >>
> >>(I'm using all kinds of RedHat Linux versions, from 5.0 up to 7.3.=20
> >>From what I can tell, this problems exists in all versions.)
> >>
>=20
>=20
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.NET email is sponsored by: FREE  SSL Guide from=20
> Thawte are you planning your Web Server Security? Click here=20
> to get a FREE Thawte SSL guide and find the answers to all=20
> your  SSL security issues.=20
> http://ads.sourceforge.net/cgi-> bin/redirect.pl?thaw0026en
>=20
>=20
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net=20
> https://lists.sourceforge.net/lists/listinfo/n> fs
>=20
