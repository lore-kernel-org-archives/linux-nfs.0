From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: async vs. sync
Date: Tue, 27 Jul 2004 15:00:31 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200407271500.38074.bernd-schubert@web.de>
References: <482A3FA0050D21419C269D13989C61130435E51E@lavender-fe.eng.netapp.com> <200407270006.08581.bernd-schubert@web.de> <410643C5.3040004@bruvoll.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-02=_1HlBB42++M9RCSk";
  charset="iso-8859-1"
Cc: NFS mailling list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpRZd-0003jU-4N
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 06:00:53 -0700
Received: from smtp07.web.de ([217.72.192.225])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BpRZc-00006l-Cg
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 06:00:53 -0700
To: Jan Bruvoll <jan@bruvoll.com>
In-Reply-To: <410643C5.3040004@bruvoll.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--Boundary-02=_1HlBB42++M9RCSk
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

> >>My set-up has about the same performance data, however my big problem is
> >>that the server dies when I hook all my clients up... Raw throughput
> >
> >Fortunately that doesn't seem to happen in our case.
>
> Let me clarify - the server doesn't quite die, however it slows down
> drastically, having a load of ~7 while 99% CPU idle. The clients clog
> up, and for instance trying to mount anything just times out. If I
> unmount the busy share from the clients, everything settles down again.

We noticed a higher load with sync-mounts, usually we have 0-2, with 2.4. a=
nd=20
sync-mounts it went until 3-4. But we also only used sync mounts for less=20
than 24, so changed to async mounts as soon as the people complained.

[snip]

>
> I tried a little more performance number hunting:
>  - NFS copy and write to same device - 3Mb/s sustained (500Mb file)
>  - piozone direct write to RAID device - ~34-50Mb/s (depending on file
> size) - drbd network device - 933Mb/s
>
> Nothing really wrong here I'd say - not blazingly quick, but surely
> nothing to explain why everything just stops when I hook up my 12
> clients to this set-up?

Certainly not. We have 45 diskless booting clients.

[snip]

> >Well, as I said, when I tested our old server with sync mounts, it had t=
he
> >same problem. Are you sure that your old server did not export
> > asynchronous?
>
> Doesn't seem so, no, the /etc/export is -extremely- simple:
>
> /export client1(rw,no_root_squash)

Which nfs-utils version is running on that server? With 1.0 the default=20
changed from async to sync. I guess you only did security updates from your=
=20
distribution and so there's <=3D0.3 installed.

With 2.6.7 it helped us a lot to give the no_wdelay option, maybe you shoul=
d=20
try it as well.

>
> Similarly, I'm not trying to be clever on the client side (/etc/fstab
> excerpt):
>
> server:/export /export nfs rw,hard,intr 0 0

You should make sure, that rsize and wsize are set to 8192 (cat /proc/mount=
s=20
tells you the current value). Also, just try to use tcp-mounts, if you have=
=20
an asynchronous net (e.g. the server and switch have a GBit interface, but=
=20
the clients only 100MBit) this is necessary anyway. The same if the clients=
=20
or server are using linux-2.6.x.


Cheers,
	Bernd

--Boundary-02=_1HlBB42++M9RCSk
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBBlH1C8BUnAF+ydYRAgHHAJ0Q6SLCiZf5KUP1l9DC4hluSsPrygCfeXUX
dXmySI8g5AP9qrM/wzkemws=
=RALf
-----END PGP SIGNATURE-----

--Boundary-02=_1HlBB42++M9RCSk--


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
