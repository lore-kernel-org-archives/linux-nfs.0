From: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
Subject: RE: RE: 2.4.19 NFSALL performance oddity
Date: Wed, 9 Oct 2002 09:07:39 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B91653BDC7@poexmb3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail1.conoco.com ([12.31.208.226])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zHV4-0003ms-00
	for <nfs@lists.sourceforge.net>; Wed, 09 Oct 2002 07:07:46 -0700
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


I have tried it both with and without Neil's patches, they don't
make it better and don't make it worse.  Runing the server/client
tcp makes things a little bit worse.

We should be using sync on the mount option, correct? =20

All of my tests used sync on the mount and sync in the export,
previously when using async on 2.2.xx (on the export side),=20
and not using the sync option on the mount appeared to cause
issues under heavy loads, ie the out of slots warnings, and
sometimes worse.

I know from some limited testing that the sync option does
make the IO really bad on real disks.

I did look and it appears that how the sync option on the
mount command changed sometime in 2001, someplace
in the 2.4 series.

			Roger

> -----Original Message-----
> From:	Trond Myklebust [SMTP:trond.myklebust@fys.uio.no]
> Sent:	Tuesday, October 08, 2002 5:42 PM
> To:	Heflin, Roger A.
> Cc:	nfs@lists.sourceforge.net
> Subject:	Re: [NFS] RE: 2.4.19 NFSALL performance oddity
>=20
> >>>>> " " =3D=3D Roger A Heflin <Heflin> writes:
>=20
>      > Ok, I applied the new patch, it does not appear to have made
>      > any difference in my setup and tests, it also does not appear
>      > to break anything.  I am still analyzing the results, but not
>      > finding anything obvious about what is going on.  2.2.19
>      > appears to make alot better client to a 2.4.19 server than
>      > 2.4.1[89][no patch/nfsall] does.  And 2.4.19 with no patches
>      > appears to make a better server than 2.4.19 (for the writes)
>      > with the NFS patches (using 2.2.19 as a client).
>=20
> 2.4.19-NFS_ALL doesn't touch the server code unless you are also
> applying my hacked up version of Neil's experimental NFS-over-TCP
> server patches on top of the 'stock NFS_ALL'.
>=20
> The direct comparison with 2.2.19 is interesting, but only makes sense
> if you can follow up and do a binary search of 2.4.x kernels (start
> off by testing something like 2.4.9, say) in order to find out where
> the performance drop occurs. I simply wouldn't know where to start
> looking otherwise...
>=20
> Note that on my own setups, I'm seeing performance numbers with
> 2.4.19-NFS_ALL clients against both Linux 2.4.19 servers and Sun
> Solaris servers of the same order as your 2.2.19 numbers...
>=20
> Cheers,
>   Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
