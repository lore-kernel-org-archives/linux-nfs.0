Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:48126 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753784Ab0EMQUQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 May 2010 12:20:16 -0400
Message-ID: <4BEC26BC.2040900@panasas.com>
Date: Thu, 13 May 2010 19:20:12 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
CC: Boaz Harrosh <bharrosh@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: SQUASHME: missing from FIXME: async layout return
References: <4BEBBAE9.8090605@panasas.com>	 <AANLkTind3eXmuPw5HrKqB6bHJSSXFL3g2cDSEyyYc1n8@mail.gmail.com>	 <4BEC0F78.5060203@panasas.com>	 <AANLkTilhbkde-kAPGSBHT1b8vIZq4cM1SPpI-Rd0iOb7@mail.gmail.com>	 <4BEC1B43.2040901@panasas.com> <AANLkTikXcTBNWXKmp7Fs_6cjOsJQ3C5iFNvW4GvuMkkY@mail.gmail.com>
In-Reply-To: <AANLkTikXcTBNWXKmp7Fs_6cjOsJQ3C5iFNvW4GvuMkkY@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On May. 13, 2010, 19:04 +0300, "William A. (Andy) Adamson" <androsadamson@gmail.com> wrote:
> On Thu, May 13, 2010 at 11:31 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>> On 05/13/2010 06:17 PM, William A. (Andy) Adamson wrote:
>>> On Thu, May 13, 2010 at 10:40 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>>>> On May. 13, 2010, 17:19 +0300, "William A. (Andy) Adamson" <androsadamson@gmail.com> wrote:
>>>>> On Thu, May 13, 2010 at 4:40 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>>>>> I've tested the patch:
>>>>>>        FIXME: async layout return
>>>>>>
>>>>>> And there is a missing small hunk
>>>>>>
>>>>>> I have tested with this patch and it is a very good patch
>>>>>> that should also go into 2.6.33. It is necessary in the rare
>>>>>> case when one inode have more then one open_context.
>>>>>
>>>>> Do you mean more than one open context per open owner?
>>>>
>>>> What we see is one "regular" open context and one which is the layout_commit_ctx
>>>
>>> Isn't that a BUG?
>>>
>>> Here is what we're seeing:
>>>
>>> nfs_file_release->nfs_release->nfs_file_clear_open_context->__put_nfs_open_context->
>>> NFS_PROTO(inode)->close_context->nfs4_close_sync->__nfs4_close->pnfs_layoutcommit_inode,
>>>
>>> This is the same code that Boaz's 'missing small hunk' adds the wait
>>> to the pnfs_layout_commit_inode to. This is good, because when
>>> __nfs4_close is called with sync, every thing must be sent/returned
>>> prior to the nfs_do_close call.
>>>
>>> But there is still a problem. Here is the __nfs4_close call (with out
>>> the wait that Boaz added)
>>>
>>>                 if (nfsi->layoutcommit_ctx)
>>>                         pnfs_layoutcommit_inode(state->inode, 0);
>>>                 if (has_layout(nfsi) && nfsi->layout.roc_iomode) {
>>>                         struct nfs4_pnfs_layout_segment range;
>>>
>>>                         range.iomode = nfsi->layout.roc_iomode;
>>>                         range.offset = 0;
>>>                         range.length = NFS4_MAX_UINT64;
>>>                         pnfs_return_layout(state->inode, &range, NULL,
>>>                                            RETURN_FILE);
>>>
>>> Note that a pnfs_return_layout which is always 'sync' (async with wait
>>> for completion). So the (currently) async LAYOUTCOMMIT call returns,
>>> and a LAYOUTRETURN is put on the wire
>>>
>>> Then the LAYOUTCOMMIT rpc_call_done routine calls
>>> pnfs_layoutcommit_done which calls put_nfs_open_context. If the open
>>> context is different from the open context that was put by
>>> nfs_file_release, then
>>>
>>> pnfs_layoutcommit_done->put_nfs_open_context-> ..... ->__nfs4_close
>>> and the return on close LAYOUTRETURN is sent again!
>>>
>>> Of couse this second LAYOUTRETURN either gets a zero stateid, or uses
>>> the same stateid as the first LAYOUTRETURN, and the reply to the
>>> second LAYOUTRETURN will result in a NFS4ERR_BAD_STATEID .....
>>>
>>> This will occur whether the LAYOUTCOMMIT is async or sync as they both
>>> call pnfs_layoutcommit_done.
>>>
>>> I need to understand why there are two open contexts. On the face of
>>> it, it seems wrong.
>>>
>>> We also add a pointer to the open context in the nfs_write_data, and
>>> in the pnfs_layoutcommit_data. Do we take a reference on the open data
>>> in theses cases? .
>>>
>>> -->Andy
>>>
>>>
>>
>> Yes on all acounts. This is what Benny's patch is fixing please try it out
>> it is most important (Add my small fix)
> 
> Is this what you mean?
> 
> With Benny's patch, with return-on-close set and the layoutcommit_ctx
> different from the open context that caused the __nfs4_close:
> 
> The (now) sync LAYOUTCOMMIT triggered from the nfs_file_release
> __nfs4_close() will complete prior to calling the return-on-close
> LAYOUTRETURN call. Since pnfs_layoutcommit_done is still called,
> put_nfs_open_context will be call on the layoutconmit_ctx (saved in
> pnfs_layoutcommit_data->ctx) and __nfs4_close will be called.
> 
> In _this_ instance of calling __nfs4_close (from
> pnfs_layoutcommit_done), the nfsi->layoutcommit_ctx pointer is null so
> the pnfs_layoutcommit_inode call is skipped, and  pnfs_return_layout
> is called. Since it is also a sync call, pnfs_layoutcommit_done does
> not return until it is complete. So the layout is returned, the layout
> is freed (all layout segments 'cause the range covers the whole file)
> and pnfs_layoutcommit_inode returns to the FIRST __nfs4_close (from
> nfs_file_release)
> 
> Now since return-on-close is set, pnfs_layout_return is called (in the
> nfs_file_release __nfs4_close). This LAYOUTRETURN call will never go
> on the wire because the first pnfs_layout_return (from the
> pnfs_layoutcommit_done __nfs4_close) has removed the layout segment,
> and all is well.
> 
> Sheese.

Yeah :-/
I'm feeling increasingly uncomfortable with the current implementation
and we're planning to come up with the state-machine based model
for the Bakeathon and test it there.  Ideally, this will be stable enough
that we can get the gist of it into pnfs-submit.

Benny

> 
> --->Andy
> 
> 
>>
>> And about the multiple contexts I don't understand as well but the fact of it
>> is that an nfs_inode has an list_head of open_contexts and we must deal properly
>> with when that happens. (BTW with 2.6.34 Kernel it happens regularly as in
>> prev kernels it almost never trigger.)
>>
>> Benny's patch takes care of that and I've done heavy testing of it I can see cases
>> of more then one contexts and it works correctly.
>>
>> But I too would like to understand when is it that an inode can have more then
>> one open_context
>>
>> Boaz
>>
>>>
>>>>
>>>> Benny
>>>>
>>>>>
>>>>> -->Andy
>>>>>
>>>>>>
>>>>>> (For some reason I see that happening much more in 2.6.34
>>>>>>  I don't understand why)
>>>>>>
>>>>>> Boaz
>>>>>> ---
>>>>>> git diff --stat -p -M
>>>>>>  fs/nfs/nfs4state.c |    2 +-
>>>>>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>>>>>
>>>>>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>>>>>> index 15c8bc8..6dbe893 100644
>>>>>> --- a/fs/nfs/nfs4state.c
>>>>>> +++ b/fs/nfs/nfs4state.c
>>>>>> @@ -590,7 +590,7 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state, fmode_t fm
>>>>>>                struct nfs_inode *nfsi = NFS_I(state->inode);
>>>>>>
>>>>>>                if (nfsi->layoutcommit_ctx)
>>>>>> -                       pnfs_layoutcommit_inode(state->inode, 0);
>>>>>> +                       pnfs_layoutcommit_inode(state->inode, wait);
>>>>>>                if (has_layout(nfsi) && nfsi->layout.roc_iomode) {
>>>>>>                        struct nfs4_pnfs_layout_segment range;
>>>>>>
>>>>>> --
>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>
>>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>>
