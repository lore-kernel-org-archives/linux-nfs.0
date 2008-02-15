From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/2] NLM failover unlock
Date: Fri, 15 Feb 2008 11:20:22 -0500
Message-ID: <20080215162022.GA20826@fieldses.org>
References: <4781B91D.8090509@redhat.com> <20080214183833.GA26936@newbie.thebellsplace.net> <47B490BC.2000309@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Wendy Cheng <wcheng@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:40061 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752713AbYBOQUZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Feb 2008 11:20:25 -0500
In-Reply-To: <47B490BC.2000309@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 14, 2008 at 02:04:28PM -0500, Wendy Cheng wrote:
> Bob Bell wrote:
>> On Mon, Jan 07, 2008 at 12:31:09AM -0500, Wendy Cheng wrote:
>>> This submission is part of the patch sets added to support NFS server 
>>> failover where the specified export is moved from one physical server 
>>> to another.
>>
>> Wendy,
>>
>> What's the current status of these patches?  I believe I have a  
>> situation that could benefit from being able to release all NLM locks  
>> on an exported filesystem.
>>
> I think Bruce has queued the unlock patch for 2.6.26 (Bruce ?) ..

Not yet, for several reasons.  First, there's two smaller problems
outstanding that I can recall:

	- We should be matching on the superblock, not the vfs mount.
	  Otherwise, for example, the unlock will have no effect if it's
	  done from a private namespace, which I think will be
	  unexpected.  Arguably this could result in revoking more locks
	  than necessary, but if the goal is to allow unmounting some
	  shared block device, then that's what we've got to do.
	- Let's get the address types right.  I think the concensus from
	  previous discussions was just to use in6_addr everywhere?

(Both those should be relatively small-let me know if you can resend
fixed versions or if you'd like me to fix them up--either's fine.)

As I've said before I'd also like to see how this will fit into a
solution for some longer-term problems:

	- How will we block locks on other nodes of a cluster filesystem
	  during grace periods/failover?
	- How will the comparable v4 references to the filesystem (from
	  opens and locks) be revoked?

I'm working on those (some patches are in

	git://linux-nfs.org/~bfields/linux.git failover

but it's still at an early stage.)  But I don't want the perfect to be
the enemy of the good, so, sure, if it looks like that's not going to be
figured out by 2.6.26 then I'll queue up this unlock patch before then.

We do need at least the small problems above fixed, though.

Also, are you planning to address the comments on the grace period
patches, or do you want me to take over revising them?

--b.
