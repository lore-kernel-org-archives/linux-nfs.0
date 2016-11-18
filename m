Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36347 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752516AbcKRRek (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2016 12:34:40 -0500
Received: by mail-it0-f65.google.com with SMTP id n68so5670319itn.3
        for <linux-nfs@vger.kernel.org>; Fri, 18 Nov 2016 09:34:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <C9C69F9A-F0AD-4F76-B334-11C4E83D4155@primarydata.com>
References: <87lgxiwoxi.fsf@notabene.neil.brown.name> <8760nlfkkq.fsf@notabene.neil.brown.name>
 <C9C69F9A-F0AD-4F76-B334-11C4E83D4155@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 18 Nov 2016 12:34:38 -0500
Message-ID: <CAN-5tyH+4=9y9a3v0po5-cW+5ABSp5Z1pXN=+eTZSnd0KORk2Q@mail.gmail.com>
Subject: Re: [PATCH] NFSv4.1: nfs4_fl_prepare_ds must be careful about
 reporting success.
To: Trond Myklebust <trondmy@primarydata.com>
Cc: NeilBrown <neilb@suse.com>, Adamson William <andros@netapp.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 18, 2016 at 9:32 AM, Trond Myklebust
<trondmy@primarydata.com> wrote:
>
>> On Nov 18, 2016, at 00:01, NeilBrown <neilb@suse.com> wrote:
>>
>>
>> Ping?
>> No sign of this in linux-next, and no replies=E2=80=A6.
>
> I=E2=80=99d like some confirmation from the NetApp folks on this. They ar=
e the main stakeholders for the pNFS files implementation. I don=E2=80=99t =
think we need an equivalent for flex files.

Just to see if I understand this patch. If "ds" isn't NULL, then the
client has an RPC client with the ds. But it doesn't have a valid NFS
client? Looking at the code I really don't see how that can happen.
Maybe there is a bug elsewhere? If we return here, is there a chance
we are going to have a zombie RPC client with the ds? If that's not a
problem then I don't think there an issue to assume that if there is
no valid NFS client then we would want to return a NULL from
nfs4_fl_prepare_ds().


>
>>
>> Thanks,
>> NeilBrown
>>
>>
>> On Fri, Oct 21 2016, NeilBrown wrote:
>>
>>>
>>> Various places assume that if nfs4_fl_prepare_ds() turns a non-NULL
>>> 'ds', then ds->ds_clp will also be non-NULL.
>>>
>>> This is not necessasrily true in the case when the process received a
>>> fatal signal while nfs4_pnfs_ds_connect is waiting in
>>> nfs4_wait_ds_connect().  In that case ->ds_clp may not be set, and the
>>> devid may not recently have been marked unavailable.
>>>
>>> So add a test for ->ds_clp =3D=3D NULL and return NULL in that case.
>>>
>>> Fixes: c23266d532b4 ("NFS4.1 Fix data server connection race")
>>> Signed-off-by: NeilBrown <neilb@suse.com>
>>> ---
>>> fs/nfs/filelayout/filelayoutdev.c | 3 ++-
>>> 1 file changed, 2 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/file=
layoutdev.c
>>> index 4946ef40ba87..85ef38f9765f 100644
>>> --- a/fs/nfs/filelayout/filelayoutdev.c
>>> +++ b/fs/nfs/filelayout/filelayoutdev.c
>>> @@ -283,7 +283,8 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg=
, u32 ds_idx)
>>>                           s->nfs_client->cl_rpcclient->cl_auth->au_flav=
or);
>>>
>>> out_test_devid:
>>> -    if (filelayout_test_devid_unavailable(devid))
>>> +    if (ret->ds_clp =3D=3D NULL ||
>>> +        filelayout_test_devid_unavailable(devid))
>>>              ret =3D NULL;
>>> out:
>>>      return ret;
>>> --
>>> 2.10.1
>
