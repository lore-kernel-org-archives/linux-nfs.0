Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:31706 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754635Ab1KVUOT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Nov 2011 15:14:19 -0500
Subject: Re: [RFC] NFS: Cache state owners after files are closed
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20111122193638.GB21451@fieldses.org>
Date: Tue, 22 Nov 2011 15:14:03 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <5CE4FEAE-3432-4F87-ABC8-DBFE4FAF91C7@oracle.com>
References: <20111122174225.1866.25410.stgit@degas.1015granger.net> <20111122193638.GB21451@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 22, 2011, at 2:36 PM, J. Bruce Fields wrote:

> On Tue, Nov 22, 2011 at 12:52:53PM -0500, Chuck Lever wrote:
>> Servers have a finite amount of memory to store NFSv4 open and lock
>> owners.  Moreover, servers may have a difficult time determining when
>> they can reap their state owner table, thanks to gray areas in the
>> NFSv4 protocol specification.
> 
> What's the gray area?
> 
> Reminding myself: OK, I guess it's the NFSv4.0 close-replay problem.
> You have to keep around enough information about a closed stateid to
> handle a replay.  If a client reuses the stateowner than you can purge
> that as soon as you bump the sequence number, otherwise you have to keep
> it around a while (how long is unclear).

                    ^^^^^^^^^^^^^^^^^^^^
That's the problem.

When the server can't store any more state owners, it has to use heuristics to reap unused state owners, or it can have the client perform state recovery to determine which state owners the client wants to keep around.  Or, it can return NFS4ERR_RESOURCE and hope for the best.

> (Is that what you're referring to?)
> 
>> Thus clients should be careful to reuse
>> state owners when possible.
>> 
>> Currently Linux is not too careful.  When a user has closed all her
>> files on one mount point, the state owner's reference count goes to
>> zero, and it is released.  The next OPEN allocates a new one.  A
>> workload that serially opens and closes files can run through a large
>> number of open owners this way.
>> 
>> When a state owner's reference count goes to zero, slap it onto a free
>> list for that nfs_server, with an expiry time.  Garbage collect before
>> looking for a state owner.  This makes state owners for active users
>> available for re-use.
> 
> Makes sense to me.

Trond's idea.  A simpler approach might keep them around until umount, but I expect we'd still need some way to trim down the client's collection of these things on big hosts with lots of users.

>> @@ -1739,6 +1745,7 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
>> 		goto error;
>> 
>> 	dprintk("<-- nfs4_create_server() = %p\n", server);
>> +	server->destroy = nfs4_destroy_server;
>> 	return server;
>> 
>> error:
>> @@ -1792,6 +1799,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
>> 		goto error;
>> 
>> 	dprintk("<-- nfs_create_referral_server() = %p\n", server);
>> +	server->destroy = nfs4_destroy_server;
> 
> Couldn't you avoid adding that line in two different places, if you put
> it in nfs4_server_common_setup()?

Probably.  I never seem to catch all the places where these things are created or destroyed.  I'll look into this if/when I redrive the patch.

Thanks for the review!

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




