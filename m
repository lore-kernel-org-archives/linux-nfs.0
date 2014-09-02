Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f172.google.com ([209.85.220.172]:58667 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754581AbaIBTcz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2014 15:32:55 -0400
Received: by mail-vc0-f172.google.com with SMTP id ij19so7626023vcb.17
        for <linux-nfs@vger.kernel.org>; Tue, 02 Sep 2014 12:32:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140902192328.GA3873@infradead.org>
References: <1409680738-12491-1-git-send-email-trond.myklebust@primarydata.com>
	<1409680738-12491-2-git-send-email-trond.myklebust@primarydata.com>
	<20140902192328.GA3873@infradead.org>
Date: Tue, 2 Sep 2014 15:32:55 -0400
Message-ID: <CAHQdGtRcyphAktKfdx8PKzbcExOmJsNCkCYFu9syfGjmS+J+TQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] nfs: do not start the callback thread until we set rqstp->rq_task
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Bruce Fields <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 2, 2014 at 3:23 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Tue, Sep 02, 2014 at 01:58:58PM -0400, Trond Myklebust wrote:
>> This fixes an Oopsable race when starting up the callback server.
>>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  fs/nfs/callback.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
>> index e3dd1cd175d9..b8fb3a4ef649 100644
>> --- a/fs/nfs/callback.c
>> +++ b/fs/nfs/callback.c
>> @@ -235,7 +235,7 @@ static int nfs_callback_start_svc(int minorversion, struct rpc_xprt *xprt,
>>
>>       cb_info->serv = serv;
>>       cb_info->rqst = rqstp;
>> -     cb_info->task = kthread_run(callback_svc, cb_info->rqst,
>> +     cb_info->task = kthread_create(callback_svc, cb_info->rqst,
>>                                   "nfsv4.%u-svc", minorversion);
>>       if (IS_ERR(cb_info->task)) {
>>               ret = PTR_ERR(cb_info->task);
>> @@ -245,6 +245,7 @@ static int nfs_callback_start_svc(int minorversion, struct rpc_xprt *xprt,
>>               return ret;
>>       }
>>       rqstp->rq_task = cb_info->task;
>> +     wake_up_process(cb_info->task);
>
> Wouldn't it be cleaner to do something like:
>
> -       cb_info->task = kthread_run(callback_svc, cb_info->rqst,
> +       cb_info->task = rqstp->rq_run =
> +               kthread_create(callback_svc, cb_info->rqst,
>
> or am I missing something subtile that the changelog didn't mention?

The above is fine if you call kthread_create(), but if you stick with
kthread_run(), then there is still the same atomicity issue that the
thread can be started before we've initialised cb_info->task and
rqstp->rq_run.

Internal testing has shown that this can lead to an oops when starting
lockd. I'm therefore assuming that the same thing can happen with the
NFS client callback channel.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
