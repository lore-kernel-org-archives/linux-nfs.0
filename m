From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: read-error on utmp file
Date: Fri, 03 Sep 2004 12:52:00 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094230320.8196.32.camel@lade.trondhjem.org>
References: <41383991.1020108@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C3HII-0000Qz-Ci
	for nfs@lists.sourceforge.net; Fri, 03 Sep 2004 09:52:10 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C3HIH-0008En-PD
	for nfs@lists.sourceforge.net; Fri, 03 Sep 2004 09:52:10 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <41383991.1020108@bio.ifi.lmu.de>
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

P=E5 fr , 03/09/2004 klokka 05:29, skreiv Frank Steiner:

> One of the two loops immediately aborts with "unknown". Looking at
> strace I can see this:
>=20
> ...
> 9377  open("/var/run/utmp", O_RDWR)     =3D 5
> 9377  fcntl64(5, F_GETFD)               =3D 0
> 9377  fcntl64(5, F_SETFD, FD_CLOEXEC)   =3D 0
> 9377  _llseek(5, 0, [0], SEEK_SET)      =3D 0
> 9377  brk(0)                            =3D 0x804a000
> 9377  brk(0x806b000)                    =3D 0x806b000
> 9377  brk(0)                            =3D 0x806b000
> 9377  alarm(0)                          =3D 0
> 9377  rt_sigaction(SIGALRM, {0x40147da0, [], SA_RESTORER, 0x40067aa8}, {S=
IG_DFL}, 8) =3D 0
> 9377  alarm(1)                          =3D 0
> 9377  fcntl64(5, F_SETLKW, {type=3DF_RDLCK, whence=3DSEEK_SET, start=3D0,=
 len=3D0}) =3D 0
> 9377  read(5, "\2\0\0\0\0\0\0\0~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..=
., 384) =3D 384
> 9377  fcntl64(5, F_SETLKW, {type=3DF_UNLCK, whence=3DSEEK_SET, start=3D0,=
 len=3D0}) =3D 0
> 9377  alarm(0)                          =3D 1
> 9377  rt_sigaction(SIGALRM, {SIG_DFL}, NULL, 8) =3D 0
> 9377  alarm(0)                          =3D 0
> 9377  rt_sigaction(SIGALRM, {0x40147da0, [], SA_RESTORER, 0x40067aa8}, {S=
IG_DFL}, 8) =3D 0
> 9377  alarm(1)                          =3D 0
> 9377  fcntl64(5, F_SETLKW, {type=3DF_RDLCK, whence=3DSEEK_SET, start=3D0,=
 len=3D0}) =3D 0
> 9377  read(5, 0x401706e0, 384)          =3D -1 EIO (Input/output error)

Binary "tcpdump -s 9000" please?

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
