Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62415 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521Ab1LFSYX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Dec 2011 13:24:23 -0500
Received: by wgbdr13 with SMTP id dr13so6680294wgb.1
        for <linux-nfs@vger.kernel.org>; Tue, 06 Dec 2011 10:24:22 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <4EDE278B.6020406@tonian.com>
References: <1323000237-13565-1-git-send-email-tigran.mkrtchyan@desy.de>
	<1323000237-13565-3-git-send-email-tigran.mkrtchyan@desy.de>
	<4EDB6AA3.1030702@tonian.com>
	<20111206020851.GA4486@fieldses.org>
	<4EDDFBCD.3010608@tonian.com>
	<CAGue13r9EZJLco0OsfoPH4eyn7Txa0OJqBPavw5cFoiBPN3=2g@mail.gmail.com>
	<20111206134014.GB8657@fieldses.org>
	<4EDE278B.6020406@tonian.com>
Date: Tue, 6 Dec 2011 19:24:21 +0100
Message-ID: <CAGue13qBy-dcv9KQ9xmpSQqX95m5V5GUTUAdgzwO_Ld=77R+ew@mail.gmail.com>
Subject: Re: [PATCH 2/2] nfsv41: handle current stateid on open and close
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Benny Halevy <bhalevy@tonian.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ok, I think  I know what to do. I will update patches later today or tomorrw.

Tigran.

On Tue, Dec 6, 2011 at 3:32 PM, Benny Halevy <bhalevy@tonian.com> wrote:
> On 2011-12-06 15:40, J. Bruce Fields wrote:
>> On Tue, Dec 06, 2011 at 02:31:14PM +0100, Tigran Mkrtchyan wrote:
>>> On Tue, Dec 6, 2011 at 12:26 PM, Benny Halevy <bhalevy@tonian.com> wrote:
>>>> On 2011-12-06 04:08, J. Bruce Fields wrote:
>>>>> On Sun, Dec 04, 2011 at 02:42:11PM +0200, Benny Halevy wrote:
>>>>>> On 2011-12-04 14:03, tigran.mkrtchyan@desy.de wrote:
>>>>>>> From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>>>>>>>
>>>>>>>
>>>>>>> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>>>>>>> ---
>>>>>>>  fs/nfsd/nfs4proc.c  |    6 ++++++
>>>>>>>  fs/nfsd/nfs4state.c |   26 ++++++++++++++++++++------
>>>>>>>  2 files changed, 26 insertions(+), 6 deletions(-)
>>>>>>>
>>>>>>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>>>>>>> index fa38336..535aed2 100644
>>>>>>> --- a/fs/nfsd/nfs4proc.c
>>>>>>> +++ b/fs/nfsd/nfs4proc.c
>>>>>>> @@ -400,6 +400,12 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>>>>>>      */
>>>>>>>     status = nfsd4_process_open2(rqstp, &cstate->current_fh, open);
>>>>>>>     WARN_ON(status && open->op_created);
>>>>>>> +
>>>>>>> +   if(status)
>>>>>>> +           goto out;
>>>>>>> +
>>>>>>> +   /* set current state id */
>>>>>>> +   memcpy(&cstate->current_stateid, &open->op_stateid, sizeof(stateid_t));
>>>>>
>>>>> That comment is a bit redundant.
>>>>>
>>>>>> Since this should be done for all stateid-returning operations
>>>>>> I think that a cleaner approach could be to mark those as such in
>>>>>> nfsd4_ops by providing a per-op function to return the operation's
>>>>>> stateid.  You can then call this method from nfsd4_proc_compound()
>>>>>> after the call to nfsd4_encode_operation() and when status == 0.
>>>>>
>>>>> So the choice is between
>>>>>
>>>>> +       memcpy(&cstate->current_stateid, &open->op_stateid,
>>>>> sizeof(stateid_t));
>>>>>
>>>>> and
>>>>>
>>>>> +       static void get_open_stateid(stateid_t *s)
>>>>> +       {
>>>>> +               memcpy(s, open->op_stateid);
>>>>> +       }
>>>>> +
>>>>> +       [OP_OPEN] = {
>>>>> +               ...
>>>>> +               .op_get_stateid = get_open_stateid,
>>>>> +               ...
>>>>> +       }
>>>>>
>>>>> ?
>>>>>
>>>>> I'm not so sure.
>>>>
>>>> The point is to copy the result stateid into the current_stateid
>>>> in a centralized place: nfsd4_proc_compound() and do that for all
>>>> stateid-modifying operations.
>>>
>>> Sounds good, nevertheless all operations call differently resulting
>>> stateid which make it's not possible to use a unified schema.
>
> That was the point of introducing a per-op method to get the value.
>
>>
>> Could we just remove all (or most) of those different fields and replace
>> them by cstate->current_stateid?
>
> Hmm, that will require changing the corresponding xdr result encoding
> routines to use the new field and all other use sites, but I don't think
> of a good reason why this won't work.
>
> Benny
>
>>
>> --b.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
