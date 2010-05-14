From: Zhang Jingwang <yyalone@gmail.com>
Subject: Re: SQUASHME: missing from FIXME: async layout return
Date: Fri, 14 May 2010 11:28:46 +0800
Message-ID: <AANLkTikG-QLid-R4Zt0UJ29bbimpYXjA8XEQ0AVNxMhr@mail.gmail.com>
References: <4BEBBAE9.8090605@panasas.com>
	 <AANLkTind3eXmuPw5HrKqB6bHJSSXFL3g2cDSEyyYc1n8@mail.gmail.com>
	 <4BEC0F78.5060203@panasas.com>
	 <AANLkTilhbkde-kAPGSBHT1b8vIZq4cM1SPpI-Rd0iOb7@mail.gmail.com>
	 <4BEC1B43.2040901@panasas.com>
	 <AANLkTikXcTBNWXKmp7Fs_6cjOsJQ3C5iFNvW4GvuMkkY@mail.gmail.com>
	 <4BEC26BC.2040900@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:55800 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575Ab0END2r convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 May 2010 23:28:47 -0400
Received: by pvh1 with SMTP id 1so305030pvh.19
        for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 20:28:46 -0700 (PDT)
In-Reply-To: <4BEC26BC.2040900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2010/5/14 Benny Halevy <bhalevy@panasas.com>:
> On May. 13, 2010, 19:04 +0300, "William A. (Andy) Adamson" <androsada=
mson@gmail.com> wrote:
>> On Thu, May 13, 2010 at 11:31 AM, Boaz Harrosh <bharrosh@panasas.com=
> wrote:
>>> On 05/13/2010 06:17 PM, William A. (Andy) Adamson wrote:
>>>> On Thu, May 13, 2010 at 10:40 AM, Benny Halevy <bhalevy-C4P08NqkoRmIwRZHo2/mJg@public.gmane.org=
m> wrote:
>>>>> On May. 13, 2010, 17:19 +0300, "William A. (Andy) Adamson" <andro=
sadamson@gmail.com> wrote:
>>>>>> On Thu, May 13, 2010 at 4:40 AM, Boaz Harrosh <bharrosh@panasas.=
com> wrote:
>>>>>>> I've tested the patch:
>>>>>>> =A0 =A0 =A0 =A0FIXME: async layout return
>>>>>>>
>>>>>>> And there is a missing small hunk
>>>>>>>
>>>>>>> I have tested with this patch and it is a very good patch
>>>>>>> that should also go into 2.6.33. It is necessary in the rare
>>>>>>> case when one inode have more then one open_context.
>>>>>>
>>>>>> Do you mean more than one open context per open owner?
>>>>>
>>>>> What we see is one "regular" open context and one which is the la=
yout_commit_ctx
>>>>
>>>> Isn't that a BUG?
>>>>
>>>> Here is what we're seeing:
>>>>
>>>> nfs_file_release->nfs_release->nfs_file_clear_open_context->__put_=
nfs_open_context->
>>>> NFS_PROTO(inode)->close_context->nfs4_close_sync->__nfs4_close->pn=
fs_layoutcommit_inode,
>>>>
>>>> This is the same code that Boaz's 'missing small hunk' adds the wa=
it
>>>> to the pnfs_layout_commit_inode to. This is good, because when
>>>> __nfs4_close is called with sync, every thing must be sent/returne=
d
>>>> prior to the nfs_do_close call.
>>>>
>>>> But there is still a problem. Here is the __nfs4_close call (with =
out
>>>> the wait that Boaz added)
>>>>
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nfsi->layoutcommit_ctx)
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pnfs_layoutcommit_=
inode(state->inode, 0);
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (has_layout(nfsi) && nfsi->layo=
ut.roc_iomode) {
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nfs4_pnfs_l=
ayout_segment range;
>>>>
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 range.iomode =3D n=
fsi->layout.roc_iomode;
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 range.offset =3D 0=
;
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 range.length =3D N=
=46S4_MAX_UINT64;
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pnfs_return_layout=
(state->inode, &range, NULL,
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0RETURN_FILE);
>>>>
>>>> Note that a pnfs_return_layout which is always 'sync' (async with =
wait
>>>> for completion). So the (currently) async LAYOUTCOMMIT call return=
s,
>>>> and a LAYOUTRETURN is put on the wire
>>>>
>>>> Then the LAYOUTCOMMIT rpc_call_done routine calls
>>>> pnfs_layoutcommit_done which calls put_nfs_open_context. If the op=
en
>>>> context is different from the open context that was put by
>>>> nfs_file_release, then
>>>>
>>>> pnfs_layoutcommit_done->put_nfs_open_context-> ..... ->__nfs4_clos=
e
>>>> and the return on close LAYOUTRETURN is sent again!
>>>>
>>>> Of couse this second LAYOUTRETURN either gets a zero stateid, or u=
ses
>>>> the same stateid as the first LAYOUTRETURN, and the reply to the
>>>> second LAYOUTRETURN will result in a NFS4ERR_BAD_STATEID .....
>>>>
>>>> This will occur whether the LAYOUTCOMMIT is async or sync as they =
both
>>>> call pnfs_layoutcommit_done.
>>>>
>>>> I need to understand why there are two open contexts. On the face =
of
>>>> it, it seems wrong.
>>>>
>>>> We also add a pointer to the open context in the nfs_write_data, a=
nd
>>>> in the pnfs_layoutcommit_data. Do we take a reference on the open =
data
>>>> in theses cases? .
>>>>
>>>> -->Andy
>>>>
>>>>
>>>
>>> Yes on all acounts. This is what Benny's patch is fixing please try=
 it out
>>> it is most important (Add my small fix)
>>
>> Is this what you mean?
>>
>> With Benny's patch, with return-on-close set and the layoutcommit_ct=
x
>> different from the open context that caused the __nfs4_close:
>>
>> The (now) sync LAYOUTCOMMIT triggered from the nfs_file_release
>> __nfs4_close() will complete prior to calling the return-on-close
>> LAYOUTRETURN call. Since pnfs_layoutcommit_done is still called,
>> put_nfs_open_context will be call on the layoutconmit_ctx (saved in
>> pnfs_layoutcommit_data->ctx) and __nfs4_close will be called.
>>
>> In _this_ instance of calling __nfs4_close (from
>> pnfs_layoutcommit_done), the nfsi->layoutcommit_ctx pointer is null =
so
>> the pnfs_layoutcommit_inode call is skipped, and =A0pnfs_return_layo=
ut
>> is called. Since it is also a sync call, pnfs_layoutcommit_done does
>> not return until it is complete. So the layout is returned, the layo=
ut
>> is freed (all layout segments 'cause the range covers the whole file=
)
>> and pnfs_layoutcommit_inode returns to the FIRST __nfs4_close (from
>> nfs_file_release)
>>
>> Now since return-on-close is set, pnfs_layout_return is called (in t=
he
>> nfs_file_release __nfs4_close). This LAYOUTRETURN call will never go
>> on the wire because the first pnfs_layout_return (from the
>> pnfs_layoutcommit_done __nfs4_close) has removed the layout segment,
>> and all is well.
>>
>> Sheese.
>
> Yeah :-/
> I'm feeling increasingly uncomfortable with the current implementatio=
n
> and we're planning to come up with the state-machine based model
> for the Bakeathon and test it there. =A0Ideally, this will be stable =
enough
> that we can get the gist of it into pnfs-submit.
>
> Benny
>

Is there any document about the state-machine based model?
>>
>> --->Andy
>>
>>
>>>
>>> And about the multiple contexts I don't understand as well but the =
fact of it
>>> is that an nfs_inode has an list_head of open_contexts and we must =
deal properly
>>> with when that happens. (BTW with 2.6.34 Kernel it happens regularl=
y as in
>>> prev kernels it almost never trigger.)
>>>
>>> Benny's patch takes care of that and I've done heavy testing of it =
I can see cases
>>> of more then one contexts and it works correctly.
>>>
>>> But I too would like to understand when is it that an inode can hav=
e more then
>>> one open_context
>>>
>>> Boaz
>>>
>>>>
>>>>>
>>>>> Benny
>>>>>
>>>>>>
>>>>>> -->Andy
>>>>>>
>>>>>>>
>>>>>>> (For some reason I see that happening much more in 2.6.34
>>>>>>> =A0I don't understand why)
>>>>>>>
>>>>>>> Boaz
>>>>>>> ---
>>>>>>> git diff --stat -p -M
>>>>>>> =A0fs/nfs/nfs4state.c | =A0 =A02 +-
>>>>>>> =A01 files changed, 1 insertions(+), 1 deletions(-)
>>>>>>>
>>>>>>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>>>>>>> index 15c8bc8..6dbe893 100644
>>>>>>> --- a/fs/nfs/nfs4state.c
>>>>>>> +++ b/fs/nfs/nfs4state.c
>>>>>>> @@ -590,7 +590,7 @@ static void __nfs4_close(struct path *path,=
 struct nfs4_state *state, fmode_t fm
>>>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfs_inode *nfsi =3D NFS_I=
(state->inode);
>>>>>>>
>>>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (nfsi->layoutcommit_ctx)
>>>>>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pnfs_layoutcommit=
_inode(state->inode, 0);
>>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pnfs_layoutcommit=
_inode(state->inode, wait);
>>>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (has_layout(nfsi) && nfsi->la=
yout.roc_iomode) {
>>>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfs4_pnfs=
_layout_segment range;
>>>>>>>
>>>>>>> --
>>>>>>> To unsubscribe from this list: send the line "unsubscribe linux=
-nfs" in
>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info=
=2Ehtml
>>>>>>>
>>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nf=
s" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.ht=
ml
>>>>
>>>
>>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Zhang Jingwang
National Research Centre for High Performance Computers
Institute of Computing Technology, Chinese Academy of Sciences
No. 6, South Kexueyuan Road, Haidian District
Beijing, China
