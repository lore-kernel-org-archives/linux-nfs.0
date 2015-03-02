Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx141.netapp.com ([216.240.21.12]:18385 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754002AbbCBVCJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Mar 2015 16:02:09 -0500
Message-ID: <54F4CFCE.2040704@Netapp.com>
Date: Mon, 2 Mar 2015 16:02:06 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Olga Kornievskaia <aglo@umich.edu>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: buggy CLOSE in the "testing" branch
References: <CAN-5tyEYVSNeBzN8Ok=vmjxrMj-fhYQSL=ny4rqvx4r5TQNLyg@mail.gmail.com>	<CAHQdGtQxR_VT+8g5oNLHcsBOKcWVG6j7c+A2rQBO7VkP9E6WPA@mail.gmail.com> <CAN-5tyGY=gA8zCfnQCKMmvV2TDDGHBHVt+0Df9sj2mtytJpA5g@mail.gmail.com>
In-Reply-To: <CAN-5tyGY=gA8zCfnQCKMmvV2TDDGHBHVt+0Df9sj2mtytJpA5g@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/02/2015 03:53 PM, Olga Kornievskaia wrote:
> On Mon, Mar 2, 2015 at 3:47 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> Hi Olga,
>>
>> On Mon, Mar 2, 2015 at 3:15 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>> Hi folks,
>>>
>>> I'm experiencing that CLOSE uses a delegation stateid instead of the
>>> open stateid which I think is what the spec says. Server replies with
>>> BAD_STATEID.
>>>
>>> Is this a bug or did I misread the spec? Thanks.
>>>
>>
>> That would be a client bug. Do you have a reproducer?
> 
> Yep. Just cat a (2nd) file after mount (i.e.., a file needs to have a
> delegation). A CLOSE will use a delegation stateid. Problem is seenl
> on the network trace. It will also leads to failure on unmount with
> CLIENTID_BUSY because there is still an open state that client never
> released. Please note that both "cat" and "unmount" will "succeed"
> from the user's perspective. Thus, unless testing also looks at the
> network trace, this failure will never be caught.

Does this change help?  Comments next to the nfs4_state stateid field say that it could hold a delegation stateid.

Anna

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a211daf..7b409ff 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2691,7 +2691,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
        is_rdwr = test_bit(NFS_O_RDWR_STATE, &state->flags);
        is_rdonly = test_bit(NFS_O_RDONLY_STATE, &state->flags);
        is_wronly = test_bit(NFS_O_WRONLY_STATE, &state->flags);
-       nfs4_stateid_copy(&calldata->arg.stateid, &state->stateid);
+       nfs4_stateid_copy(&calldata->arg.stateid, &state->open_stateid);
        /* Calculate the change in open mode */
        calldata->arg.fmode = 0;
        if (state->n_rdwr == 0) {


> 
> 
>>
>> --
>> Trond Myklebust
>> Linux NFS client maintainer, PrimaryData
>> trond.myklebust@primarydata.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

