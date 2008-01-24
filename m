From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Thu, 24 Jan 2008 11:39:20 -0500
Message-ID: <20080124163920.GC26164@fieldses.org>
References: <478D3820.9080402@redhat.com> <20080117151007.GB16581@fieldses.org> <478F78E8.40601@redhat.com> <20080117163105.GG16581@fieldses.org> <478F82DA.4060709@redhat.com> <20080117164002.GH16581@fieldses.org> <478F9946.9010601@redhat.com> <20080117202342.GA6416@fieldses.org> <20080124160030.GB26164@fieldses.org> <4798BAAE.6090107@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wendy Cheng <wcheng@redhat.com>, Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58006 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751135AbYAXQjY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Jan 2008 11:39:24 -0500
In-Reply-To: <4798BAAE.6090107@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 24, 2008 at 11:19:58AM -0500, Peter Staubach wrote:
> J. Bruce Fields wrote:
>> On Thu, Jan 17, 2008 at 03:23:42PM -0500, J. Bruce Fields wrote:
>>   
>>> To summarize a phone conversation from today:
>>>
>>> On Thu, Jan 17, 2008 at 01:07:02PM -0500, Wendy Cheng wrote:
>>>     
>>>> J. Bruce Fields wrote:
>>>>       
>>>>> Would there be any advantage to enforcing that requirement in the
>>>>> server?  (For example, teaching nlm to reject any locking request for a
>>>>> certain filesystem that wasn't sent to a certain server IP.)
>>>>>
>>>>> --b.
>>>>>           
>>>> It is doable... could be added into the "resume" patch that is 
>>>> currently  being tested (since the logic is so similar to the 
>>>> per-ip base grace  period) that should be out for review no later 
>>>> than next Monday.
>>>>
>>>> However, as any new code added into the system, there are 
>>>> trade-off(s).  I'm not sure we want to keep enhancing this too much 
>>>> though.
>>>>       
>>> Sure.  And I don't want to make this terribly complicated.  The patch
>>> looks good, and solves a clear problem.  That said, there are a few
>>> related problems we'd like to solve:
>>>
>>> 	- We want to be able to move an export to a node with an already
>>> 	  active nfs server.  Currently that requires restarting all of
>>> 	  nfsd on the target node.  This is what I understand your next
>>> 	  patch fixes.
>>> 	- In the case of a filesystem that may be mounted from multiple
>>> 	  nodes at once, we need to make sure we're not leaving a window
>>> 	  allowing other applications to claim locks that nfs clients
>>> 	  haven't recovered yet.
>>> 	- Ideally we'd like this to be possible without making the
>>> 	  filesystem block all lock requests during a 90-second grace
>>> 	  period; instead it should only have to block those requests
>>> 	  that conflict with to-be-recovered locks.
>>> 	- All this should work for nfsv4, where we want to eventually
>>> 	  also allow migration of individual clients, and
>>> 	  client-initiated failover.
>>>
>>> I absolutely don't want to delay solving this particular problem until
>>> all the above is figured out, but I would like to be reasonably
>>> confident that the new user-interface can be extended naturally to
>>> handle the above cases; or at least that it won't unnecessarily
>>> complicate their implementation.
>>>
>>> I'll try to sketch an implementation of most of the above in the next
>>> week.
>>>     
>>
>> Bah.  Apologies, this is taking me longer than it should to figure
>> out--I've only barely started writing patches.
>>
>> The basic idea, though:
>>
>> In practice, it seems that both the unlock_ip and unlock_pathname
>> methods that revoke locks are going to be called together.  The two
>> separate calls therefore seem a little redundant.  The reason we *need*
>> both is that it's possible that a misconfigured client could grab locks
>> for a (server ip, export) combination that it isn't supposed to.
>>
>> So it makes sense to me to restrict locking from the beginning to
>> prevent that from happening.  Therefore I'd like to add a call at the
>> beginning like:
>>
>> 	echo "192.168.1.1 /exports/example" > /proc/fs/nfsd/start_grace
>>
>> before any exports are set up, which both starts a grace period, and
>> tells nfs to allow locks on the filesystem /exports/example only if
>> they're addressed to the server ip 192.168.1.1.  Then on shutdown,
>>
>> 	echo "192.168.1.1" >/proc/fs/nfsd/unlock_ip
>>
>> should be sufficient to guarantee that nfsd/lockd no longer holds locks
>> on /exports/example.
>>
>> (I think Wendy's pretty close to that api already after adding the
>> second method to start grace?)
>>
>> The other advantage to having the server-ip from the start is that at
>> the time we make lock requests to the cluster filesystem, we can tell it
>> that the locks associated with 192.168.1.1 are special: they may migrate
>> as a group to another node, and on node failure they should (if
>> possible) be held to give a chance for another node to take them over.
>>
>> Internally I'd like to have an object like
>>
>> 	struct lock_manager {
>> 		char *lm_name;
>> 		...
>> 	}
>>
>> for each server ip address.  A pointer to this structure would be passed
>> with each lock request, allowing the filesystem to associate locks to
>> lock_manager's.  The name would be a string derived from the server ip
>> address that the cluster can compare to match reclaim requests with the
>> locks that they're reclaiming from another node.
>>
>> (And in the NFSv4 case we would eventually also allow lock_managers with
>> single nfsv4 client (as opposed to server-ip) granularity.)
>>
>> Does that seem sane?
>>
>> But it's taking me longer than I'd like to get patches that implement
>> this.  Hopefully by next week I can get working code together for people
>> to look at....
>
> This seems somewhat less than scalable and not particularly
> generally useful except in this specific sort of situation
> to me.  The ratios between servers and clients tend to be
> one to many, where many can be not uncommonly 4 digits.
> What happens if the cluster is 1000+ nodes?  This strikes me
> as tough on a systems administrator.

I think that may turn out to be a valid objection to the notion of allowing
migration of individual v4 clients.  Does it really apply to the case of
migration by server ip addresses?

Maybe I'm not understanding the exact scalability problem you're
thinking of.

> It seems to me that it would be nice to be able to solve this
> problem someplace else like a cluster lock manager and not
> clutter up the NFS lock manager.

All we're doing in lock/nfsd is associating individual lock requests to "lock
managers"--sets of locks that may migrate as a group and making it possible to
individually shut down and start up lock managers.

In the case of a cluster filesystem, what I hope we end up with is an
api with calls to the filesystem like:

	lock_manager_start(lock_manager, super_block);
	lock_manager_end_grace(lock_manager, super_block);
	lock_manager_shutdown(lock_manager, super_block);

that inform the filesystem of the status of each lock manager.  If we pass lock
requests (including reclaims) to the filesystem as well, then it can if it
wants get complete control over the lock recovery process--so for example if it
knows which locks a dead node held, it may decide to allow normal locking that
doesn't conflict with those locks during the grace period.  Or it may choose to
do something simpler.

So I *think* this allows us to do what you want--it adds the minimal
infrastructure to lockd required to allow the cluster's lock manager to do the
real work.

(Though we'd also want a simple default implementation in the vfs which handles
simpler cases--like two servers that mount a single ext3 filesystem one at a
time from a shared block device.)

--b.

>
> Perhaps the cluster folks could explain why this problem
> can't be solved there?  Is this another case of attempting
> to create a cluster concept without actually doing all of
> the work to make the cluster appear to be a single system?
>
> Or am I misunderstanding the situation here?
