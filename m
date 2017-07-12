Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49704 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932365AbdGLAqd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 20:46:33 -0400
From: NeilBrown <neilb@suse.com>
To: Phil Kauffman <kauffman@cs.uchicago.edu>, linux-nfs@vger.kernel.org
Date: Wed, 12 Jul 2017 10:46:22 +1000
Subject: Re: /etc/mtab read ~900 times by rpc.mountd
In-Reply-To: <1740081e-6180-1c88-0a0c-8747a92c65a1@cs.uchicago.edu>
References: <f9dcc371-cd94-6b39-dd6a-b412bdf03df4@cs.uchicago.edu> <8737a9x9ky.fsf@notabene.neil.brown.name> <595F1A3A.7070405@cs.uchicago.edu> <87efto69rs.fsf@notabene.neil.brown.name> <4ec2a8fc-3ca5-d26b-7742-be4e2f749c21@cs.uchicago.edu> <87y3rv4zrb.fsf@notabene.neil.brown.name> <1740081e-6180-1c88-0a0c-8747a92c65a1@cs.uchicago.edu>
Message-ID: <87bmoq4h41.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Tue, Jul 11 2017, Phil Kauffman wrote:

> On 07/10/2017 06:51 PM, NeilBrown wrote:
>> This does look encouraging ... but I'm not sure we are comparing apples
>> with apples.
> I had a feeling this was the case.
>
>
>> Could you repeat your experiments after first running "exportfs -f" on
>> the nfs server?  That should cause worst-case load on mountd.
> The new strace with '-tt': http://people.cs.uchicago.edu/~kauffman/nfs-kernel-server/test_with_patch_take2/2017-07-11_100929_strace.txt
> SSH test: http://people.cs.uchicago.edu/~kauffman/nfs-kernel-server/test_with_patch_take2/ssh_output.txt
>
> nfsserver# exportfs -f; m=$(pgrep rpc.mountd); strace -tt -p ${m} 2>&1 | tee `date +%F_%T`_strace.txt
>
>
> # cut -d' ' -f2 2017-07-11_100929_strace.txt| cut -d'(' -f1 | sort | uniq -c | sort -n
>       1 Process
>      73 select
>     143 write
>     216 close
>     216 fstat
>     216 open
>   48240 read
>  435599 stat
>  871162 statfs
>  871163 lstat
>
>
>> (and thanks for providing all the tracing details - I love getting
>> unambiguous data!!)
> No problem, I'm available to run any necessary tests. I also appreciate your help on this.
>

So the new data shows about 7 seconds for a login, which is probably
a little longer than you would like, but might be acceptable?
Each login triggers 3 reads of /etc/mtab, and each read  (from 'open' to
'close') takes either 3-4 seconds or about 0.2 seconds.
Actually reading /etc/mtab seems to take about 0.1-0.2 seconds at most.
The rest of the time is calling stat, with a pattern like

10:09:39.547280 stat("/tank/homes/someuser", {st_mode=S_IFDIR|0750, st_size=52, ...}) = 0
10:09:39.547318 lstat("/tank/homes/someuser", {st_mode=S_IFDIR|0750, st_size=52, ...}) = 0
10:09:39.547350 lstat("/tank/homes/someuser"..", {st_mode=S_IFDIR|0755, st_size=5967, ...}) = 0
10:09:39.547385 statfs("/tank/homes/someuser", {f_type=0x2fc12fc1, f_bsize=131072, f_blocks=40960, f_bfree=38830, f_ba
10:09:39.547424 statfs("/tank/homes/someuser", {f_type=0x2fc12fc1, f_bsize=131072, f_blocks=40960, f_bfree=38830, f_ba

Of the three passes through /etc/mtab for each login, one generates
95 of these, one generates 6049, and one generates 5952.

The 'stat' is from match_fsid()
The 2 'lstat' are from is_mountpoint() (called by match_fsid()
The first statfs() is from uuid_by_path()
Maybe the second is somewhere in the blkid code.

Probably the next step is to cache the mapping from
  path, fsidtype -> fsid.

That is more than a 2-line patch.  I might have a go later this week.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlllcWAACgkQOeye3VZi
gbn+bA/8DwHp1S9zTcgrv0Xoj+gLPgxkyHAx5xaaPq8eplSRoZd1/SHRdyKaJe60
PmFsz49g7MzhfobexLe1K4bhuU8AzeGXRG7As09tf+1dc+Fc4cHJ3z/3Wvh7nAkd
tuogWfFseDMPRbN55hQrFgX1dpIf/9kZmBoUzvszFf/ozZN0oDCP02Ot9W6IEMbW
MsK52/rG/1Ugje3WODeiFZowuiKRS6KExtFg84rlnx+QS269r6jimrJu/KRBwEn+
qgMdSzciq28qUM5kygWwvyREFjKWZixtQuDqMKG74yTexLucUhDcXPWAmWqm8ppR
kPPhrCbYC3HYuvjHlBxra3mgv8eypl+OTOxT/+FbAtgg51K1OToMJKpT45um0I9j
nu06DzsL4SdU4ljLw4ViyTSf5jzUOIQa5VzA7z4CTtLYOK2HXjZ1HIhD71U+2pcu
GavoFXR3B9qI81fUEMnkZmFIfKy/wW/Ky1au9FPi6JjA4go+Xk7n9+JHKbuCrCzC
6DyIKmCIYkEg5NRRwNy0kiPwff/GCX1x3IVtOSmDAhwjgO4lK4feGY3WdSLL9beu
f6cw1exF3QVVmJpaZm4npClSecQBprPz7Nv0ZC6rDwCnMfXlWJxJkYPTxY3Ibr38
efVNQmyA1uU7H7REoqUHF+4fGL1eBzDYdqhroE1AgzZprmJazu4=
=EvSa
-----END PGP SIGNATURE-----
--=-=-=--
