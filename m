Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60764 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750775AbdHRIDL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Aug 2017 04:03:11 -0400
Date: Fri, 18 Aug 2017 04:03:00 -0400
From: Richard Guy Briggs <rgb@redhat.com>
To: Paul Moore <paul@paul-moore.com>
Cc: David Howells <dhowells@redhat.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        cgroups@vger.kernel.org, linux-api@vger.kernel.org,
        containers@lists.linux-foundation.org, linux-audit@redhat.com,
        mszeredi@redhat.com, jlayton@redhat.com, viro@zeniv.linux.org.uk,
        luto@kernel.org, trondmy@primarydata.com, serge@hallyn.com,
        ebiederm@xmission.com
Subject: Re: [PATCH 2/9] Implement containers as kernel objects
Message-ID: <20170818080300.GQ7187@madcap2.tricolour.ca>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
 <149547016213.10599.1969443294414531853.stgit@warthog.procyon.org.uk>
 <20170814054711.GB29957@madcap2.tricolour.ca>
 <CAHC9VhRgPRa7KeMt8G700aeFvqVYc0gMx__82K31TYY6oQQqTw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHC9VhRgPRa7KeMt8G700aeFvqVYc0gMx__82K31TYY6oQQqTw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2017-08-16 18:21, Paul Moore wrote:
