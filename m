Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f180.google.com ([209.85.220.180]:61043 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957AbaJASs6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Oct 2014 14:48:58 -0400
Received: by mail-vc0-f180.google.com with SMTP id le20so717976vcb.11
        for <linux-nfs@vger.kernel.org>; Wed, 01 Oct 2014 11:48:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <542C082C.3080602@Netapp.com>
References: <1411876498-12039-1-git-send-email-trond.myklebust@primarydata.com>
	<1411876498-12039-2-git-send-email-trond.myklebust@primarydata.com>
	<1411876498-12039-3-git-send-email-trond.myklebust@primarydata.com>
	<542C082C.3080602@Netapp.com>
Date: Wed, 1 Oct 2014 14:48:57 -0400
Message-ID: <CAHQdGtSc_R-NNjE6nGvONyWoPGXb7hOJ2jpTFtJ2oS0ka6m7aQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] NFSv4: fix open/lock state recovery error handling
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 1, 2014 at 9:57 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> On 09/27/2014 11:54 PM, Trond Myklebust wrote:
>> The current open/lock state recovery unfortunately does not handle errors
>> such as NFS4ERR_CONN_NOT_BOUND_TO_SESSION correctly. Instead of looping,
>> just proceeds as if the state manager is finished recovering.
>> This patch ensures that we loop back, handle higher priority errors
>> and complete the open/lock state recovery.
>>
>> Cc: stable@vger.kernel.org
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  fs/nfs/nfs4state.c | 16 ++++++----------
>>  1 file changed, 6 insertions(+), 10 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index 26d510d11efd..87b2d0e79797 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -1705,7 +1705,8 @@ restart:
>>                       if (status < 0) {
>>                               set_bit(ops->owner_flag_bit, &sp->so_flags);
>>                               nfs4_put_state_owner(sp);
>> -                             return nfs4_recovery_handle_error(clp, status);
>> +                             status = nfs4_recovery_handle_error(clp, status);
>> +                             return (status != 0) ? status : -EAGAIN;
>
> Why is the ternary better than doing something like this?
>
>         if (status == 0)
>                 return -EAGAIN;
>         return status;

It is 2 lines shorter, yet just as legible in this situation.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
