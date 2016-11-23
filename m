Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36696 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932792AbcKWRiC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Nov 2016 12:38:02 -0500
Received: by mail-io0-f195.google.com with SMTP id k19so2390087iod.3
        for <linux-nfs@vger.kernel.org>; Wed, 23 Nov 2016 09:37:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87wpg0dlnb.fsf@notabene.neil.brown.name>
References: <87lgxiwoxi.fsf@notabene.neil.brown.name> <8760nlfkkq.fsf@notabene.neil.brown.name>
 <C9C69F9A-F0AD-4F76-B334-11C4E83D4155@primarydata.com> <CAN-5tyH+4=9y9a3v0po5-cW+5ABSp5Z1pXN=+eTZSnd0KORk2Q@mail.gmail.com>
 <87wpg0dlnb.fsf@notabene.neil.brown.name>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 23 Nov 2016 12:37:50 -0500
Message-ID: <CAN-5tyFfnSxcnFjpcCqT--qQhpHa-37NnVXuX70imE1WiyFFNg@mail.gmail.com>
Subject: Re: [PATCH] NFSv4.1: nfs4_fl_prepare_ds must be careful about
 reporting success.
To: NeilBrown <neilb@suse.com>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        Adamson William <andros@netapp.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Nov 19, 2016 at 1:33 AM, NeilBrown <neilb@suse.com> wrote:
> On Sat, Nov 19 2016, Olga Kornievskaia wrote:
>
>> On Fri, Nov 18, 2016 at 9:32 AM, Trond Myklebust
>> <trondmy@primarydata.com> wrote:
>>>
>>>> On Nov 18, 2016, at 00:01, NeilBrown <neilb@suse.com> wrote:
>>>>
>>>>
>>>> Ping?
>>>> No sign of this in linux-next, and no replies=E2=80=A6.
>>>
>>> I=E2=80=99d like some confirmation from the NetApp folks on this. They =
are the main stakeholders for the pNFS files implementation. I don=E2=80=99=
t think we need an equivalent for flex files.
>>
>> Just to see if I understand this patch. If "ds" isn't NULL, then the
>> client has an RPC client with the ds. But it doesn't have a valid NFS
>> client? Looking at the code I really don't see how that can happen.
>
> I thought I explained that, but I was rather brief.
>
> nfs4_fl_prepare_ds() calls nfs4_pnfs_ds_connect() in order to create the
> NFS client.  The first time it is called it will set NFS4DS_CONNECTING
> and then call _nfs4_pnfs_v?_ds_connect() which will establish the
> connection and set ds->ds_clp.  If the server is unresponsive, this an
> block indefinitely.
>
> If a second thread then tries the same time, it will enter
> nfs4_pnfs_ds_connect() and will discovery that NFS4DS_CONNECTING is
> already set, so it will call nfs4_wait_ds_connect().
>
> As nfs4_wait_ds_connect() waits with TASK_KILLABLE, it will abort if the
> process is kill by an uncaught signal (such as SIGKILL).
> In this case it will return even though NFS4DS_CONNECTING is still set,
> and ds->ds_clp is still NULL.  i.e. the first thread hasn't established
> the connection yet.
>
> As the process has been killed, the 'ds' that it holds that doesn't have
> an NFS client handle will never be used.  But we need to be sure that
> the process will exit cleanly without trying to de-reference that NULL
> ds_clp.
>
> That is what the patch ensures.

Thanks for the explanation. Makes sense.

>> Maybe there is a bug elsewhere? If we return here, is there a chance
>> we are going to have a zombie RPC client with the ds? If that's not a
>> problem then I don't think there an issue to assume that if there is
>> no valid NFS client then we would want to return a NULL from
>> nfs4_fl_prepare_ds().
>
> It isn't a "zombie RPC client", but rather an unborn RPC client, which
> still has NFS4DS_CONNECTING set.
>
> Thanks,
> NeilBrown
>
>
>>
>>
>>>
>>>>
>>>> Thanks,
>>>> NeilBrown
>>>>
>>>>
>>>> On Fri, Oct 21 2016, NeilBrown wrote:
>>>>
>>>>>
>>>>> Various places assume that if nfs4_fl_prepare_ds() turns a non-NULL
>>>>> 'ds', then ds->ds_clp will also be non-NULL.
>>>>>
>>>>> This is not necessasrily true in the case when the process received a
>>>>> fatal signal while nfs4_pnfs_ds_connect is waiting in
>>>>> nfs4_wait_ds_connect().  In that case ->ds_clp may not be set, and th=
e
>>>>> devid may not recently have been marked unavailable.
>>>>>
>>>>> So add a test for ->ds_clp =3D=3D NULL and return NULL in that case.
>>>>>
>>>>> Fixes: c23266d532b4 ("NFS4.1 Fix data server connection race")
>>>>> Signed-off-by: NeilBrown <neilb@suse.com>
>>>>> ---
>>>>> fs/nfs/filelayout/filelayoutdev.c | 3 ++-
>>>>> 1 file changed, 2 insertions(+), 1 deletion(-)
>>>>>
>>>>> diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/fi=
lelayoutdev.c
>>>>> index 4946ef40ba87..85ef38f9765f 100644
>>>>> --- a/fs/nfs/filelayout/filelayoutdev.c
>>>>> +++ b/fs/nfs/filelayout/filelayoutdev.c
>>>>> @@ -283,7 +283,8 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *ls=
eg, u32 ds_idx)
>>>>>                           s->nfs_client->cl_rpcclient->cl_auth->au_fl=
avor);
>>>>>
>>>>> out_test_devid:
>>>>> -    if (filelayout_test_devid_unavailable(devid))
>>>>> +    if (ret->ds_clp =3D=3D NULL ||
>>>>> +        filelayout_test_devid_unavailable(devid))
>>>>>              ret =3D NULL;
>>>>> out:
>>>>>      return ret;
>>>>> --
>>>>> 2.10.1
>>>
