Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35966 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757970AbcKCQis (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Nov 2016 12:38:48 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>,
        "Jeff Layton" <jlayton@redhat.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/6] NFSv4: change nfs4_do_setattr to take an open_context
 instead of a nfs4_state.
Date: Thu, 03 Nov 2016 12:38:45 -0400
Message-ID: <82FF393E-B8F1-4357-9DBC-F467F7082DB7@redhat.com>
In-Reply-To: <877f8lqwv3.fsf@notabene.neil.brown.name>
References: <147633263771.766.17853370901003798934.stgit@noble>
 <147633280745.766.9047567139865023402.stgit@noble>
 <0773ADA2-C1DE-4D01-8B3C-5883A6A62C2E@redhat.com>
 <877f8lqwv3.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2 Nov 2016, at 19:34, NeilBrown wrote:

> On Thu, Nov 03 2016, Benjamin Coddington wrote:
>
>> On 13 Oct 2016, at 0:26, NeilBrown wrote:
>
>>> @@ -3694,20 +3695,17 @@ nfs4_proc_setattr(struct dentry *dentry,
>>> struct nfs_fattr *fattr,
>>>
>>>  	/* Search for an existing open(O_WRITE) file */
>>>  	if (sattr->ia_valid & ATTR_FILE) {
>>> -		struct nfs_open_context *ctx;
>>>
>>>  		ctx = nfs_file_open_context(sattr->ia_file);
>>> -		if (ctx) {
>>> +		if (ctx)
>>>  			cred = ctx->cred;
>>> -			state = ctx->state;
>>> -		}
>>>  	}
>>
>>
>> Does this need a get_nfs_open_context() there to make sure the open
>> context
>> doesn't drop away?
>
> I can't see why you would.  The ia_file must hold a reference to the
> ctx, and this code doesn't keep any reference to the ctx after
> nfs4_proc_setattr completes - does it?

I had a thought that the file pointer could be shared, and just checking to
see if the file's private data was set didn't mean that this task set it.
I'm probably wrong about that, and I'm definitely wrong about the fix, since
it will crash taking a reference.  It just took much longer this time.

>>     I'm getting this on generic/089:
>>
>> [  651.855291] run fstests generic/089 at 2016-11-01 11:15:57
>> [  652.645828] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
>> [  653.166259] NFSD: client ::1 testing state ID with incorrect client
>> ID
>> [  653.167218] BUG: unable to handle kernel NULL pointer dereference at
>> 0000000000000018
>
> I think this BUG is happening in nfs41_check_expired_locks.
> This:
> 	list_for_each_entry(lsp, &state->lock_states, ls_locks) {
> walks off the end of a list, finding a NULL on a list which should never
> have a NULL pointer.  That does suggest a use-after-free of an
> nfs4_lock_state, or possibly of an nfs4_state.
>
> I can't see it in the code yet though.

Yes, walking off the list, and I had some idea that we were getting
duplicate fl_owners from a bad lock_context, but today that doesn't make
any sense to me.  I can't see how this can happen either.

>>
>> Something else is also wrong there.. wrapping that with
>> get_nfs_open_context() makes the crash go away, but there are still
>> several
>> "NFS: nfs4_reclaim_open_state: Lock reclaim failed!" in the log.   Why
>> would
>> we be doing reclaim at all?  I'll look at a network capture next.
>
> The
>> [  653.166259] NFSD: client ::1 testing state ID with incorrect client ID
>
> errors suggests that the client is sending a stateid that doesn't match
> the client id, so the server reports and error and the client enters
> state recovery.
> Maybe one thread is dropping a flock lock while another thread is using
> it for some IO and they race?  I think there are refcounts in place to
> protect that but something might be missing.
>
> I look forward to seeing the network capture.

The network capture isn't very enlightening.. or I haven't been able to find
where the problem happens in the 800Mb of capture.  I probably need to make
the box panic on oops and capture externally so the problem is right at the
end of the capture.  I'll keep plugging away at this as I can.

Ben

