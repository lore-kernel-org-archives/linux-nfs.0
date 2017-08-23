Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52566 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932407AbdHWU1b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 23 Aug 2017 16:27:31 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] NFSv4: Don't add a new lock on an interrupted wait for
 LOCK
Date: Wed, 23 Aug 2017 16:27:30 -0400
Message-ID: <B136DA81-CF93-4F25-B00D-855BC7B64D88@redhat.com>
In-Reply-To: <ED0CEBFE-82F4-41CE-BB7B-A7E7A73753FB@redhat.com>
References: <1501618320.4702.14.camel@redhat.com>
 <cda7d9d6f145289d2855eb733a8d795938e67453.1501673116.git.bcodding@redhat.com>
 <D7F32DDE-7DE7-46F6-87AA-F6FF68397BE3@redhat.com>
 <1503519306.78164.1.camel@primarydata.com>
 <ED0CEBFE-82F4-41CE-BB7B-A7E7A73753FB@redhat.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 23 Aug 2017, at 16:25, Benjamin Coddington wrote:

> On 23 Aug 2017, at 16:15, Trond Myklebust wrote:
>
>> On Wed, 2017-08-23 at 16:11 -0400, Benjamin Coddington wrote:
>>> Ping on this one as well -- it was buried in a thread:
>>>
>>> Ben
>>>
>>> On 2 Aug 2017, at 7:27, Benjamin Coddington wrote:
>>>
>>>> If the wait for a LOCK operation is interrupted, and then the file
>>>> is
>>>> closed, the locks cleanup code will assume that no new locks will
>>>> be
>>>> added
>>>> to the inode after it has completed.  We already have a mechanism
>>>> to
>>>> detect
>>>> if there was signal, so let's use that to avoid recreating the
>>>> local
>>>> lock
>>>> once the RPC completes.
>>>>
>>>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>>>> Reviewed-by: Jeff Layton <jlayton@redhat.com>
>>>> ---
>>>>  fs/nfs/nfs4proc.c | 2 +-
>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>>> index dbfa18900e25..5256f429c268 100644
>>>> --- a/fs/nfs/nfs4proc.c
>>>> +++ b/fs/nfs/nfs4proc.c
>>>> @@ -6100,7 +6100,7 @@ static void nfs4_lock_done(struct rpc_task
>>>> *task, void *calldata)
>>>>  	case 0:
>>>>  		renew_lease(NFS_SERVER(d_inode(data->ctx-
>>>>> dentry)),
>>>>  				data->timestamp);
>>>> -		if (data->arg.new_lock) {
>>>> +		if (data->arg.new_lock && !data->cancelled) {
>>>>  			data->fl.fl_flags &= ~(FL_SLEEP |
>>>> FL_ACCESS);
>>>>  			if (locks_lock_inode_wait(lsp->ls_state-
>>>>> inode, &data->fl) < 0) {
>>>>  				rpc_restart_call_prepare(task);
>>>>
>>
>> Why do we want to special case '0'? Surely we don't want to restart the
>> RPC call for any of the error cases if data->cancelled is set.
>
> We don't want to add the local lock if data->cancelled is set.  It's
> possible that the file has already been closed and the locks cleanup code
> has removed all of the local locks, so if this races in and adds a lock we
> end up with one left over.
>
> I don't understand what you mean about restarting the RPC call - we'd only
> restart the RPC call here if there was an error adding the local lock.

Oh, I see what you mean.. we ought to bail out even if there is an error.
That makes sense, I can send this again.

Ben
