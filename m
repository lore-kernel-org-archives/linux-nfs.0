Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:41733 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753663AbaJQTe0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Oct 2014 15:34:26 -0400
Received: by mail-ie0-f173.google.com with SMTP id tp5so1406806ieb.32
        for <linux-nfs@vger.kernel.org>; Fri, 17 Oct 2014 12:34:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyGF1QTe1PuA_XoJG9CocAhTHfR6HOJTQwkSksRLb06uoA@mail.gmail.com>
References: <CAN-5tyGT71Y3DZ-V16ikjDa-+6Bt_j_2QwkQZyQMSZSLun5CaA@mail.gmail.com>
	<CAHQdGtSoowMb4tz1gVTTf1xRY8jwwgQOX_2CxPC_xziWurmw4Q@mail.gmail.com>
	<CAN-5tyE8zt5iUQUFp+2iz9oP37HJhQ54YtSgesWs6Cu66A6qZw@mail.gmail.com>
	<CAHQdGtQ6WYe0qgn7b7s2TW_HFsq2ZCwyMuMW8PO_10xLh79QFQ@mail.gmail.com>
	<CAN-5tyFKhmHOzV6gmgKJkjSL-cgd_uK0ef6kHXWER7JBvbwTjw@mail.gmail.com>
	<CAHQdGtQN=0aitE=nSOSdA0ROZMfdchnshQoe-EkeoHBdbFBjsg@mail.gmail.com>
	<CAN-5tyGF1QTe1PuA_XoJG9CocAhTHfR6HOJTQwkSksRLb06uoA@mail.gmail.com>
Date: Fri, 17 Oct 2014 15:34:25 -0400
Message-ID: <CAN-5tyEt4XsGBn-LiUxb+W6MqtZ-eNf-LNmujxUudWRPkqtoEA@mail.gmail.com>
Subject: Re: nfs4_lock_delegation_recall() improperly handles errors such as ERROR_GRACE
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 24, 2014 at 7:20 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Wed, Sep 24, 2014 at 6:45 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> On Wed, Sep 24, 2014 at 6:31 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>> On Wed, Sep 24, 2014 at 3:57 PM, Trond Myklebust
>>> <trond.myklebust@primarydata.com> wrote:
>>>> Hi Olga,
>>>>
>>>> On Wed, Sep 24, 2014 at 2:20 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>> Hi Trond,
>>>>>
>>>>> nfs_delegation_claim_opens() return EAGAIN to nfs_end_delegation_return().
>>>>> issync is always 0 (as its called by the
>>>>> nfs_client_return_marked_delegations) and it breaks out of the loop...
>>>>> as a result the error just doesn't get handled.
>>>>
>>>> Ah. OK, so this is being called from
>>>> nfs_client_return_marked_delegations. That makes sense.
>>>>
>>>> So for that case, I'd expect the call to return to the loop in
>>>> nfs4_state_manager(), and then to retry through that after doing
>>>> whatever is needed to recover.
>>>> Essentially, we should be setting NFS4CLNT_DELEGRETURN again, and then
>>>> bouncing back into nfs_client_return_marked_delegations (after all the
>>>> recovery work has been done).
>>>
>>> Yes I don't fully understand what it should be. It never does anything
>>> about recovering from the lock error and simply returns the
>>> delegation. Ok I don't know if it means anything to you, but the 2nd
>>> time around (when it returns the delegation even though it hasn't
>>> recovered the lock), it never goes into the
>>> nfs4_open_delegation_recall() because stateid condition doesn't hold
>>> true.
>>>
>>> If it's not too much trouble, could you explain why lock error
>>> shouldn't be handled as I suggested instead of resending the open with
>>> claim_cur over again. As I understand in your case, it'll be a series
>>> of successful open with claim_cur paired with a failed lock with
>>> err_grace. In my case, it'll be one open with claim_cur and a number
>>> of lock with err_grace.
>>
>> There is only 1 state manager thread allowed per nfs_client (i.e. per
>> server) and so we want to avoid having it busy wait in any one state
>> handler. Doing so would basically mean that all other state recovery
>> on that nfs_client is on hold; i.e. we could not deal with exceptions
>> like ADMIN_REVOKED, CB_PATH_DOWN, etc until the busy wait is over.
>> This is why that code has been designed to fall all the way back to
>> nfs4_state_manager() in the event of any error/exception.
>
> Ok, thanks. It make sense. And makes things complicated. I'm sure
> you'll beat me to figuring out why the error is not handled but I'll
> keep trying.
>


I believe the cause of the improper handling of LOCK errors during
return of delegations is in the check of matching stateid in
nfs_delegation_claim_opens(). After the first attempt of returning the
delegation -- sending an open with delegate_cur and then the lock
which errors -- the code properly errors out, aborts the delegation
return and will try again. However, the stateid at this point has been
update to the open_stateid received by that open. The check for
matching stateid and delegation stateid fails, so it skips this open
and just returns the delegation and moves forward.

I'd like an option about either
(1) removing the check for matching state ids as a solution, or
(2) should the stateid be updated back to the delegation stateid
(which i think be wrong)?


>>
>> --
>> Trond Myklebust
>>
>> Linux NFS client maintainer, PrimaryData
>>
>> trond.myklebust@primarydata.com
