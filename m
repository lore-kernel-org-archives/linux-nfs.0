From: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Sat, 27 Sep 2008 11:16:26 +0100
Message-ID: <1222510586.3949.45.camel@localhost.localdomain>
References: <1221544139.2534.18.camel@localhost.localdomain>
	 <48CF9AC3.6060801@opengridcomputing.com>
	 <1221577412.28572.60.camel@zakaz.uk.xensource.com>
	 <48CFD7C3.5080207@opengridcomputing.com>
	 <1221582285.28572.67.camel@zakaz.uk.xensource.com>
	 <1222156770.6869.13.camel@localhost.localdomain>
	 <1222169589.6869.20.camel@localhost.localdomain>
	 <20080923170344.GC2700@fieldses.org>
	 <1222443426.3949.18.camel@localhost.localdomain>
	 <1222453053.3949.21.camel@localhost.localdomain>
	 <20080927035415.GC12765@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-AKm9JcxJpCbzAlEQClVf"
Cc: Tom Tucker <tom@opengridcomputing.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Grant Coady <gcoady.lk@gmail.com>,
	linux-kernel@vger.kernel.org, neilb@suse.de,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:16275 "EHLO
	mtaout03-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752074AbYI0KQl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Sep 2008 06:16:41 -0400
In-Reply-To: <20080927035415.GC12765@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-AKm9JcxJpCbzAlEQClVf
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2008-09-26 at 23:54 -0400, J. Bruce Fields wrote:
> OK, so apologies, but this has been a long thread, and maybe we could
> use a summary of the symptoms and the results so far.  I think you said
> 2.6.24 or .25 was the last you're *positive* was good?

2.6.24.x was good 2.6.25.y was not. The Debian packages don't include
the stable release numbers in their version so I'm unsure of x and y,
Judging from the changelog entries I think 2.6.24.3 and 2.6.25.10.=20

Since I have been building my own kernels I have seen repros with:

a551b98d5f6fce5897d497abd8bfb262efb33d2a Merge branch 'for-linus' of
git://git.kernel.dk/linux-2.6-block (was tip of git at the time I tested
it a while ago)

c02a79dedc7f3c3d4fdbb5eb2000cacea5df4cde v2.6.26.5

daedfbe2a67628a40076a6c75fb945c60f608a2e NFS: Ensure we zap only the
access and acl caches when setting new acls (backport of
f41f741838480aeaa3a189cff6e210503cf9c42d to 2.6.26.y stream, identified
by bisect, possibly/probably incorrectly)

f41f741838480aeaa3a189cff6e210503cf9c42d NFS: Ensure we zap only the
access and acl caches when setting new acls (original trunk commit of
above)

2e96d2867245668dbdb973729288cf69b9fafa66 NFS: Fix a warning in
nfs4_async_handle_error (commit before
f41f741838480aeaa3a189cff6e210503cf9c42d)

I did not see the problem with bce7f793daec3e65ec5c5705d2457b81fe7b5725
(v2.6.26) in 4 days 19 hours. Due to the apparent mis-bisection leading
to daedfbe2a67628a40076a6c75fb945c60f608a2e this result is in doubt, I'm
currently retesting this kernel.

The bisect was restricted to paths under fs/nfs* and net/sunrpc. I've
gone over the range v2.6.26..daedfbe2a67628a40076a6c75fb945c60f608a2e
and nothing jumps out at me. If my retest of 2.6.26 shows it to be OK
again I'll bisect over the non-NFS changesets in that range.

The symptoms are a hang of any access to an NFS mounted path, although
the rest of the system continues to work.=20

Other potentially interesting info cribbed from earlier postings:

While the hang is occurring rpc_debug on the server gives nothing, on
the client gives:
[144741.637997] -pid- proc flgs status -client- -prog- --rqstp- -timeout -r=
pcwait -action- ---ops--=20
[144741.637997]  3439 0004 0080    -11 f3f48200 100003 f7770000    0 xprt_s=
ending fa0ae88e fa0bddf4
[144741.637997]  3438 0001 00a0      0 f77f2a00 100003 f77700d0 5000 xprt_p=
ending fa0ae88e fa0bddf4

The mount points are
        hopkins:/storage/music /storage/music nfs rw,nosuid,vers=3D3,rsize=
=3D32768,wsize=3D32768,namlen=3D255,hard,intr,proto=3Dtcp,timeo=3D600,retra=
ns=3D2,sec=3Dsys,mountproto=3Dudp,addr=3D192.168.1.6 0 0
        hopkins:/storage/mythtv/recordings /var/lib/mythtv/recordings nfs r=
w,nosuid,vers=3D3,rsize=3D32768,wsize=3D32768,namlen=3D255,acregmin=3D0,acr=
egmax=3D0,acdirmin=3D0,acdirmax=3D0,hard,intr,proto=3Dtcp,timeo=3D600,retra=
ns=3D2,sec=3Dsys,mountproto=3Dudp,addr=3D192.168.1.6 0 0
        hopkins:/var/lib/mythvideo /var/lib/mythvideo nfs rw,nosuid,vers=3D=
3,rsize=3D32768,wsize=3D32768,namlen=3D255,acregmin=3D0,acregmax=3D0,acdirm=
in=3D0,acdirmax=3D0,hard,intr,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dsys=
,mountproto=3Dudp,addr=3D192.168.1.6 0 0
        hopkins:/storage/home/ijc /home/ijc nfs rw,vers=3D3,rsize=3D131072,=
wsize=3D131072,namlen=3D255,hard,nointr,proto=3Dtcp,timeo=3D600,retrans=3D2=
,sec=3Dsys,mountproto=3Dudp,addr=3D192.168.1.6 0 0
all of them seem to be effected simultaneously (but I'll check to make doub=
le sure next time it occurs).

