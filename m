From: Dan Yocum <yocum@fnal.gov>
Subject: Re: RPC: Unable to allocate resbuf from cache! - revisited
Date: Mon, 06 Jan 2003 10:29:37 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E19AEF1.6060702@fnal.gov>
References: <3E15A708.50102@fnal.gov> <shslm1ysmfd.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Cc: nfs list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from heffalump.fnal.gov ([131.225.9.20] helo=fnal.gov)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Va8A-0005NN-00
	for <nfs@lists.sourceforge.net>; Mon, 06 Jan 2003 08:29:38 -0800
Received: from fnal.gov ([131.225.7.82]) by smtp.fnal.gov (PMDF V6.0-24 #37519)
 with ESMTP id <0H8A005IZWHD6A@smtp.fnal.gov> for nfs@lists.sourceforge.net;
 Mon, 06 Jan 2003 10:29:37 -0600 (CST)
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Yes, the error message is on the server system and it is running 2.4.18+X=
FS.

I guess I didn't realize that the error message is being created by the c=
lient.

Dan


Trond Myklebust wrote:
>>>>>>" " =3D=3D Dan Yocum <yocum@fnal.gov> writes:
>>>>>
>=20
>      > Hi all, Looking back at the archives
>      > (http://marc.theaimsgroup.com/?t=3D101707335800002&r=3D1&w=3D2) =
I see
>      > that you (Trond) say that these copious "RPC: Unable..."=20
>      > messages shouldn't be a problem.  Could they be a problem?
>=20
>=20
>      > The reason I ask is, occassionally, we're getting these strange
>      > files created with 0 size, date, and some gobble-dee-gook
>      > names, and they just so happen to show up when we get this
>      > error message in the logs.  Here's what one looks like:
>=20
>=20
>      > bash-2.04$ ls -l |egrep -v '(fit|ps|fp|mem)' total 5742612
>      > -rwxr-xr-x 1 jen_a sdss 0 Dec 31 1969 :N=A8TL8=D5 =E4=F0=FF=FF=EB=
=FE=FF=F5@ =A6,
>=20
>      > The rest of the files are OK, but this is slightly
>      > disconcerting.
>=20
> That's totally unrelated to the above message, and looks rather like a
> server bug. Is the server also 2.4.18+XFS?
>=20
> Cheers,
>   Trond
>=20


--=20
Dan Yocum
Sloan Digital Sky Survey, Fermilab  630.840.6509
yocum@fnal.gov, http://www.sdss.org
SDSS.  Mapping the Universe.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
