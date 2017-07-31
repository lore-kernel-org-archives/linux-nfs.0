Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45593 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750709AbdGaEXa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 31 Jul 2017 00:23:30 -0400
From: NeilBrown <neilb@suse.com>
To: Phil Kauffman <kauffman@cs.uchicago.edu>, linux-nfs@vger.kernel.org
Date: Mon, 31 Jul 2017 14:23:21 +1000
Subject: Re: /etc/mtab read ~900 times by rpc.mountd
In-Reply-To: <3fd8c348-13ee-ce90-a1d5-d0c652f66c89@cs.uchicago.edu>
References: <f9dcc371-cd94-6b39-dd6a-b412bdf03df4@cs.uchicago.edu> <8737a9x9ky.fsf@notabene.neil.brown.name> <595F1A3A.7070405@cs.uchicago.edu> <87efto69rs.fsf@notabene.neil.brown.name> <4ec2a8fc-3ca5-d26b-7742-be4e2f749c21@cs.uchicago.edu> <87y3rv4zrb.fsf@notabene.neil.brown.name> <1740081e-6180-1c88-0a0c-8747a92c65a1@cs.uchicago.edu> <87bmoq4h41.fsf@notabene.neil.brown.name> <9e16d6c3-a675-b53e-c6f3-dfa9cdf1d5c9@cs.uchicago.edu> <871spj1pfr.fsf@notabene.neil.brown.name> <03636068-4cc7-896e-5f8b-8c3ebfd2aa94@cs.uchicago.edu> <87h8xywl4t.fsf@notabene.neil.brown.name> <3fd8c348-13ee-ce90-a1d5-d0c652f66c89@cs.uchicago.edu>
Message-ID: <87r2wxutdy.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 27 2017, Phil Kauffman wrote:

> On 07/26/2017 11:37 PM, NeilBrown wrote:
>> Weird.
> I thought so as well.
>
>> So it seems like the context is different in some way.
> It is in the sense that I am now using 1.3.4 and 2.1.1 vanilla on Ubuntu =
Xenial(provides 1.2.8) without any of debian's patches or niceties.=20
>
>=20=20
>> Your nfs_test_notes.txt doesn't show /etc/export.d getting filled in
>> ... maybe that it done automatically somehow...
> I copied the files from the original NFS server into /etc/exports.d  as p=
art of the VM snapshot I revert back to. My notes say 'mkdir -p /etc/export=
s.d', but this step is not necessary.
>
> root@nfsserver:~# ls /etc/exports.d/ | wc -l
> 972
>
> I only added 3 extra files so that 'nfsclient' would be able to mount fro=
m the testing server (nfsserver).
>
> The ZFS datasets were also precreated:
>
> root@nfsserver:~# zfs list | wc -l
> 6062
>
>
>> Can you try with unpatches 2.1.1?
> I assume you mean without any patches. vanilla 2.1.1
>
>> Also maybe provide an strace starting before any attempt to mount
>> anything, and with an extra option "-s 1000"..
>
> This is all that happens *before* trying to mount from the client.
> root@nfsserver:~# systemctl restart nfs-server; exportfs -f; m=3D$(pgrep =
rpc.mountd); strace -s 1000 -ttt -T -p $m 2>&1 | tee strace_rpc.mountd2.txt
> strace: Process 2517 attached
> 1501190436.659800 select(1024, [3 4 5 7 8 9 10 11 12 13 14 15 16 17 18], =
NULL, NULL, NULL
>
> Stracing rpc.nfsd:
> root@nfsserver:~# exportfs -f; strace -s1000 -ttt -T /usr/sbin/rpc.nfsd 0=
 2>&1| tee strace_nfsd.txt; /usr/sbin/sm-notify
> http://people.cs.uchicago.edu/~kauffman/nfs-kernel-server/take3/strace_rp=
c.nfsd.txt
>
> When mounting from the client I get a strace that is 1.3G (it seems '-s' =
was not respected for some reason): http://people.cs.uchicago.edu/~kauffman=
/nfs-kernel-server/take3/strace_rpc.mountd.txt=20
>


I'm sorry but I cannot get anything useful from these.  It isn't crystal
clear what was being tested in each case....
Could you try:

1/ build the current 'master' branch from the nfs-utils git tree, with
   no extra patches.
2/ Install that and perform the same test which produce the 1.3G strace
   file above.  Provide the resulting strace of rpc.mountd.
3/ Tell me what happened when you mounted on the client.  Did it work as
   expected?
4/ Apply the patch I provided on top of the 'master' branch but change

		hcreate_r(1000, &hdata);

to

		hcreate_r(20000, &hdata);

5/ Install that and perform the same test as in step to, producing
   a new strace of rpc.mounted.  Presumably it will be difference.
6/ Tell me what happened when you mounted on the client.  Did it work
   as expected, or did it fail like I think it did last time.

If one worked and the other didn't, I can compare the strace and try to
find a difference.
If both worked, then we should have useful information about how much
speed up the patch provides (if any).
If neither worked, then something weird is happening...

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAll+sLsACgkQOeye3VZi
gbkJZhAAgVLhnf5JBEKm4+mIQx7C69EJjDrsMf/jHLnEG0h20halvRrC/bAWfc2q
kAVYEmsN7gt5H28sxrCNm2U9y0sol7DYyUdiKDUL8ebV8BfmF9ddW73j8TIxT9ig
VWQFT7oUZ+q4/DEbMrkKW8HPtY8T9mJGBZQ9pCgAvrRWNLkiIgbZdUN5JtAgzGOp
4b98liz6AGC5a1ajzITY9i/d4PwpqK1RxEYp/GJ2wG6eFNLWEyYDh5cHgiRnKhJq
GBKB7DTIzGMdPOB/n+Bf44uW0KJdZVZNeC1CsM5U8K9x8FJUpu0HJjj6eynNa8nX
5hP37Ymu4jBrRh2A1BdvS9XLy/+ghTPN/IUgG0FMX4nBPyFjJ2Cl5wswUUTjtN9J
oH0bfk1r7qKFAr9OA50YptLrqZAJmA1BniLjpx9SH9kNMtRRADG43G1w5AVXMvVr
LJFBSJmp1Kzlz3kvdx79+teOHvjWbMHbR4+4yJTV0wFkMNO5ac8Tk6vt4fasQeg9
cJENRrTYYrGJWkDEuXNLmgFBrpkWQ39+qOwOZ1NLypQkff40iNBrwPtorUHDboH9
mLYVgFqRZAoLlj2KEKju9s+kUcoCX25pNxOODYWbMseQ1+faLv4ZbqjXxlseGGpm
k55XSZmIqGXug1VuYlFc4HhMmApWsp6TIW5Qj2JOJn+2Hu8upm0=
=iZ2I
-----END PGP SIGNATURE-----
--=-=-=--
