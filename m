From: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
Subject: 2.4.18 disk i/o load spikes
Date: Fri, 17 May 2002 08:59:51 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <49CA7FE2A83A33459A2CD27E99E90EFB0BAE9C@poexmb1.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <jeff@atheros.com>,
	<ewhiting@amis.com>,
	<rsweet@atos-group.nl>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail1.conoco.com ([12.31.208.226])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178iGx-0003qS-00
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 06:59:55 -0700
To: <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>



	Ryan,

	When you run it with the 10 streams, that is on the local disk with
	no nfs?   And also, besides the load rising, what happens to the
	io rates when things start to spiral?   I have not been able to =
duplicate
	it under 2.4.19 with the latest NFS patches with limited testing.

	I am the author of slowspeed.c, I have been able to duplicate it
	on 2.2.19 with nfs, I believe I was able to duplicate it on a local
	disk with no nfs, but I cannot duplicate things slowing down
	always with things on the local disk.   On 2.2.19 it looks like
	a interaction between NFS and the kernel buffer cache, because
	the machine completely stops responding when this happens.

						Roger


> Message: 10
> Date: Fri, 17 May 2002 11:46:51 +0200 (MEST)
> From: Ryan Sweet <rsweet@atos-group.nl>
> Reply-To: Ryan Sweet <rsweet@atos-group.nl>
> To: Jeff Smith <jeff@atheros.com>
> cc: Eric Whiting <ewhiting@amis.com>, <nfs@lists.sourceforge.net>,
>    Ryan Sweet <rsweet@atos-group.nl>
> Subject: Re: [NFS] 2.4.18 disk i/o load spikes was: re: knfsd load =
spikes
>=20
>=20
> I did some additional testing, and in my case I do not think the =
problem
> I am having is nfs related.  Thus perhaps we can move this discussion =
to
> lkml.  I will probably post a summary there later today.
>=20
> I can reproduce the issue at will when the file server is not busy =
using
> the slowspeed.c program that was attached in  previous message.
>=20
> If I run it with 10 streams at 65k against the external RAID array
> (adaptec 29160 controller), it will eventually (within 20 minutes) =
spiral
> into severe pain (load > 30).
>=20
> Looking at /proc/scsi/aic7xxx/2, I can see that the Commands Active is
> always pegged at 8.  The Command Openings reads 245 (the controller =
depth
> of 253-8). Looking at the kernel config, the aic7xx driver was built =
with
> the old default TCQ depth of 8, but it should really be 253 (I think).
>=20
> I tested another system, slower, only single cpu, but with the same
> controller.  I used the same kernel and could easily reproduce the =
problem
> with about 6 streams.  Then I rebuilt the same kernel only changed the =
TCQ
> depth to 253.   In that configuration the system does very well up to
> about 20 - 25 streams, at which point it starts to wait too long.  =
Looking
> in /proc/scsi/aic7xx on that system the Commands Active is pegged at =
64,
> and Command Openings at 0.  When the system is idle, Command Openings =
is
> at 64.  Note that I can still cause the problem to happen with 20+ =
streams
> of I/O.  That hardly seems optimal.
>=20
> So first on my list is to reboot the filer with the aic7xxx set to TCQ
> depth of 253.
>=20
> My questions are still:
> 1) Why if the kernel (as reported by dmesg) has the TCQ set to 253, =
does
> it cap it at 64?
>=20
> 2) What causes it to spiral to unusable loads when the TCQ is full?
>=20
>=20
>=20
> --=20
> Ryan Sweet <ryan.sweet@atosorigin.com>
> Atos Origin Engineering Services
> http://www.aoes.nl
>=20
>=20
>=20
>=20
>=20
> --__--__--
>=20
> Message: 11
> From: Alexander Thiel <alex.lists@freenet.de>
> Reply-To: alex.lists@freenet.de
> To: David LeBard <david.lebard@asu.edu>, nfs@lists.sourceforge.net
> Subject: Re: [NFS] Newbie at NFS
> Date: Fri, 17 May 2002 12:20:27 +0200
>=20
> On Thursday 16 May 2002 18:31, David LeBard wrote:
> > I am new to nfs and to this list, so please excuse my obvious =
ignorance.
> >
>=20
> In that case you may want to have a look at the NFS Howto at
> http://nfs.sourceforge.net/nfs-howto
>=20
> Alex
>=20
>=20
> --__--__--
>=20
> Message: 12
> Date: Fri, 17 May 2002 15:27:07 +0000 (UTC)
> From: Abhas Abhinav <abhas@deeproot.co.in>
> To: Neil Brown <neilb@cse.unsw.edu.au>
> cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
> Subject: Re: [NFS] Error: RPC request reserved 244 but used 248
>=20
> On Fri, 17 May 2002, Neil Brown wrote:
>=20
> >--|> client and the server are running 2.4.8. The server uses =
ReiserFS for
>                                      ^^^^^^^^^^>=20
> 							This was "small" typo - it should've been
> 							2.4.18!
>=20
> >--|It means that I can't count, and that the patch you have is a bit
> >--|out-of-date.
> >--|The latext -ac patch should work fine.
> >--|
> >--|I probably wont be putting out another complete NFS patch until =
2.4.19
> >--|comes out.
>=20
> I patched the server kernel using the patch-Bd-NfsdAll for 2.4.18 that =
I
> downloaded from cse.unsw.edu.au. So I guess I am using your latest
> patches. The client was patched using 2.4.18 + Trond's NFS client
> patch linux-2.4.18-NFS_ALL.dif. Other than that both the server and =
the
> client were patched for reiserfs quota support (Chris Mason's =
patches).
>=20
> All these patches were downloaded during the last 14 hours...
>=20
> I am basically looking at test NFS-TCP support for a file server =
design
> for a mail server. We're using reiserfs throughout.
>=20
> Would the -ac tree be stable enough to experiment with this? And are
> there any major advantages in using -ac tree or can I get away with
> using 2.4.18-stable.
>=20
> thanks for your help,
> abhas.
>=20
> --=20
> -------------------------------------------------------------------
> Abhas Abhinav		   | Free Software at its product-ive best.
> CEO, DeepRoot Linux
> http://www.deeproot.co.in           ---- Server Appliances ----
> Ph: +91 (80) 856 5624          ---- Linux Support and Services ----
> -------------------------------------------------------------------
>=20
>=20
>=20
> --__--__--
>=20
> Message: 13
> From: "Tina Arora" <tinaarora@hotmail.com>
> To: <nfs@lists.sourceforge.net>
> Date: Fri, 17 May 2002 16:35:21 +0530
> Subject: [NFS] cache clear
>=20
> This is a multi-part message in MIME format.
>=20
> ------=3D_NextPart_000_0029_01C1FDC0.D68AE6E0
> Content-Type: text/plain;
> 	charset=3D"iso-8859-1"
> Content-Transfer-Encoding: quoted-printable
>=20
> When I copy a file(which is NFS mounted)  on my client it takes =
approx. =3D
> 11 sec .but when I copy the same file again into another file with a =
=3D
> different name it takes merely 0.045 sec this is coz it picks from the =
=3D
> cache of the client .How to clear the cache..
> tina=3D20
>=20
>=20
> ------=3D_NextPart_000_0029_01C1FDC0.D68AE6E0
> Content-Type: text/html;
> 	charset=3D"iso-8859-1"
> Content-Transfer-Encoding: quoted-printable
>=20
> <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
> <HTML><HEAD>
> <META http-equiv=3D3DContent-Type content=3D3D"text/html; =3D
> charset=3D3Diso-8859-1">
> <META content=3D3D"MSHTML 6.00.2600.0" name=3D3DGENERATOR>
> <STYLE></STYLE>
> </HEAD>
> <BODY bgColor=3D3D#ffffff>
> <DIV>
> <DIV><FONT face=3D3DArial size=3D3D2>When I copy a file(which is NFS =
=3D
> mounted)&nbsp; on=3D20
> my client it takes approx. 11 sec .but when I copy the same file again =
=3D
> into=3D20
> another file with a different name it takes merely 0.045 sec this is =
coz =3D
> it=3D20
> picks from the cache of the client .How to clear the =3D
> cache..</FONT></DIV>
> <DIV><FONT face=3D3DArial size=3D3D2>tina </FONT></DIV>
> <DIV>&nbsp;</DIV></DIV></BODY></HTML>
>=20
> ------=3D_NextPart_000_0029_01C1FDC0.D68AE6E0--
>=20
>=20
>=20
> --__--__--
>=20
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20
>=20
> End of NFS Digest

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
