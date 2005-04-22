From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Detectiong Network and umount / mount NFS
Date: Fri, 22 Apr 2005 09:31:44 -0400
Message-ID: <1114176705.10450.43.camel@lade.trondhjem.org>
References: <1114027379.4266b57354785@webmail.tusofona.com>
	 <4266C21D.9030305@RedHat.com>
	 <1114038052.4266df245e54e@webmail.tusofona.com>
	 <1114042784.17214.11.camel@lade.trondhjem.org>
	 <Pine.LNX.4.61.0504211009380.3889@maggie.lkpg.cendio.se>
	 <1114088708.10727.9.camel@lade.trondhjem.org>
	 <Pine.LNX.4.61.0504212119170.16285@maggie.lkpg.cendio.se>
	 <1114118453.12750.44.camel@lade.trondhjem.org>
	 <Pine.LNX.4.61.0504220857510.28175@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOyGQ-0006oW-BN
	for nfs@lists.sourceforge.net; Fri, 22 Apr 2005 06:32:10 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DOyGL-0006Il-Hn
	for nfs@lists.sourceforge.net; Fri, 22 Apr 2005 06:32:10 -0700
To: Peter =?ISO-8859-1?Q?=C5strand?= <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.61.0504220857510.28175@maggie.lkpg.cendio.se>
Sender: nfs-admin@lists.sourceforge.net
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

fr den 22.04.2005 Klokka 09:12 (+0200) skreiv Peter =C3=85strand:

> > The kernel already aborts all pending I/O and returns EIO with "umount
> > -f".
>=20
> Interesting. How long has this been the case? I've never heard of it=20
> before; i thought that "-f" was only for not careing about the UMNT call.

Huh? I've never heard anyone say anything about UMNT call behaviour, nor
can I understand where you might have picked that up from the
documentation.
The behaviour of umount and umount -f should be exactly the same: if the
server doesn't respond, the call times out and the return value is
ignored.

> Perhaps the man-page could say something about this?

The manpage says

       -f     Force unmount (in case of an unreachable NFS system).  (Requi=
res
              kernel 2.1.116 or later.)

The behaviour of the kernel w.r.t. that flag has been the same since
2.1.116.

> The cat process was still hanged. When doing a second "umount -f",=20
> open("/mnt/foo") returned EIO. This time, the umount command said:
>=20
> # umount -f /mnt
> umount2: Device or resource busy
> umount: /mnt: device is bus
>=20
> One other interesting thing was that then, the kernel crashed... I'm usin=
g=20
> kernel 2.6.11-1.14_FC3.
>=20
> I'm able to reproduce this problem. I have a screen shot of the call trac=
e=20
> on http://www.cendio.se/~peter/fc3-umount-crash.png, if anyone is=20
> interested.

That's certainly an "interesting" Oops. ebp=3D0x1b, esp=3D0xc0446f98,
together with a timer list corruption. Is that running under vmware? If
so, can you reproduce with a normal kernel (no vmware module) and given
that weird value of ebp, with stack overflow checking turned on.

On my machine, the "umount -f" complains a bit about "Cannot MOUNTPROG
RPC (tcp): RPC: Program not registered", and there may be a few "device
is busy" here and there, but the umount definitely succeeds in killing
off the hanging programs, and it fails to Oops.

> >  1) That bugzilla is meant for reporting kernel bugs, not for feature
> > requests
>=20
> In my opinion, an "unkillable" process is a bug.

That's entirely _your_ personal opinion. A lot of other people will
argue that causing processes to lose data is a bug. In order to
accommodate both camps, there are mount options to allow for one or the
other behaviour, there are manpage entries, and there are FAQ entries.

--=20
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
