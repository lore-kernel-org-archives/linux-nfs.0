From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: RE: Stale mounts - very nasty
Date: Wed, 14 May 2003 11:27:07 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B916A3293A@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailman1.ppco.com ([138.32.33.10])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Fz61-0005IN-00
	for <nfs@lists.sourceforge.net>; Wed, 14 May 2003 09:27:13 -0700
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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


We don't have tcpdump of it, I don't know if we can get one,
but I will see.

The only thing I am coming up with is that we regenerate the exports
files and do a "exportfs -r" every so often (to automatically add new=20
hosts), and the failure *may* correspond with this happening, though
I can confirm that the exports file was the same before and after
in these cases, and that we never did a exportfs -r on a blank file
( I have copies all of the previous versions of the exports file)
I have checked and the problem seems to occur more often than
the above, but I am not absolutely sure.   I have tightened up that
script so it only replaces the exports file and does the update
when when the file is going to actually change, we will see if
this reduces the problem.

I have checked the startup order on the linux box and it is ok,
the rc script runs exportfs -r and then later starts the nfsd's.

The Sun startup is unknown it is using failover and other things
and has the script in a nonstandard place, I suspect that you
may be correct here, and that it may be starting nfs and=20
assuming the proper hostname to answer and reject nfs
mounts before the proper exportfs/shareall runs.  Someone=20
is going to carefully check this to verify its behavior.

If the Sun server export case is wrong, the Sun clients seems to still
retry after it gets a stale, as the sun clients have been comfirmed
to have received the stale message, but recovered without
intervention by any admins, or a reboot.   Can anyone else
comfirm that this appears to be the case?  This is with Solairs 8.

                              Roger




> -----Original Message-----
> From:	Trond Myklebust [SMTP:trond.myklebust@fys.uio.no]
> Sent:	Wednesday, May 14, 2003 10:29 AM
> To:	Heflin, Roger A.
> Cc:	nfs@lists.sourceforge.net
> Subject:	Re: [NFS] Stale mounts - very nasty
>=20
> >>>>> " " =3D=3D Roger A Heflin <Heflin> writes:
>=20
>      > Guys, I have one of these, where it went into this state in the
>      > middle of a copy, ie part of the a file got copied and then the
>      > nfs partition when into this broken state, all with the server
>      > doing nothing bad.
>=20
>      > And I have now confirmed that it does it against Sun Solaris 8
>      > servers, which makes it look like a client problem, and not a
>      > server problem.
>=20
> Mind showing us a tcpdump of a copy that fails? I don't buy that
> 'server doing nothing bad' theory without proof.
>=20
> Under a reboot, the server may indeed use ESTALE to deny access to
> files. Normally you ensure that this doesn't happen by killing nfsd
> before you unexport the mounts, and by re-exporting before you start
> nfsd (see the NFS list archives about the 'exportfs' ordering bugs in
> older versions of nfs-utils).
>=20
> If the server does return ESTALE, then the client is perfectly correct
> in assuming that is a fatal error.
>=20
> Cheers,
>   Trond


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
