Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:50594 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752852AbeE3NTr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 30 May 2018 09:19:47 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@hammerspace.com>
Cc: anna.schumaker@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSv4: Don't add a new lock on an interrupted wait for
 LOCK
Date: Wed, 30 May 2018 09:18:28 -0400
Message-ID: <FB3B66F5-9436-4E8A-8DD5-F1A7993CD79A@redhat.com>
In-Reply-To: <ea1ea9737290a1a553f179efdc472f084935eb24.camel@hammerspace.com>
References: <1e2732518f990acac47ef20d936ac8a1200d7a79.1525345895.git.bcodding@redhat.com>
 <ea1ea9737290a1a553f179efdc472f084935eb24.camel@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 29 May 2018, at 10:02, Trond Myklebust wrote:

> On Thu, 2018-05-03 at 07:12 -0400, Benjamin Coddington wrote:
>> If the wait for a LOCK operation is interrupted, and then the file is
>> closed, the locks cleanup code will assume that no new locks will be
>> added
>> to the inode after it has completed.  We already have a mechanism to
>> detect
>> if there was signal, so let's use that to avoid recreating the local
>> lock
>> once the RPC completes.  Also skip re-sending the LOCK operation for
>> the
>> various error cases if we were signaled.
>>
>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>> ---
>>  fs/nfs/nfs4proc.c | 24 ++++++++++++++----------
>>  1 file changed, 14 insertions(+), 10 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 47f3c273245e..1aba009a5ef8 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -6345,32 +6345,36 @@ static void nfs4_lock_done(struct rpc_task
>> *task, void *calldata)
>>  	case 0:
>>  		renew_lease(NFS_SERVER(d_inode(data->ctx->dentry)),
>>  				data->timestamp);
>> -		if (data->arg.new_lock) {
>> +		if (data->arg.new_lock && !data->cancelled) {
>>  			data->fl.fl_flags &= ~(FL_SLEEP |
>> FL_ACCESS);
>> -			if (locks_lock_inode_wait(lsp->ls_state-
>>> inode, &data->fl) < 0) {
>> -				rpc_restart_call_prepare(task);
>> +			if (locks_lock_inode_wait(lsp->ls_state-
>>> inode, &data->fl) > 0)
>
> AFAICS this will never be true; It looks to me as if
> locks_lock_inode_wait() always returns '0' or a negative error value.
> Am I missing something?

No you're not missing anything, you're catching a typo, it should be:

 +			if (locks_lock_inode_wait(lsp->ls_state-> inode, &data->fl) < 0)

We want to break out of the switch and restart the rpc call if
locks_lock_inode_wait returns an error.  Should I send another version or
can you fix it up?

Ben
