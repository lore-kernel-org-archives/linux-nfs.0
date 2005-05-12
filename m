From: "Edward Hibbert" <Edward.Hibbert@dataconnection.com>
Subject: RE: Memory usage
Date: Thu, 12 May 2005 07:56:06 +0100
Message-ID: <9E621559095AA746B22B21CD4FAF99A50FA4BC@EDINMAIL1.ad.datcon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "Sean Dogar" <sean@catfeeder.net>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DW7cG-0000yx-7F
	for nfs@lists.sourceforge.net; Wed, 11 May 2005 23:56:16 -0700
Received: from smtp.dataconnection.com ([192.91.191.4])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DW7cF-00036G-Hs
	for nfs@lists.sourceforge.net; Wed, 11 May 2005 23:56:16 -0700
To: "Neil Horman" <nhorman@redhat.com>, "liz" <liz@unixgrrl.net>
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

We've seen similar problems with 2.4 kernels, where the cache grows and =
starts swapping processes out causing atrocious performance. =20

We didn't find any solution on a 2.4 kernel (I'm not saying there isn't =
one - just that the various tuning parameters we tried didn't do it for =
us) and after considerable effort gave up and switched to a 2.6 kernel.  =


Regards,

Edward.

-----Original Message-----
From: nfs-admin@lists.sourceforge.net
[mailto:nfs-admin@lists.sourceforge.net]On Behalf Of Neil Horman
Sent: 11 May 2005 14:42
To: liz
Cc: Sean Dogar; nfs@lists.sourceforge.net
Subject: Re: [NFS] Memory usage


On Tue, May 10, 2005 at 08:07:52PM -0700, liz wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>=20
> NFS server.
>=20
> We have a box running as a NFS server and a mysql server. What were
> running into is that we have a large amount of memory being sucked up
> by cache and the box is swapping like crazy. It doesnt seem to be
> release the cache back so im stumped. The only thing using memory is
> mysql.
>=20
> All we can think of is the NFS server is using kernel cache for
> caching (a reach i know)
>=20
>=20
Depending on how frequently your NFS client accesses its file data in =
cache,
swapping process pages may be the logical thing to do.  But if not, you =
can, in
the 2.4.21 RHEL kernels use the pagecache sysctl to help reduce =
pagecache usage more
quickly when under VM pressure.  Note that in 2.4.21, setting =
pagecache.max does
not place a cieling on how much memory is used for pagecache, it just =
sets
policy for where memory should be reclaimed from first when needed. Its =
all in
the paper that Seth Referenced.

Hope that helps
Neil

> |~        total:    used:    free:  shared: buffers:  cached:
> |Mem:  4224462848 4206002176 18460672        0 41304064 2938032128
> |Swap: 2146754560 1073373184 1073381376
> |MemTotal:      4125452 kB
> |MemFree:         18028 kB
> |MemShared:           0 kB
> |Buffers:         40336 kB
> |Cached:        2095616 kB                        <---- 2G disk cache
> |SwapCached:     773556 kB
> |Active:        3186300 kB
> |ActiveAnon:    1707252 kB
> |ActiveCache:   1479048 kB
> |Inact_dirty:    607944 kB
> |Inact_laundry:  117300 kB
> |Inact_clean:     65180 kB
> |Inact_target:   795344 kB
> |HighTotal:     3276224 kB
> |HighFree:         1200 kB
> |LowTotal:       849228 kB
> |LowFree:         16828 kB
> |SwapTotal:     2096440 kB                      <-- 1G swap usage
> |SwapFree:      1048224 kB
> |HugePages_Total:     0
> |HugePages_Free:      0
> |Hugepagesize:     2048 kB
>=20
>=20
>=20
> If it is indeed NFS is there a way to make it not do that :P I looked
> in my o'reilly book, googled and posted to kernel dev (WIth my
> asbestos jacket on and zipped up ;)
>=20
> The machine is running 2.4.21 EL-SMP
>=20
> Im completely stumped...
>=20
> Thanks for looking at it :)
>=20
> Liz
>=20
> |> How does NFS handle caching? more particularly is there a way to =
limit
> |> the memory usage for caching?
> |>
> |>
> |> Does it show up as kernel cache or is it displayed in the process
> |> list?
> |>
> | Liz,
> |
> | Are you referring to a nfs server or client?
> |
> | -Sean
> |
>=20
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.4.0 (GNU/Linux)
>=20
> iD8DBQFCgXcIlt/irWun80cRAqtaAJ9LaRgz6LN44xh9d0bbvpLizWW2egCePjTD
> QWAHmxtHMeyCOKqw3JcPVwg=3D
> =3DwkVW
> -----END PGP SIGNATURE-----
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by Oracle Space Sweepstakes
> Want to be the first software developer in space?
> Enter now for the Oracle Space Sweepstakes!
> http://ads.osdn.com/?ad_id=3D7393&alloc_id=3D16281&op=3Dclick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

--=20
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=3D7393&alloc_id=3D16281&op=3Dclick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7393&alloc_id=16281&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
