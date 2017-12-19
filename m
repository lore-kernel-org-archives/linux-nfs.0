Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48687 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751975AbdLSUaP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Dec 2017 15:30:15 -0500
From: NeilBrown <neilb@suse.com>
To: "Michael Kerrisk \(man-pages\)" <mtk.manpages@gmail.com>
Date: Wed, 20 Dec 2017 07:30:06 +1100
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] fcntl.2, read.2, write.2: document "Lost locks" as cause for EIO.
In-Reply-To: <130530e8-83bc-35d3-b84c-9bee85ddee12@gmail.com>
References: <87lgi7nttp.fsf@notabene.neil.brown.name> <df9a18ce-c412-44aa-d475-77521a7252c5@gmail.com> <87shc7lnfs.fsf@notabene.neil.brown.name> <130530e8-83bc-35d3-b84c-9bee85ddee12@gmail.com>
Message-ID: <87h8smlaup.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 19 2017, Michael Kerrisk (man-pages) wrote:

> On 12/18/2017 10:45 PM, NeilBrown wrote:
>> On Mon, Dec 18 2017, Michael Kerrisk (man-pages) wrote:
>>=20
>>> Hello Neil
>>>
>>> There's a piece of your patch I don't understand. Please see below.
>>>
>>> On 12/13/2017 05:19 AM, NeilBrown wrote:
>>>>
>>>> If an advisory lock is lost, then read/write requests on any
>>>> affected file descriptor can return EIO - for NFSv4 at least.
>>>>
>>>> Signed-off-by: NeilBrown <neilb@suse.com>
>>>> ---
>>>>  man2/fcntl.2 | 24 ++++++++++++++++++++++++
>>>>  man2/read.2  |  9 +++++++++
>>>>  man2/write.2 |  9 +++++++++
>>>>  3 files changed, 42 insertions(+)
>>>>
>>>> diff --git a/man2/fcntl.2 b/man2/fcntl.2
>>>> index 67642384154c..6e6e26f66aa0 100644
>>>> --- a/man2/fcntl.2
>>>> +++ b/man2/fcntl.2
>>>> @@ -669,6 +669,30 @@ and
>>>>  Mandatory locking is not specified by POSIX.
>>>>  Some other systems also support mandatory locking,
>>>>  although the details of how to enable it vary across systems.
>>>> +.SS Lost locks
>>>> +When an advisory lock is obtained on a networked filesystem such as
>>>> +NFS it is possible that the lock might get lost.
>>>> +This may happen due to administrative action on the server, or due to=
 a
>>>> +network partition which lasts long enough for the server to assume
>>>
>>> What does "network partition which lasts long enough" mean?
>>> I think this perhaps needs to be clarified a little. At least,
>>> I don't understand it.
>>=20
>> "network partition" is a term using the NFS RFCs for any situation that
>> that results in the server and client not being able to communicate
>> (that are partitioned, one from the other?  There is partition (wall)
>> between them?  They are in separate partitions?).
>> I can see how the meaning might not be obvious if you hadn't come across
>> it before.
>>=20
>> If we change "network partition" to "loss of connectivity", would that
>> make it clear.  Is "loss of network connectivity with the server" too
>> verbose?
>
> Thanks, Neil. I've applied your patch and added the words "loss of network
> connectivity with the server".

Looks good.  Thanks!

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlo5ds8ACgkQOeye3VZi
gblXmg//bcDS7DOWR4rCid9hd+F6z28fL5I5FqOCglnEgUINPwTPfI08GHVpikw5
3gV8s7+L95apaGCe9HB5m1YJ27hFAAPs1j65L2Fn53GklJPUyQKZkv1ttqytVkG3
hxrONOc/S499y4fyu14qaFTu53OV1I2j0w5kM6N9l36pKNnO+yuO7NJ3t80mi/j3
0zRu6n3GHRoTTgwU29cNXEVEE6kcDm6Fm6/zsmBvISc4SLAPawVi4jCKDe/6yxaO
oaFHM2SKyT7REtiyLBLuclohnlyTmqhIWy4+T1zw4nXZo/af5wPs5c5rQ4VmRVWa
9DvcZ4Au+fR8NRnCzm2RVdlo+77NhTINcr1ZqjRG9tmxkhxUL/TmDSwlnUQFN7J5
Amu7UYAamVjQmSapuoz3eC418hiQ1WruOHKR/j16BKy8Nxv5bBSxgW1I/1FY5o8Y
htsZWdxSRgOg0QeIJ2WnNj+b02ap3UZpiwSbFGYfCt3CiHm4Rddg4G5Zd+6Qjx3A
dObEBa0z+d7FGeOABIcZ4PKDGxWkEbYJR9ixIZtarq4/ONX8feXgK3eyLeCOb5HC
LVrL3DLE5Jz4G7NXpt6mSoLMoubLMX+t6bGWFsv4sovHi4FHCm7gXou6Y0qxk5MX
cC6E1wa3LMNLC6LeTV8IcaVf1FI6IPKvB8gl+1s773Z8VMHn9/k=
=ij3v
-----END PGP SIGNATURE-----
--=-=-=--
