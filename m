Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:26645 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756008Ab2AYQry convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jan 2012 11:47:54 -0500
Subject: Re: [PATCH v4 0/6] nfsd: overhaul the client name tracking code
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120125083820.637c8362@tlielax.poochiereds.net>
Date: Wed, 25 Jan 2012 11:47:41 -0500
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Message-Id: <F6C58345-828B-493E-9D0E-8BBC60E348CF@oracle.com>
References: <1327348867-699-1-git-send-email-jlayton@redhat.com> <20120124230855.GE12426@fieldses.org> <20120125064158.4551a012@tlielax.poochiereds.net> <20120125131116.GA17873@fieldses.org> <20120125083820.637c8362@tlielax.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 25, 2012, at 8:38 AM, Jeff Layton wrote:

> On Wed, 25 Jan 2012 08:11:17 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
>> On Wed, Jan 25, 2012 at 06:41:58AM -0500, Jeff Layton wrote:
>>> On Tue, 24 Jan 2012 18:08:55 -0500
>>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>> 
>>>> On Mon, Jan 23, 2012 at 03:01:01PM -0500, Jeff Layton wrote:
>>>>> This is the fourth iteration of this patchset. I had originally asked
>>>>> Bruce to take the last one for 3.3, but decided at the last minute to
>>>>> wait on it a bit. I knew there would be some changes needed in the
>>>>> upcall, so by waiting we can avoid needing to deal with those in code
>>>>> that has already shipped. I would like to see this patchset considered
>>>>> for 3.4 however.
>>>>> 
>>>>> The previous patchset can be viewed here. That set also contains a
>>>>> more comprehensive description of the rationale for this:
>>>>> 
>>>>>    http://www.spinics.net/lists/linux-nfs/msg26324.html
>>>>> 
>>>>> There have been a number of significant changes since the last set:
>>>>> 
>>>>> - the remove/expire upcall is now gone. In a clustered environment, the
>>>>> records would need to be refcounted in order to handle that properly. That
>>>>> becomes a sticky problem when you could have nodes rebooting. We don't
>>>>> really need to remove these records individually however. Cleaning them
>>>>> out only when the grace period ends should be sufficient.
>>>> 
>>>> I don't think so:
>>>> 
>>>> 	1. Client establishes state with server.
>>>> 	2. Network goes down.
>>>> 	3. A lease period passes without the client being able to renew.
>>>> 	   The server expires the client and grants conflicting locks to
>>>> 	   other clients.
>>>> 	3. Server reboots.
>>>> 	4. Network comes back up.
>>>> 
>>>> At this point, the client sees that the server has rebooted and is in
>>>> its grace period, and reclaims.  Ooops.
>>>> 
>>>> The server needs to be able to tell the client "nope, you're not allowed
>>>> to reclaim any more" at this point.
>>>> 
>>>> So we need some sort of remove/expire upcall.
>>>> 
>>> 
>>> Doh! I don't know what I was thinking -- you're correct and we do need
>>> that.
>>> 
>>> Ok, I'll see about putting it back and will resend. That does make it
>>> rather nasty to handle clients mounting from multiple nodes in the same
>>> cluster though. We'll need to come up with a data model that allows for
>>> that as well.
>> 
>> Honestly, in the v4-based migration case if one client can hold state on
>> mulitple nodes, and could (could it?) after reboot decide to reclaim
>> state on a different node from the one it previously held the same state
>> on--I'm not even clear what *should* happen, or if the protocol is
>> really adequate for that case.
>> 
>> --b.
> 
> That was one of Chuck's concerns, IIUC:
> 
> --------------[snip]----------------
> 
> What if a server has more than one address?  For example, an IPv4 and
> an IPv6 address?  Does it get two separate database files?  If so, how
> do you ensure that a client's nfs_client_id4 is recorded in both places
> atomically?  I'm not sure tying the server's identity to an IP address
> is wise.
> 
> --------------[snip]----------------
> 
> This is the problem...
> 
> We need to tie the record to some property that's invariant for the NFS
> server "instance". That can't be a physical nodeid or anything, since
> part of the goal here is to allow for cluster services to float freely
> between them.
> 
> I really would like to avoid having to establish some abstract "service
> ID" or something since we'd have to track that on stable storage on a
> per-nfs-service basis.

I don't understand this concern.  You are already building an on-disk database, so adding this item would not be more overhead than a few bytes.  And having a service ID is roughly the same as an NFSv4.1 server ID, if I understand this correctly.

> The server address seems like a natural fit here. With the design I'm
> proposing, a client will need to reestablish its state on another node
> if it migrates for any reason.

The server's IP address is certainly not invariant.  It could be assigned via DHCP, for instance.  But it definitely can be changed by an administrator at any time.

And a server can be multi-homed.  It almost certainly will be multi-homed where IPv6 is present.  Which IP address represents the server's identity?

We have the same problem on clients.  We shouldn't (although we currently do) use the client's IP address in its nfs_client_id4 string: the string is supposed to be invariant, but IP addresses can change, and which address do you pick if there is more than one?

For NFSv4.1, you already have a single server ID object that is not linked to any of the server's IP addresses.

I think therefore that an IP address is actually the very last thing you should use to identify a server instance.

> Chuck, what was your specific worry about tracking these on a per
> server address basis? Can you outline a scenario where that would break
> something?

I'm having a hard time following the discussion, I must be lacking some context.  But the problem is how NFSv4.0 clients detect server identity.  The only way they can do it is by performing a SETCLIENTID_CONFIRM with a particular clientid4 against every server a client knows about.  If the clientid4 is recognized by multiple server IPs, the client knows these IPs are the same server.

Thus if you are preserving clientid4's on stable storage, it seems to me that you need to preserve the relationship between a clientid4 and which servers recognize it.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