I've seen hung task backtraces from effected processes, e.g.=20
        Aug  4 06:27:28 iranon kernel: [137969.382277] INFO: task mythbacke=
nd:3161 blocked for more than 120 seconds.
        Aug  4 06:27:28 iranon kernel: [137969.382287] "echo 0 > /proc/sys/=
kernel/hung_task_timeout_secs" disables this message.
        Aug  4 06:27:28 iranon kernel: [137969.382291] mythbackend   D 0000=
5dfc     0  3161   1
        Aug  4 06:27:28 iranon kernel: [137969.382295]        f2006c70 0000=
0082 4b05cc7e 00005dfc f2006df0 c1c0e920 00000000 f7273390=20
        Aug  4 06:27:28 iranon kernel: [137969.382301]        0000c8b4 0000=
0000 00000001 f7273398 00000282 00000202 f71b0ab0 f200ddf0=20
        Aug  4 06:27:28 iranon kernel: [137969.382306]        c1c012bc fa18=
f0a6 fa18f0bf c02b45a7 f71b0ab0 00000000 f200de0c fa18f0a6=20
        Aug  4 06:27:28 iranon kernel: [137969.382311] Call Trace:
        Aug  4 06:27:28 iranon kernel: [137969.382347]  [<fa18f0a6>] nfs_wa=
it_schedule+0x0/0x1e [nfs]
        Aug  4 06:27:28 iranon kernel: [137969.382384]  [<fa18f0bf>] nfs_wa=
it_schedule+0x19/0x1e [nfs]
        Aug  4 06:27:28 iranon kernel: [137969.382399]  [<c02b45a7>] __wait=
_on_bit_lock+0x2a/0x52
        Aug  4 06:27:28 iranon kernel: [137969.382407]  [<fa18f0a6>] nfs_wa=
it_schedule+0x0/0x1e [nfs]
        Aug  4 06:27:28 iranon kernel: [137969.382421]  [<c02b462e>] out_of=
_line_wait_on_bit_lock+0x5f/0x67
        Aug  4 06:27:28 iranon kernel: [137969.382429]  [<c0133a1d>] wake_b=
it_function+0x0/0x3c
        Aug  4 06:27:28 iranon kernel: [137969.382441]  [<fa18f16e>] __nfs_=
revalidate_inode+0xaa/0x211 [nfs]
        Aug  4 06:27:28 iranon kernel: [137969.382458]  [<c017bac0>] do_loo=
kup+0x53/0x145
        Aug  4 06:27:28 iranon kernel: [137969.382466]  [<c0187609>] mntput=
_no_expire+0x11/0x64
        Aug  4 06:27:28 iranon kernel: [137969.382472]  [<c017d971>] __link=
_path_walk+0xa71/0xb65
        Aug  4 06:27:28 iranon kernel: [137969.382477]  [<c017bac0>] do_loo=
kup+0x53/0x145
        Aug  4 06:27:28 iranon kernel: [137969.382483]  [<c0187609>] mntput=
_no_expire+0x11/0x64
        Aug  4 06:27:28 iranon kernel: [137969.382492]  [<c0187609>] mntput=
_no_expire+0x11/0x64
        Aug  4 06:27:28 iranon kernel: [137969.382496]  [<c017daf5>] path_w=
alk+0x90/0x98
        Aug  4 06:27:28 iranon kernel: [137969.382502]  [<fa18f935>] nfs_ge=
tattr+0x8f/0xbe [nfs]
        Aug  4 06:27:28 iranon kernel: [137969.382520]  [<fa18f8a6>] nfs_ge=
tattr+0x0/0xbe [nfs]
        Aug  4 06:27:28 iranon kernel: [137969.382536]  [<c01785ac>] vfs_ge=
tattr+0x36/0x4d
        Aug  4 06:27:28 iranon kernel: [137969.382545]  [<c0178684>] vfs_ls=
tat_fd+0x27/0x39
        Aug  4 06:27:28 iranon kernel: [137969.382550]  [<fa18bca6>] nfs_pe=
rmission+0x0/0x129 [nfs]
        Aug  4 06:27:28 iranon kernel: [137969.382567]  [<c0187609>] mntput=
_no_expire+0x11/0x64
        Aug  4 06:27:28 iranon kernel: [137969.382572]  [<c0174914>] sys_fa=
ccessat+0x11e/0x15d
        Aug  4 06:27:28 iranon kernel: [137969.382582]  [<c0178703>] sys_ls=
tat64+0xf/0x23
        Aug  4 06:27:28 iranon kernel: [137969.382588]  [<c017603c>] vfs_re=
ad+0xe3/0x11e
        Aug  4 06:27:28 iranon kernel: [137969.382598]  [<c0174962>] sys_ac=
cess+0xf/0x13
        Aug  4 06:27:28 iranon kernel: [137969.382603]  [<c01077e8>] sysent=
er_past_esp+0x6d/0xa5
        Aug  4 06:27:28 iranon kernel: [137969.382617]  =3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Ian.
--=20
Ian Campbell

Contemptuous lights flashed across the computer's console.
		-- Hitchhiker's Guide to the Galaxy

--=-AKm9JcxJpCbzAlEQClVf
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkjeB/kACgkQM0+0qS9rzVknGwCeJXScpG/NonH+OrTWEHGJylGX
04AAnj0KqzvL9vBzPVsMRhiLK2eqXCIb
=oE/w
-----END PGP SIGNATURE-----

--=-AKm9JcxJpCbzAlEQClVf--

