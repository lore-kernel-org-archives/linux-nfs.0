Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37600 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750798AbdINFr6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Sep 2017 01:47:58 -0400
Date: Thu, 14 Sep 2017 01:47:45 -0400
From: Richard Guy Briggs <rgb@redhat.com>
To: "Serge E. Hallyn" <serge@hallyn.com>
Cc: Paul Moore <paul@paul-moore.com>,
        David Howells <dhowells@redhat.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        cgroups@vger.kernel.org, linux-api@vger.kernel.org,
        containers@lists.linux-foundation.org, linux-audit@redhat.com,
        mszeredi@redhat.com, jlayton@redhat.com, viro@zeniv.linux.org.uk,
        luto@kernel.org, trondmy@primarydata.com, ebiederm@xmission.com
Subject: Re: [PATCH 2/9] Implement containers as kernel objects
Message-ID: <20170914054745.GS3405@madcap2.tricolour.ca>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
 <149547016213.10599.1969443294414531853.stgit@warthog.procyon.org.uk>
 <20170814054711.GB29957@madcap2.tricolour.ca>
 <CAHC9VhRgPRa7KeMt8G700aeFvqVYc0gMx__82K31TYY6oQQqTw@mail.gmail.com>
 <20170818080300.GQ7187@madcap2.tricolour.ca>
 <20170906140341.GA8729@mail.hallyn.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170906140341.GA8729@mail.hallyn.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2017-09-06 09:03, Serge E. Hallyn wrote:
> Quoting Richard Guy Briggs (rgb@redhat.com):
> ...
> > > I believe we are going to need a container ID to container definition
> > > (namespace, etc.) mapping mechanism regardless of if the container ID
> > > is provided by userspace or a kernel generated serial number.  This
> > > mapping should be recorded in the audit log when the container ID is
> > > created/defined.
> > 
> > Agreed.
> > 
> > > > As was suggested in one of the previous threads, if there are any events not
> > > > associated with a task (incoming network packets) we log the namespace ID and
> > > > then only concern ourselves with its container serial number or container name
> > > > once it becomes associated with a task at which point that tracking will be
> > > > more important anyways.
> > > 
> > > Agreed.  After all, a single namespace can be shared between multiple
> > > containers.  For those security officers who need to track individual
> > > events like this they will have the container ID mapping information
> > > in the logs as well so they should be able to trace the unassociated
> > > event to a set of containers.
> > > 
> > > > I'm not convinced that a userspace or kernel generated UUID is that useful
> > > > since they are large, not human readable and may not be globally unique given
> > > > the "pets vs cattle" direction we are going with potentially identical
> > > > conditions in hosts or containers spawning containers, but I see no need to
> > > > restrict them.
> > > 
> > > From a kernel perspective I think an int should suffice; after all,
> > > you can't have more containers then you have processes.  If the
> > > container engine requires something more complex, it can use the int
> > > as input to its own mapping function.
> > 
> > PIDs roll over.  That already causes some ambiguity in reporting.  If a
> > system is constantly spawning and reaping containers, especially
> > single-process containers, I don't want to have to worry about that ID
> > rolling to keep track of it even though there should be audit records of
> > the spawn and death of each container.  There isn't significant cost
> > added here compared with some of the other overhead we're dealing with.
> 
> Strawman proposal:
> 
> 1. Each clone/unshare/setns involving a namespace type generates an audit
> message along the lines of:
> 
> PID 9512 (pid in init_pid_ns) in auditnsid 00000001 cloned CLONE_NEWNS|CLONE_NEWNET
> new auditnsid: 00000002
> associated namespaces: (list of all namespace filesystem inode numbers)

As you will have seen, this is pretty much what my most recent proposal suggests.

> 2. Userspace (i.e. the container logging deamon here) can watch the audit log
> for all messages relating to auditnsid 00000002.  Presumably there will be
> messages along the lines of "PID 9513 in auditnsid 00000002 cloned...".  The
> container logging daemon can track those messages and add the new auditnsids
> to the list it watches.

Yes.

> 3. If a container is migrated (checkpointed and restored here or elsewhere),
> userspace can just follow the appropriate logs for the new containers.

Yes.

> Userspace does not ever *request* a auditnsid.  They are ephemeral, just a
> tool to track the namespaces through the audit log.  They are however guaranteed
> to never be re-used until reboot.

Well, this is where things get controvertial...  I had wanted this, a
kernel-generated serial number unique to a running kernel to track every
container initiation, but this does have some CRIU challenges pointed
out by Eric Biederman.  Nested containers will not have a consistent
view on a new host and no way to make it consistent.  If we could
guarantee that containers would never be nested, this could be workable.
I think nesting is inevitable in the future given the variety and
creativity of the orchestration tools, so restricting this seems
short-sighted.

At the moment the approch is to let the orchestrator determine the ID of
a container.  Some have argued for as small as u32 and others for a full
UUID.  A u32 runs the risk of rolling, so a u64 seems like a reasonable
step to solve that issue.  Others would like to be able to store a full
UUID which seemed like a good idea on the outset, but on further
thinking, this is something the orchestrator can manage while minimising
the number of bits of required information per audit record to guarantee
we can identify the provenance of a particular audit event.  Let's see
if we can make it work with a u64.

> (Feels like someone must have proposed this before)

Thsee ideas have been thrown around a few times and I'm starting to
understand them better.

> -serge

- RGB

--
Richard Guy Briggs <rgb@redhat.com>
Sr. S/W Engineer, Kernel Security, Base Operating Systems
Remote, Ottawa, Red Hat Canada
IRC: rgb, SunRaycer
Voice: +1.647.777.2635, Internal: (81) 32635
