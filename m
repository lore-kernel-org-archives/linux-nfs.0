Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:41524 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752228AbcFKPlc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Jun 2016 11:41:32 -0400
Subject: Re: [PATCH] nfsd: Close a race between access checking/setting in nfs4_get_vfs_file
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=windows-1252
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <20160610205545.GA13766@fieldses.org>
Date: Sat, 11 Jun 2016 11:41:18 -0400
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Andrew W Elble <aweits@rit.edu>
Message-Id: <B1897F84-EAAF-4AA4-921E-6FFD7FED0A9A@linuxhacker.ru>
References: <1465406560.30890.10.camel@poochiereds.net> <1465506099-475103-1-git-send-email-green@linuxhacker.ru> <D672EBB0-E73C-4BA6-BB2C-F687CA780CBA@linuxhacker.ru> <1465555833.1425.15.camel@poochiereds.net> <20160610205545.GA13766@fieldses.org>
To: "J . Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 10, 2016, at 4:55 PM, J . Bruce Fields wrote:

> On Fri, Jun 10, 2016 at 06:50:33AM -0400, Jeff Layton wrote:
>> On Fri, 2016-06-10 at 00:18 -0400, Oleg Drokin wrote:
>>> On Jun 9, 2016, at 5:01 PM, Oleg Drokin wrote:
>>> 
>>>> Currently there's an unprotected access mode check in
>>>> nfs4_upgrade_open
>>>> that then calls nfs4_get_vfs_file which in turn assumes whatever
>>>> access mode was present in the state is still valid which is racy.
>>>> Two nfs4_get_vfs_file van enter the same path as result and get two
>>>> references to nfs4_file, but later drop would only happens once
>>>> because
>>>> access mode is only denoted by bits, so no refcounting.
>>>> 
>>>> The locking around access mode testing is introduced to avoid this
>>>> race.
>>>> 
>>>> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
>>>> ---
>>>> 
>>>> This patch performs equally well to the st_rwsem -> mutex
>>>> conversion,
>>>> but is a bit ligher-weight I imagine.
>>>> For one it seems to allow truncates in parallel if we ever want it.
>>>> 
>>>> fs/nfsd/nfs4state.c | 28 +++++++++++++++++++++++++---
>>>> 1 file changed, 25 insertions(+), 3 deletions(-)
>>>> 
>>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>>>> index f5f82e1..d4b9eba 100644
>>>> --- a/fs/nfsd/nfs4state.c
>>>> +++ b/fs/nfsd/nfs4state.c
>>>> @@ -3958,6 +3958,11 @@ static __be32 nfs4_get_vfs_file(struct
>>>> svc_rqst *rqstp, struct nfs4_file *fp,
>>>> 
>>>> 	spin_lock(&fp->fi_lock);
>>>> 
>>>> +	if (test_access(open->op_share_access, stp)) {
>>>> +		spin_unlock(&fp->fi_lock);
>>>> +		return nfserr_eagain;
>>>> +	}
>>>> +
>>>> 	/*
>>>> 	 * Are we trying to set a deny mode that would conflict with
>>>> 	 * current access?
>>>> @@ -4017,11 +4022,21 @@ nfs4_upgrade_open(struct svc_rqst *rqstp,
>>>> struct nfs4_file *fp, struct svc_fh *c
>>>> 	__be32 status;
>>>> 	unsigned char old_deny_bmap = stp->st_deny_bmap;
>>>> 
>>>> -	if (!test_access(open->op_share_access, stp))
>>>> -		return nfs4_get_vfs_file(rqstp, fp, cur_fh, stp,
>>>> open);
>>>> +again:
>>>> +	spin_lock(&fp->fi_lock);
>>>> +	if (!test_access(open->op_share_access, stp)) {
>>>> +		spin_unlock(&fp->fi_lock);
>>>> +		status = nfs4_get_vfs_file(rqstp, fp, cur_fh, stp,
>>>> open);
>>>> +		/*
>>>> +		 * Somebody won the race for access while we did
>>>> not hold
>>>> +		 * the lock here
>>>> +		 */
>>>> +		if (status == nfserr_eagain)
>>>> +			goto again;
>>>> +		return status;
>>>> +	}
>>>> 
>>>> 	/* test and set deny mode */
>>>> -	spin_lock(&fp->fi_lock);
>>>> 	status = nfs4_file_check_deny(fp, open->op_share_deny);
>>>> 	if (status == nfs_ok) {
>>>> 		set_deny(open->op_share_deny, stp);
>>>> @@ -4361,6 +4376,13 @@ nfsd4_process_open2(struct svc_rqst *rqstp,
>>>> struct svc_fh *current_fh, struct nf
>>>> 		status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp,
>>>> open);
>>>> 		if (status) {
>>>> 			up_read(&stp->st_rwsem);
>>>> +			/*
>>>> +			 * EAGAIN is returned when there's a
>>>> racing access,
>>>> +			 * this should never happen as we are the
>>>> only user
>>>> +			 * of this new state, and since it's not
>>>> yet hashed,
>>>> +			 * nobody can find it
>>>> +			 */
>>>> +			WARN_ON(status == nfserr_eagain);
>>> 
>>> Ok, some more testing shows that this CAN happen.
>>> So this patch is inferior to the mutex one after all.
>>> 
>> 
>> Yeah, that can happen for all sorts of reasons. As Andrew pointed out,
>> you can get this when there is a lease break in progress, and that may
>> be occurring for a completely different stateid (or because of samba,
>> etc...)
>> 
>> It may be possible to do something like this, but we'd need to audit
>> all of the handling of st_access_bmap (and the deny bmap) to ensure
>> that we get it right.
>> 
>> For now, I think just turning that rwsem into a mutex is the best
>> solution. That is a per-stateid mutex so any contention is going to be
>> due to the client sending racing OPEN calls for the same inode anyway.
>> Allowing those to run in parallel again could be useful in some cases,
>> but most use-cases won't be harmed by that serialization.
> 
> OK, so for now my plan is to take "nfsd: Always lock state exclusively"
> for 4.7.  Thanks to both of you for your work on this….


FYI, I just hit this again with the "Always lock state exclusively" patch too.
I hate when that happens. But it is much harder to hit now.

the trace is also in the nfs4_get_vfs_file() that's called directly from
nfsd4_process_open2().

Otherwise the symptoms are pretty same - first I get the warning in set_access
that the flag is already set and then the nfsd4_free_file_rcu() one and then
unmount of underlying fs fails.

What's strange is I am not sure what else can set the flag.
Basically set_access is called from nfs4_get_vfs_file() - under the mutex via
nfsd4_process_open2() directly or via nfs4_upgrade_open()...,
or from get_lock_access() - without the mutex, but my workload does not do any
file locking, so it should not really be hitting, right?


Ah! I think I see it.
This patch has the same problem as the spinlock moving one:
When we call nfs4_get_vfs_file() directly from nfsd4_process_open2(), there's no
check for anything, so supposed we take this diret cllign path, there's a
mutex_lock() just before the call, but what's to stop another thread from finding
this stateid meanwhile and being first with the mutex and then also settign the
access mode that our first thread no longer sets?
This makes it so that in fact we can never skip the access mode testing unless
testing and setting is atomically done under the same lock which it is not now.
The patch that extended the coverage of the fi_lock got that right, I did not hit
any leaks there, just the "unhandled EAGAIN" warn on, which is wrong in it's own right.
The surprising part is that the state that's not yet been through find_or_hash_clnt_odstate could still be found by somebody else? Is it really
supposed to work like that? 

So if we are to check the access mode at all times in nfs4_get_vfs_file(),
and return eagain, should we just check for that (all under the same
lock if we go with the mutex patch) and call into nfs4_upgrade_open in that
case again?
Or I guess it's even better if we resurrect the fi_lock coverage extension patch and
do it there, as that would mean at least the check and set are atomic wrt
locking?