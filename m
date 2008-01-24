From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Thu, 24 Jan 2008 15:19:10 -0500
Message-ID: <20080124201910.GF26164@fieldses.org>
References: <478D3820.9080402@redhat.com> <20080117151007.GB16581@fieldses.org> <478F78E8.40601@redhat.com> <20080117163105.GG16581@fieldses.org> <478F82DA.4060709@redhat.com> <20080117164002.GH16581@fieldses.org> <478F9946.9010601@redhat.com> <20080117202342.GA6416@fieldses.org> <20080124160030.GB26164@fieldses.org> <4798EAE1.2000707@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39821 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751702AbYAXUTP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Jan 2008 15:19:15 -0500
In-Reply-To: <4798EAE1.2000707@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 24, 2008 at 02:45:37PM -0500, Wendy Cheng wrote:
> J. Bruce Fields wrote:
>> In practice, it seems that both the unlock_ip and unlock_pathname
>> methods that revoke locks are going to be called together.  The two
>> separate calls therefore seem a little redundant.  The reason we *need*
>> both is that it's possible that a misconfigured client could grab locks
>> for a (server ip, export) combination that it isn't supposed to.
>>   
>
> That is not a correct assumption. The two commands (unlock_ip and  
> unlock_pathname) are not necessarily called together. It is ok for local  
> filesystem (ext3) but not for cluster filesystem where the very same  
> filesystem (or subtree) can be exported from multiple servers using  
> different subtrees.

Ouch.  Are people really doing that, and why?  What happens if the
subtrees share files (because of hard links) that are locked from both
nodes?

> Also as we discussed before, it is  
> "unlock_filesystem", *not* "unlock_pathname" (this implies sub-tree  
> exports) due to implementation difficulties (see the "Implementation  
> Notes" from http://people.redhat.com/wcheng/Patches/NFS/NLM/004.txt).

Unless I misread the latest patch, it's actually matching on the
vfsmount, right?

I guess that means we *could* handle the above situation by doing a

	mount --bind /path/to/export/point /path/to/export/point

on each export, at which point there will be a separate vfsmount for
each export point?

But I don't think that's what we really want.  The goal is to ensure
that the nfs server holds no locks on a disk filesystem so we can
unmount it completely from this machine and mount it elsewhere.  So we
should really be removing all locks for the superblock, not just for a
particular mount of that superblock.  Otherwise we'll have odd problems
if someone happens to do the unlock_filesystem downcall from a different
namespace or something.

>> So it makes sense to me to restrict locking from the beginning to
>> prevent that from happening.  Therefore I'd like to add a call at the
>> beginning like:
>>
>> 	echo "192.168.1.1 /exports/example" > /proc/fs/nfsd/start_grace
>>   
>
> My second patch set is about to be sent out (doing text description at  
> this moment .. sorry for the delay).

Good, thanks.

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
>
> I still don't have a warm feeling about adding this (at this moment) -  
> somehow feel we over-engineer the lock failover issues.

I agree that that's a risk.

> Remember lock  failover is just a small portion of the general NFS
> server failover (for  both HA and load balancing purpose) issues.
> Maybe we should have  something simple and usable for 2.6 kernel
> before adding this type of  complication ?

Yeah.  We should aim to include basic failover functionality in 2.6.26,
one way or another--I think that dealing with the other issues I'm
worried about won't actually be a great deal more complicated, but if
that doesn't pan out then fine.  I would like to at least make sure this
is all working for nfsv4 as well, though.  (Currently only locks held by
v2/v3 clients are dropped.)

--b.
