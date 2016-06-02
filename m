Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33872 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932446AbcFBTs7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jun 2016 15:48:59 -0400
Received: by mail-io0-f193.google.com with SMTP id l9so7847430ioe.1
        for <linux-nfs@vger.kernel.org>; Thu, 02 Jun 2016 12:48:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyEdttEMqepHWmd-KgUcH-azbnko4QJsVuwQha=GSVgzoA@mail.gmail.com>
References: <CAN-5tyFXzH+Je8Th_irarJtBb+9QziFj8p7xH0NRLupOsTYBrw@mail.gmail.com>
	<F693F912-2BA0-4899-A73C-65CB7536B090@primarydata.com>
	<CAN-5tyEdttEMqepHWmd-KgUcH-azbnko4QJsVuwQha=GSVgzoA@mail.gmail.com>
Date: Thu, 2 Jun 2016 15:48:58 -0400
Message-ID: <CAN-5tyEnAAkw58Zn70YkN-neJVJUkCLVAc1dbz4F22rsUoQnZQ@mail.gmail.com>
Subject: Re: open_downgrade use
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 1, 2016 at 4:59 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Wed, Jun 1, 2016 at 4:41 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
>> You are misreading what I wrote. Your test should indeed give rise to an
>> OPEN_DOWNGRADE (unless there is a delegation involved). The code that was
>> misbehaving and that was fixed by the patch was triggering an OPEN_DOWNGRADE
>> from a stateid that had only been opened for RW.
>
> I see. With this patch, the upstream code no longer sends an
> OPEN_DOWNGRADE. I will investigate why then as it seems like a bug.

Can you please help explain the logic of this commit as my solution is
to negate this:

commit aee7af356e151494d5014f57b33460b162f181b5
Author: Trond Myklebust <trond.myklebust@primarydata.com>
Date:   Mon Aug 25 22:33:12 2014 -0400

    NFSv4: Fix problems with close in the presence of a delegation

    In the presence of delegations, we can no longer assume that the
    state->n_rdwr, state->n_rdonly, state->n_wronly reflect the open
    stateid share mode, and so we need to calculate the initial value
    for calldata->arg.fmode using the state->flags.

    Reported-by: James Drews <drews@engr.wisc.edu>
    Fixes: 88069f77e1ac5 (NFSv41: Fix a potential state leakage when...)
    Cc: stable@vger.kernel.org # 2.6.33+
    Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

When close(fd0) come which suppose to translate into OPEN_DOWNGRADE:

nfs4_close_prepare is_rdwr=1 is_rdonly=1 is_wronly=0 n_rdwr=0
n_rdonly=1 n_wonly=0

        if (state->n_rdwr == 0) {
                if (state->n_rdonly == 0)
                        call_close |= is_rdonly;
                else if (is_rdonly)
                        calldata->arg.fmode |= FMODE_READ;  <** this
is set but call_close ends up being 0 **>
                if (state->n_wronly == 0)
                        call_close |= is_wronly;
                else if (is_wronly)
                        calldata->arg.fmode |= FMODE_WRITE;
        } else if (is_rdwr)
                calldata->arg.fmode |= FMODE_READ|FMODE_WRITE;

so then the check for !call_close later sends it to no_action and
nothing is sent.

Here's what I propose to fix it:
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 327b8c3..1db2e31 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2870,7 +2870,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void
                call_close = 0;
        spin_unlock(&state->owner->so_lock);

-       if (!call_close) {
+       if (!call_close && !calldata->arg.fmode) {
                /* Note: exit _without_ calling nfs4_close_done */
                goto out_no_action;
        }

But then I really don't understand why not sent call_close for if
(is_rdonly) case?

Thank you.
>
>>
>>
>> On 6/1/16, 16:31, "linux-nfs-owner@vger.kernel.org on behalf of Olga
>> Kornievskaia" <linux-nfs-owner@vger.kernel.org on behalf of aglo@umich.edu>
>> wrote:
>>
>>>I'm failing to think of what can trigger an open_downgrade?
>>>I thought the following example should trigger an open downgrade:
>>>
>>>fd0 = open(foo, RDRW) -- should be open on the wire for "both"
>>>fd1 = open(foo, RDONLY) -- should be open on the wire for "read"
>>>close(fd0) -- should trigger an open_downgrade
>>>read(fd1)
>>>close(fd1)
>>>
>>>However this commit says that it's not allowed by the spec.
>>>
>>>commit cd9288ffaea4359d5cfe2b8d264911506aed26a4
>>>Author: Trond Myklebust <trond.myklebust@primarydata.com>
>>>Date: Thu Sep 18 11:51:32 2014 -0400
>>>
>>> NFSv4: Fix another bug in the close/open_downgrade code
>>>
>>> James Drew reports another bug whereby the NFS client is now sending
>>> an OPEN_DOWNGRADE in a situation where it should really have sent a
>>> CLOSE: the client is opening the file for O_RDWR, but then trying to
>>> do a downgrade to O_RDONLY, which is not allowed by the NFSv4 spec.
>>>
>>> Reported-by: James Drews <drews@engr.wisc.edu>
>>> Link: http://lkml.kernel.org/r/541AD7E5.8020409@engr.wisc.edu
>>> Fixes: aee7af356e15 (NFSv4: Fix problems with close in the presence...)
>>> Cc: stable@vger.kernel.org # 2.6.33+
>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>>>
>>>If RDWR to RDONLY isn't allowed then why do we have OPEN_DOWNGRADE at all?
>>>--
>>>To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>the body of a message to majordomo@vger.kernel.org
>>>More majordomo info at http://vger.kernel.org/majordomo-info.html
>>>
>>
>>
>> Disclaimer
>>
>> The information contained in this communication from the sender is
>> confidential. It is intended solely for use by the recipient and others
>> authorized to receive it. If you are not the recipient, you are hereby
>> notified that any disclosure, copying, distribution or taking action in
>> relation of the contents of this information is strictly prohibited and may
>> be unlawful.
