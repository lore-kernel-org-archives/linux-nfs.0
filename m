Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f177.google.com ([209.85.212.177]:57135 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588AbaKFTQA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Nov 2014 14:16:00 -0500
Received: by mail-wi0-f177.google.com with SMTP id ex7so2490457wid.10
        for <linux-nfs@vger.kernel.org>; Thu, 06 Nov 2014 11:15:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyE3pH0Y-RRGEoufQ-YWBJ=CQ_fBa0UJN0EF=e+TiHEzVQ@mail.gmail.com>
References: <1415025403-31914-1-git-send-email-kolga@netapp.com>
	<CAN-5tyHVoJ60z7WBaCYvUN3GsCEGh9jGc0evRCuiVt2aA6zP0g@mail.gmail.com>
	<CAHQdGtQWg+Fiyn7vH9pjU1GR-TKvMp+gcR7ssaA1zESQ8JdVsw@mail.gmail.com>
	<CAN-5tyEOLnq_v_8X6zNXX4u2oOdJeJHpEmxsr_yOAfHFZxyhyA@mail.gmail.com>
	<CAHQdGtTMtWLoeAmhCZRC2gdh5h=vHuUAT_am5_0h5L7FNZdQiA@mail.gmail.com>
	<CAN-5tyE3pH0Y-RRGEoufQ-YWBJ=CQ_fBa0UJN0EF=e+TiHEzVQ@mail.gmail.com>
Date: Thu, 6 Nov 2014 14:15:58 -0500
Message-ID: <CAHQdGtQw_7tWuGEZOwdUWN6TEaTn85kkmAQb_nPF5QaTrk487w@mail.gmail.com>
Subject: Re: [PATCH 1/1] Fixing infinite state recovery loop due to failed
 delegation return
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 6, 2014 at 1:54 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Wed, Nov 5, 2014 at 1:38 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> On Wed, Nov 5, 2014 at 12:53 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>> Thank you for looking into this!
>>>
>>> On Tue, Nov 4, 2014 at 7:14 PM, Trond Myklebust
>>> <trond.myklebust@primarydata.com> wrote:
>>>> On Tue, Nov 4, 2014 at 6:22 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>> Trond, can you please respond to the patch?
>>>>>
>>>>> As per earlier conversation, in this solution, state recovery is
>>>>> initiated which marks the locks lost.
>>>>>
>>>>> Please either accept this patch or let me know what needs to be fixed.
>>>>>
>>>>
>>>> Please see the 3 fixes I just sent out concerning delegation recovery
>>>> w.r.t. NFSv4+NFSv4.1. In addition, we need to handle the case you
>>>> patch attempts to address (however see the question I have below).
>>>>
>>>>> Thank you.
>>>>>
>>>>> On Mon, Nov 3, 2014 at 9:36 AM, Olga Kornievskaia <kolga@netapp.com> wrote:
>>>>>> If we get a bad-stateid-type of error when we send OPEN with delegate_cur
>>>>>> to return currently held delegation, we shouldn't be trying to reclaim locks
>>>>>> associated with that delegation state_id because we don't have an
>>>>>> open_stateid to be used for the LOCK operation. Thus, we should
>>>>>> return an error from the nfs4_open_delegation_recall() in that case.
>>>>>>
>>>>>> Furthermore, if an error occurs the delegation code will call
>>>>>> nfs_abort_delegation_return() which sets again the NFS4CLNT_DELEGRETURN
>>>>>> flags in the state and it leads the state manager to into an infinite loop
>>>>>> for trying to reclaim the delegated state.
>>>>>>
>>>>>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>>>>>> ---
>>>>>>  fs/nfs/delegation.c |    5 +++--
>>>>>>  fs/nfs/nfs4proc.c   |    2 +-
>>>>>>  2 files changed, 4 insertions(+), 3 deletions(-)
>>>>>>
>>>>>> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
>>>>>> index 5853f53..8016d89 100644
>>>>>> --- a/fs/nfs/delegation.c
>>>>>> +++ b/fs/nfs/delegation.c
>>>>>> @@ -394,7 +394,7 @@ static int nfs_end_delegation_return(struct inode *inode, struct nfs_delegation
>>>>>>                 err = nfs4_wait_clnt_recover(clp);
>>>>>>         } while (err == 0);
>>>>>>
>>>>>> -       if (err) {
>>>>>> +       if (err && err != -EIO) {
>>>>>>                 nfs_abort_delegation_return(delegation, clp);
>>>>
>>>> This exception for EIO now has me worried. If we detach the
>>>> delegation, then it looks to me as if we will never send a
>>>> FREE_STATEID, as required for the case of NFSv4.1.
>>>
>>> I'd need to brush up on the FREE_STATEID op to confidently answer
>>> that. But can't this be taken care of in state_recovery when locks are
>>> marked lost?
>>
>> No, because in the case of EIO we now fall through to
>> nfs_detach_delegation() and nfs_do_return_delegation(). What we really
>> want to do is call TEST_STATEID + FREE_STATEID (see RFC5661 sections
>> 8.2.4, 8.5 and 18.38.3), which will now be done as part of state
>> recovery.
>
> I don't see it. :-/ Is it because there is a race between returning a
> delegation and state recovery that was initiated? Because as far as I
> can see, the stateid recovery initiated by the
> handle_delegation_recall_error() will call nfs4_test_stateid() via
> nfs41_open_expire().
>

No. My point is that once we call nfs_detach_delegation(), then nobody
will be able to find the delegation from either the struct nfs_inode
or from the server->delegations list.
IOW: the question is how would the state recovery thread find it in
the first place?

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
