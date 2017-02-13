Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33080 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751850AbdBMNrt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2017 08:47:49 -0500
Received: by mail-wr0-f194.google.com with SMTP id i10so24263043wrb.0
        for <linux-nfs@vger.kernel.org>; Mon, 13 Feb 2017 05:47:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1486827922.3490.2.camel@primarydata.com>
References: <CAPrqf9378wbKmv9EaiuFzYLwvCxziXtkk-ZY-jsJxSOgSNm+QA@mail.gmail.com>
 <1486739454.19587.1.camel@primarydata.com> <CAPrqf938zLB73tShOZyeQDacDR5J9VaHhF4_-t7eEjecWocyUQ@mail.gmail.com>
 <1486827922.3490.2.camel@primarydata.com>
From: Pankaj Singh <psingh.ait@gmail.com>
Date: Mon, 13 Feb 2017 19:17:47 +0530
Message-ID: <CAPrqf90bJ-e1bwNv-osLr8LtCaGTbm8y8XgDwHF7VfWtBsOz1A@mail.gmail.com>
Subject: Re: How NLM support posix threads?
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

> I agree. That is a bug and it needs to be fixed. How about the
following?

Thanks for acknowledging the bug. Fix seems to be good.

On Sat, Feb 11, 2017 at 9:15 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
> On Sat, 2017-02-11 at 11:49 +0530, Pankaj Singh wrote:
>> > During "fl_grant" callback wrong "block" will be compared hence
>> > this will result in lock failure even if lock is actually granted.
>>
>> "nlm_compare_locks" will compare the locks on the bases of pid,
>> owner,
>> start offset, end offset and type. In case of posix threads as pid is
>> same, also all other parameters can be same for locks of different
>> files.
>>
>> Now the scenario is, if there are two posix thread with pid p1 and
>> they try to take the lock on different files (say l1 and l2) then
>> different blocks will be created (say b1 and b2). In this case
>> underline filesystem may send "FILE_LOCK_DEFERRED" for both the locks
>> and these blocks will be added to deferred block list.
>>
>> So during "fl_grant" callback lock are compared with the blocks of
>> block list. Now lets say callback is called for l1 and the comparison
>> will succeed with b1 (this is as expected) and B_GOT_CALLBACK flag
>> will be set. But as b1 is still in block list, now when callback for
>> l2 arrives then also comparison with b1 can succeed instead of b2
>> because b1 is prior to b2 in the list. Hence B_GOT_CALLBACK flag will
>> not be set for b2 and when NFS client will retry for lock then lock
>> will be denied.
>>
>> Below is the snipt fl_grant code where comparison happens.
>> list_for_each_entry(block, &nlm_blocked, b_list) {
>> if (nlm_compare_locks(&block->b_call->a_args.lock.fl, fl)
>
> OK. I see what you mean. You are saying, in essence, that in the lockd
> server code, nlmsvc_notify_blocked() needs to check that the files are
> the same (just like nlmsvc_lookup_block() already does).
>
> I agree. That is a bug and it needs to be fixed. How about the
> following?
>
> Cheers
>   Trond
> 8<---------------------------------------------------------------
> From fff75e35ed857b9ad211905fee2acffa528696d9 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Sat, 11 Feb 2017 10:37:38 -0500
> Subject: [PATCH] nlm: Ensure callback code also checks that the files match
>
> It is not sufficient to just check that the lock pids match when
> granting a callback, we also need to ensure that we're granting
> the callback on the right file.
>
> Reported-by: Pankaj Singh <psingh.ait@gmail.com>
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Cc: stable@vger.kernel.org
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  include/linux/lockd/lockd.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
> index c15373894a42..b37dee3acaba 100644
> --- a/include/linux/lockd/lockd.h
> +++ b/include/linux/lockd/lockd.h
> @@ -355,7 +355,8 @@ static inline int nlm_privileged_requester(const struct svc_rqst *rqstp)
>  static inline int nlm_compare_locks(const struct file_lock *fl1,
>                                     const struct file_lock *fl2)
>  {
> -       return  fl1->fl_pid   == fl2->fl_pid
> +       return file_inode(fl1->fl_file) == file_inode(fl2->fl_file)
> +            && fl1->fl_pid   == fl2->fl_pid
>              && fl1->fl_owner == fl2->fl_owner
>              && fl1->fl_start == fl2->fl_start
>              && fl1->fl_end   == fl2->fl_end
> --
> 2.9.3
>
> --
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com



-- 
Regards,
Pankaj SIngh
Phone No: 8826266889
