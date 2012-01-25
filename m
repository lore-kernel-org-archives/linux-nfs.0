Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32765 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751025Ab2AYUYC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jan 2012 15:24:02 -0500
Date: Wed, 25 Jan 2012 15:23:56 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 0/6] nfsd: overhaul the client name tracking code
Message-ID: <20120125152356.10bdd772@tlielax.poochiereds.net>
In-Reply-To: <20120125185529.GJ17873@fieldses.org>
References: <1327348867-699-1-git-send-email-jlayton@redhat.com>
	<20120124230855.GE12426@fieldses.org>
	<20120125064158.4551a012@tlielax.poochiereds.net>
	<20120125131116.GA17873@fieldses.org>
	<20120125083820.637c8362@tlielax.poochiereds.net>
	<F6C58345-828B-493E-9D0E-8BBC60E348CF@oracle.com>
	<20120125171401.GI17873@fieldses.org>
	<D13C2C6D-7731-4EE6-BC3D-2A9D1D1F0581@oracle.com>
	<20120125185529.GJ17873@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 25 Jan 2012 13:55:29 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Jan 25, 2012 at 12:41:27PM -0500, Chuck Lever wrote:
> > If SETCLIENTID returns a unique clientid4 that a client hasn't seen from other servers, the client knows that's a unique server instance which must be recovered separately after a reboot.
> 
> Hm, but does it have to do the recovery with that server?
> 
> And if so, then how does that fit with failover?
> 
> I mean, suppose the whole cluster is rebooted.  From the client's point
> of view, its server becomes unresponsive.  So it should probably start
> pinging the replicas to see if another one's up.  The first server it
> gets a response from won't necessarily be the one it was using before.
> What happens next?
> 
> --b.

Perhaps this will articulate the problem better:

Suppose we have a cluster of two machines (node1 and node2) and they
both serve out two exports (/exp1 and /exp2). A client mounts /exp1
from node1 and /exp2 from node2. Furthermore, let's assume that the
client sends the same name string to both hosts in the SETCLIENTID call.

Now, there's a network partition such that the client cannot talk to
node2 anymore, but can talk to node1. node2 expires the client and
tries to remove its record from stable storage...but we can't allow the
record to be purged since we need to keep the record around for node1.
So, we need to ensure that both nodes have their own record.

Fine, so let's assume that we tie that record to a "nodeid" or
something specific to the physical host. Now, let's suppose there's a
cluster-wide reboot and the network partition is repaired. The client
decides on its own to migrate all of its mounts to node1. But, we
can't allow it to reclaim the locks /exp2. So maybe we need to track
the nfs_client_id4 on a per-node+per_fs basis...

Don't worry, it gets worse...suppose we end up with the mounting
subdirectories of the same mount from different hosts (say,
node1:/exp2/dir1 node2:/exp2/dir2 -- it's pathological, but there's no
reason you couldn't do that). Now, it's not even sufficient to track
this info on a per-node + per-fs basis...

So, while it's all well and good to talk about keeping this flexible, I
think the only way to bring in sanity here is to put some artificial
constraints in place. I suggest that we only allow the reclaim of locks
on the original address against which they were established. It's less
than ideal, and we can try to loosen that later somehow, but doing
anything else on the first pass is going to be really ugly.

Thoughts?
-- 
Jeff Layton <jlayton@redhat.com>