> On Mon, Aug 14, 2017 at 1:47 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
> > Hi David,
> >
> > I wanted to respond to this thread to attempt some constructive feedback,
> > better late than never.  I had a look at your fsopen/fsmount() patchset(s) to
> > support this patchset which was interesting, but doesn't directly affect my
> > work.  The primary patch of interest to the audit kernel folks (Paul Moore and
> > me) is this patch while the rest of the patchset is interesting, but not likely
> > to directly affect us.  This patch has most of what we need to solve our
> > problem.
> >
> > Paul and I agree that audit is going to have a difficult time identifying
> > containers or even namespaces without some change to the kernel.  The audit
> > subsystem in the kernel needs at least a basic clue about which container
> > caused an event to be able to report this at the appropriate level and ignore
> > it at other levels to avoid a DoS.
> 
> While there is some increased risk of "death by audit", this is really
> only an issue once we start supporting multiple audit daemons; simply
> associating auditable events with the container that triggered them
> shouldn't add any additional overhead (I hope).  For a number of use
> cases, a single auditd running outside the containers, but recording
> all their events with some type of container attribution will be
> sufficient.  This is step #1.
> 
> However, we will obviously want to go a bit further and support
> multiple audit daemons on the system to allow containers to
> record/process their own events (side note: the non-container auditd
> instance will still see all the events).  There are a number of ways
> we could tackle this, both via in-kernel and in-userspace record
> routing, each with their own pros/cons.  However, how this works is
> going to be dependent on how we identify containers and track their
> audit events: the bits from step #1.  For this reason I'm not really
> interested in worrying about the multiple auditd problem just yet;
> it's obviously important, and something to keep in mind while working
> up a solution, but it isn't something we should focus on right now.
> 
> > We also agree that there will need to be some sort of trigger from userspace to
> > indicate the creation of a container and its allocated resources and we're not
> > really picky how that is done, such as a clone flag, a syscall or a sysfs write
> > (or even a read, I suppose), but there will need to be some permission
> > restrictions, obviously.  (I'd like to see capabilities used for this by adding
> > a specific container bit to the capabilities bitmask.)
> 
> To be clear, from an audit perspective I think the only thing we would
> really care about controlling access to is the creation and assignment
> of a new audit container ID/token, not necessarily the container
> itself.  It's a small point, but an important one I think.
> 
> > I doubt we will be able to accomodate all definitions or concepts of a
> > container in a timely fashion.  We'll need to start somewhere with a minimum
> > definition so that we can get traction and actually move forward before another
> > compelling shared kernel microservice method leaves our entire community
> > behind.  I'd like to declare that a container is a full set of cloned
> > namespaces, but this is inefficient, overly constricting and unnecessary for
> > our needs.  If we could agree on a minimum definition of a container (which may
> > have only one specific cloned namespace) then we have something on which to
> > build.  I could even see a container being defined by a trigger sent from
> > userspace about a process (task) from which all its children are considered to
> > be within that container, subject to further nesting.
> 
> I really would prefer if we could avoid defining the term "container".
> Even if we manage to get it right at this particular moment, we will
> surely be made fools a year or two from now when things change.  At
> the very least lets avoid a rigid definition of container, I'll
> concede that we will probably need to have some definition simply so
> we can implement something, I just don't want the design or
> implementation to depend on a particular definition.
> 
> This comment is jumping ahead a bit, but from an audit perspective I
> think we handle this by emitting an audit record whenever a container
> ID is created which describes it as the kernel sees it; as of now that
> probably means a list of namespace IDs.  Richard mentions this in his
> email, I just wanted to make it clear that I think we should see this
> as a flexible mechanism.  At the very least we will likely see a few
> more namespaces before the world moves on from containers.
> 
> > In the simplest usable model for audit, if a container (definition implies and)
> > starts a PID namespace, then the container ID could simply be the container's
> > "init" process PID in the initial PID namespace.  This assumes that as soon as
> > that process vanishes, that entire container and all its children are killed
> > off (which you've done).  There may be some container orchestration systems
> > that don't use a unique PID namespace per container and that imposing this will
> > cause them challenges.
> 
> I don't follow how this would cause challenges if the containers do
> not use a unique PID namespace; you are suggesting using the PID from
> in the context of the initial PID namespace, yes?

The PID of the "init" process of a container (PID=1 inside container,
but PID=containerID from the initial PID namespace perspective).

> Regardless, I do worry that using a PID could potentially be a bit
> racy once we start jumping between kernel and userspace (audit
> configuration, logs, etc.).

How do you think this could be racy?  An event happenning before or as
the container has been defined?

> > If containers have at minimum a unique mount namespace then the root path
> > dentry inode device and inode number could be used, but there are likely better
> > identifiers.  Again, there may be container orchestrators that don't use a
> > unique mount namespace per container and that imposing this will cause
> > challenges.
> >
> > I expect there are similar examples for each of the other namespaces.
> 
> The PID case is a bit unique as each process is going to have a unique
> PID regardless of namespaces, but even that has some drawbacks as
> discussed above.  As for the other namespaces, I agree that we can't
> rely on them (see my earlier comments).

(In general can you specify which earlier comments so we can be sure to
what you are referring?)

> > If we could pick one namespace type for consensus for which each container has
> > a unique instance of that namespace, we could use the dev/ino tuple from that
> > namespace as had originally been suggested by Aristeu Rozanski more than 4
> > years ago as part of the set of namespace IDs.  I had also attempted to
> > solve this problem by using the namespace' proc inode, then switched over to
> > generate a unique kernel serial number for each namespace and then went back to
> > namespace proc dev/ino once Al Viro implemented nsfs:
> >         v1      https://lkml.org/lkml/2014/4/22/662
> >         v2      https://lkml.org/lkml/2014/5/9/637
> >         v3      https://lkml.org/lkml/2014/5/20/287
> >         v4      https://lkml.org/lkml/2014/8/20/844
> >         v5      https://lkml.org/lkml/2014/10/6/25
> >         v6      https://lkml.org/lkml/2015/4/17/48
> >         v7      https://lkml.org/lkml/2015/5/12/773
> >
> > These patches don't use a container ID, but track all namespaces in use for an
> > event.  This has the benefit of punting this tracking to userspace for some
> > other tool to analyse and determine to which container an event belongs.
> > This will use a lot of bandwidth in audit log files when a single
> > container ID that doesn't require nesting information to be complete
> > would be a much more efficient use of audit log bandwidth.
> 
> Relying on a particular namespace to identify a containers is a
> non-starter from my perspective for all the reasons previously
> discussed.

I'd rather not either and suspect there isn't much danger of it, but if
it is determined that there is one namespace in particular that is a
minimum requirement, I'd prefer to use that nsID instead of creating an
additional ID.

> > If we rely only on the setting of arbitrary container names from userspace,
> > then we must provide a map or tree back to the initial audit domain for that
> > running kernel to be able to differentiate between potentially identical
> > container names assigned in a nested container system.  If we assign a
> > container serial number sequentially (atomic64_inc) from the kernel on request
> > from userspace like the sessionID and log the creation with all nsIDs and the
> > parent container serial number and/or container name, the nesting is clear due
> > to lack of ambiguity in potential duplicate names in nesting.  If a container
> > serial number is used, the tree of inheritance of nested containers can be
> > rebuilt from the audit records showing what containers were spawned from what
> > parent.
> 
> I believe we are going to need a container ID to container definition
> (namespace, etc.) mapping mechanism regardless of if the container ID
> is provided by userspace or a kernel generated serial number.  This
> mapping should be recorded in the audit log when the container ID is
> created/defined.

Agreed.

> > As was suggested in one of the previous threads, if there are any events not
> > associated with a task (incoming network packets) we log the namespace ID and
> > then only concern ourselves with its container serial number or container name
> > once it becomes associated with a task at which point that tracking will be
> > more important anyways.
> 
> Agreed.  After all, a single namespace can be shared between multiple
> containers.  For those security officers who need to track individual
> events like this they will have the container ID mapping information
> in the logs as well so they should be able to trace the unassociated
> event to a set of containers.
> 
> > I'm not convinced that a userspace or kernel generated UUID is that useful
> > since they are large, not human readable and may not be globally unique given
> > the "pets vs cattle" direction we are going with potentially identical
> > conditions in hosts or containers spawning containers, but I see no need to
> > restrict them.
> 
> From a kernel perspective I think an int should suffice; after all,
> you can't have more containers then you have processes.  If the
> container engine requires something more complex, it can use the int
> as input to its own mapping function.

PIDs roll over.  That already causes some ambiguity in reporting.  If a
system is constantly spawning and reaping containers, especially
single-process containers, I don't want to have to worry about that ID
rolling to keep track of it even though there should be audit records of
the spawn and death of each container.  There isn't significant cost
added here compared with some of the other overhead we're dealing with.

> > How do we deal with setns()?  Once it is determined that action is permitted,
> > given the new combinaiton of namespaces and potential membership in a different
> > container, record the transition from one container to another including all
> > namespaces if the latter are a different subset than the target container
> > initial set.
> 
> That is a fun one, isn't it?  I think this is where the container
> ID-to-definition mapping comes into play.  If setns() changes the
> process such that the existing container ID is no longer valid then we
> need to do a new lookup in the table to see if another container ID is
> valid; if no established container ID mappings are valid, the
> container ID becomes "undefined".

Hopefully we can design this stuff so that container IDs are still valid
while that transition occurs.

> paul moore

- RGB

--
Richard Guy Briggs <rgb@redhat.com>
Sr. S/W Engineer, Kernel Security, Base Operating Systems
Remote, Ottawa, Red Hat Canada
IRC: rgb, SunRaycer
Voice: +1.647.777.2635, Internal: (81) 32635
