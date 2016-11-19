Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38385 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751152AbcKSGdX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 19 Nov 2016 01:33:23 -0500
From: NeilBrown <neilb@suse.com>
To: Olga Kornievskaia <aglo@umich.edu>,
        Trond Myklebust <trondmy@primarydata.com>
Date: Sat, 19 Nov 2016 17:33:12 +1100
Cc: Adamson William <andros@netapp.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4.1: nfs4_fl_prepare_ds must be careful about reporting success.
In-Reply-To: <CAN-5tyH+4=9y9a3v0po5-cW+5ABSp5Z1pXN=+eTZSnd0KORk2Q@mail.gmail.com>
References: <87lgxiwoxi.fsf@notabene.neil.brown.name> <8760nlfkkq.fsf@notabene.neil.brown.name> <C9C69F9A-F0AD-4F76-B334-11C4E83D4155@primarydata.com> <CAN-5tyH+4=9y9a3v0po5-cW+5ABSp5Z1pXN=+eTZSnd0KORk2Q@mail.gmail.com>
Message-ID: <87wpg0dlnb.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Sat, Nov 19 2016, Olga Kornievskaia wrote:

> On Fri, Nov 18, 2016 at 9:32 AM, Trond Myklebust
> <trondmy@primarydata.com> wrote:
>>
>>> On Nov 18, 2016, at 00:01, NeilBrown <neilb@suse.com> wrote:
>>>
>>>
>>> Ping?
>>> No sign of this in linux-next, and no replies=E2=80=A6.
>>
>> I=E2=80=99d like some confirmation from the NetApp folks on this. They a=
re the main stakeholders for the pNFS files implementation. I don=E2=80=99t=
 think we need an equivalent for flex files.
>
> Just to see if I understand this patch. If "ds" isn't NULL, then the
> client has an RPC client with the ds. But it doesn't have a valid NFS
> client? Looking at the code I really don't see how that can happen.

I thought I explained that, but I was rather brief.

nfs4_fl_prepare_ds() calls nfs4_pnfs_ds_connect() in order to create the
NFS client.  The first time it is called it will set NFS4DS_CONNECTING
and then call _nfs4_pnfs_v?_ds_connect() which will establish the
connection and set ds->ds_clp.  If the server is unresponsive, this an
block indefinitely.

If a second thread then tries the same time, it will enter
nfs4_pnfs_ds_connect() and will discovery that NFS4DS_CONNECTING is
already set, so it will call nfs4_wait_ds_connect().

As nfs4_wait_ds_connect() waits with TASK_KILLABLE, it will abort if the
process is kill by an uncaught signal (such as SIGKILL).
In this case it will return even though NFS4DS_CONNECTING is still set,
and ds->ds_clp is still NULL.  i.e. the first thread hasn't established
the connection yet.

As the process has been killed, the 'ds' that it holds that doesn't have
an NFS client handle will never be used.  But we need to be sure that
the process will exit cleanly without trying to de-reference that NULL
ds_clp.

That is what the patch ensures.


> Maybe there is a bug elsewhere? If we return here, is there a chance
> we are going to have a zombie RPC client with the ds? If that's not a
> problem then I don't think there an issue to assume that if there is
> no valid NFS client then we would want to return a NULL from
> nfs4_fl_prepare_ds().

It isn't a "zombie RPC client", but rather an unborn RPC client, which
still has NFS4DS_CONNECTING set.

Thanks,
NeilBrown


>
>
>>
>>>
>>> Thanks,
>>> NeilBrown
>>>
>>>
>>> On Fri, Oct 21 2016, NeilBrown wrote:
>>>
>>>>
>>>> Various places assume that if nfs4_fl_prepare_ds() turns a non-NULL
>>>> 'ds', then ds->ds_clp will also be non-NULL.
>>>>
>>>> This is not necessasrily true in the case when the process received a
>>>> fatal signal while nfs4_pnfs_ds_connect is waiting in
>>>> nfs4_wait_ds_connect().  In that case ->ds_clp may not be set, and the
>>>> devid may not recently have been marked unavailable.
>>>>
>>>> So add a test for ->ds_clp =3D=3D NULL and return NULL in that case.
>>>>
>>>> Fixes: c23266d532b4 ("NFS4.1 Fix data server connection race")
>>>> Signed-off-by: NeilBrown <neilb@suse.com>
>>>> ---
>>>> fs/nfs/filelayout/filelayoutdev.c | 3 ++-
>>>> 1 file changed, 2 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/fil=
elayoutdev.c
>>>> index 4946ef40ba87..85ef38f9765f 100644
>>>> --- a/fs/nfs/filelayout/filelayoutdev.c
>>>> +++ b/fs/nfs/filelayout/filelayoutdev.c
>>>> @@ -283,7 +283,8 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lse=
g, u32 ds_idx)
>>>>                           s->nfs_client->cl_rpcclient->cl_auth->au_fla=
vor);
>>>>
>>>> out_test_devid:
>>>> -    if (filelayout_test_devid_unavailable(devid))
>>>> +    if (ret->ds_clp =3D=3D NULL ||
>>>> +        filelayout_test_devid_unavailable(devid))
>>>>              ret =3D NULL;
>>>> out:
>>>>      return ret;
>>>> --
>>>> 2.10.1
>>

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYL/IpAAoJEDnsnt1WYoG5PCMP/ik4FyqBJxSeGWqkSkrGSkpH
EF6xZcSu33eZh/cHwHT3r5CbtXEDMz8f/YVMfvTjo47SR+LQbNxV74UxMsnH/88U
CqxZem0Yr4kiV0LPpB0pV146RKDvb0UzJoODcsj4GernqXjGjOxWcGOUOJTw3EHA
RhZdU2YNbrDEAdxEXamY4eF89dj6SL8/R/+pnanVNI0UHErwGQ+nXqLp6N0rFGD2
qvAkxp/GgguBj+Cg9Gk+A8go15WptaV+9fFh1IP6NokdMlHbyk8P6te1U32HTISz
P4PMi1DQ3MUjezZXywXf19EC2UxuumMMfohjrZ1ZClFLgOvvjU2qkAiVK7zdpriT
uj7/j95vDWTJy+D/nLYJtDnqHItziuoNTFVJQaVRSf+apbxUmfX9AZC73+AtZ+We
AlXWCDtFWU4Q9/p49WNdAokX1r4qv6hCZ6mGPmVzUlYXcTIYfsOgm2voMKLgpfE0
Ywlp9U6RDoOwBemwjgkOa0MGKNMy5pFEW/yEn7WTCZ/l+knRUEYXEJ8NxMnr7SYx
ewWRrN4FZP1zTpUS3J2TeBODKT3rmZMAOdsL8+yWTcU1mcKL/0Y+FL+iVlVP3ioB
gztmunrj9nG0CZfKd+bozJELFXcDSKJ4OG78syGuYhEEztHFFkSQhG8Y5GQWYrTg
yO+odXNf0RxzInc1niTK
=kZdi
-----END PGP SIGNATURE-----
--=-=-=--
