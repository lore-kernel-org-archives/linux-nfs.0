Return-Path: linux-nfs-owner@vger.kernel.org
Received: from haggis.pcug.org.au ([203.10.76.10]:57350 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758614Ab2C2DZG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2012 23:25:06 -0400
Date: Thu, 29 Mar 2012 14:24:55 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: jlayton@redhat.com, bfields@redhat.com, Trond.Myklebust@netapp.com,
        linux-nfs@vger.kernel.org, linux-next@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: linux-next: breakage on undefined reference to
 `nfsd4_cld_block'
Message-Id: <20120329142455.dbad3778ced27db683d06a6a@canb.auug.org.au>
In-Reply-To: <CAP=VYLr9CL33ZbEVUhVNXsKOCcDWmwmP268jggzWJEBaMa_W0w@mail.gmail.com>
References: <CAP=VYLr9CL33ZbEVUhVNXsKOCcDWmwmP268jggzWJEBaMa_W0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__29_Mar_2012_14_24_55_+1100_Cj8Si8yBkrcmj.c9"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Signature=_Thu__29_Mar_2012_14_24_55_+1100_Cj8Si8yBkrcmj.c9
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

[cc of nfsd tree contact added]

On Wed, 28 Mar 2012 20:31:36 -0400 Paul Gortmaker <paul.gortmaker@windriver=
.com> wrote:
>
> Hi all,
>=20
> The linux-next tree got about ten new failures today, spanning all arch.
> They all shared this in common, it seems.
>=20
> ERROR: "nfsd4_cld_block" [fs/nfsd/nfsd.ko] undefined!
> make[2]: *** [__modpost] Error 1
>=20
> I chose alpha (since it was the 1st I saw alphabetically) and did a bisec=
t,
> and it came up with the below commit.  I've also included the bisect log.
>=20
> Can someone please take a look at this?  Too late to fix for the Thursday
> build, but Friday might be the last for 3.4 content and it would be nice =
to
> have all these builds green again in that one.
>=20
> Thanks,
> Paul.
>=20
> --------------
> commit 813fd320c16691eac508fe350b4ee7362c6c4a56
> Author: Jeff Layton <jlayton@redhat.com>
> Date:   Wed Mar 21 09:52:08 2012 -0400
>=20
>     nfsd: add notifier to handle mount/unmount of rpc_pipefs sb
>=20
>     In the event that rpc_pipefs isn't mounted when nfsd starts, we
>     must register a notifier to handle creating the dentry once it
>     is mounted, and to remove the dentry on unmount.
>=20
>     Signed-off-by: Jeff Layton <jlayton@redhat.com>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> -------------------
>=20
> git bisect start
> # good: [c16fa4f2ad19908a47c63d8fa436a1178438c7e7] Linux 3.3
> git bisect good c16fa4f2ad19908a47c63d8fa436a1178438c7e7
> # bad: [7734592ef4a5d14bba15cf2df7fcac8c39d6bdb4] Add linux-next
> specific files for 20120328
> git bisect bad 7734592ef4a5d14bba15cf2df7fcac8c39d6bdb4
> # good: [50953e0640b3473dcb409d5d0d938c2742c93b0d] Merge branch 'poll'
> into staging/for_v3.4
> git bisect good 50953e0640b3473dcb409d5d0d938c2742c93b0d
> # bad: [ecc717668be52fe7b3b29e922b96700067767f05] Merge
> remote-tracking branch 'l2-mtd/master'
> git bisect bad ecc717668be52fe7b3b29e922b96700067767f05
> # good: [d0f6867abfb505b191e31a87dbcdeed65241243a] Merge
> remote-tracking branch 'arm/for-next'
> git bisect good d0f6867abfb505b191e31a87dbcdeed65241243a
> # bad: [2dddaf865e0c13448518abbabd0ad462a7a2d3dd] Merge
> remote-tracking branch 'kbuild/for-next'
> git bisect bad 2dddaf865e0c13448518abbabd0ad462a7a2d3dd
> # bad: [7be8f9ff0749f5d8a0a508b071c206cb68decf04] Merge
> remote-tracking branch 'nfsd/nfsd-next'
> git bisect bad 7be8f9ff0749f5d8a0a508b071c206cb68decf04
> # good: [5537f6f1d690270d388987d543de2cc1e7be40e6] Merge
> remote-tracking branch 'ceph/master'
> git bisect good 5537f6f1d690270d388987d543de2cc1e7be40e6
> # good: [9d547c35799a4ddd235f1565cec2fff6c9263504] vfs: remove unused
> superblock helpers
> git bisect good 9d547c35799a4ddd235f1565cec2fff6c9263504
> # bad: [cc27e0d407021a278d08c1952f5af4ab38c49eda] nfsd: don't allow
> legacy client tracker init for anything but init_net
> git bisect bad cc27e0d407021a278d08c1952f5af4ab38c49eda
> # good: [1255a8f36cb16a02540bdad91c0bc0971b9fb429] nfsd4: don't set
> cl_firststate on first reclaim in 4.1 case
> git bisect good 1255a8f36cb16a02540bdad91c0bc0971b9fb429
> # good: [62b9510cb373d5722fdaba71d961d8f695acfcd5] nfsd: merge cookie
> collision fixes from ext4 tree
> git bisect good 62b9510cb373d5722fdaba71d961d8f695acfcd5
> # good: [2a4317c55438d8589a015d42912454ede12031f0] nfsd: add
> nfsd4_client_tracking_ops struct and a way to set it
> git bisect good 2a4317c55438d8589a015d42912454ede12031f0
> # good: [0ab628d856a63d63b47307b09851d1e955c706ac] nfsd: add a header
> describing upcall to nfsdcld
> git bisect good 0ab628d856a63d63b47307b09851d1e955c706ac
> # bad: [813fd320c16691eac508fe350b4ee7362c6c4a56] nfsd: add notifier
> to handle mount/unmount of rpc_pipefs sb
> git bisect bad 813fd320c16691eac508fe350b4ee7362c6c4a56
> # good: [f3f8014862d813cca81a597c83bd1dbf0fb2b8f6] nfsd: add the
> infrastructure to handle the cld upcall
> git bisect good f3f8014862d813cca81a597c83bd1dbf0fb2b8f6

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__29_Mar_2012_14_24_55_+1100_Cj8Si8yBkrcmj.c9
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPc9YHAAoJEECxmPOUX5FEPDgP/jJ4EDFbiOuB+rNiw/bukO1m
hEfYcOTYQ21lPINZ3KicSJ8T8EzagcZya24EYCuJslcNqh1q+Hd9XmWKoofzMGIV
sPweAiSZRLKXzvexB4oLAnDG3Bq9ycBxxlM9juyEXzyddBRI8Dobt0ryEmzo9+hX
LpmXDDu8GFX5+A3jgM07HkBzaql52FTfotMBVia4Frj4hr2Fd7KZu2CvsrYyB38v
jEiFfvq8Q3lwivKxJgyMIn4LTirydkfW5qH42ghaikjyGZnMG8+mzyLOr6yuo+V5
JEEQTI5CUFaMjA+UWoOTQ+zbhOoqDnHyvtVYjtMOartPLpjw2AYRrxImjtlTHpT2
S/129OaaDfYaJ+7F3Vjwg1lL+5fGVUVNsdzN+yOKgbcd2Sizs5oBo4wdPtKOIq4U
1eg1rbsJdh7NcszB2ivk2kEcvyp8JkFm28Odvg1dQ9ITAry7EohM+SF/Buqn0j5o
fbzt1qrdAEq/WISOnWt2+WhT80xOZnpIu3e0tgX4BrIF0RlOermj8OePw+yNjdA1
rMw6HVMCCF5eLYOhxMrYV5cmI0qrq2rxFyIptdVpwgnotIlo/MnJGJ4ptwVMUE8O
rjLk3TKSRCxwR3jKVZOr0XlzEpZlSQ/9JeLDCaHNc0Jqht+SVrtHkG4T8e/vu8Eu
+kUBfX4scT3eNzF8Y602
=O+3i
-----END PGP SIGNATURE-----

--Signature=_Thu__29_Mar_2012_14_24_55_+1100_Cj8Si8yBkrcmj.c9--
