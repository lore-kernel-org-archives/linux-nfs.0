Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from h2.hallyn.com ([78.46.35.8]:47454 "EHLO h2.hallyn.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932171AbdIFODa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Sep 2017 10:03:30 -0400
Date: Wed, 6 Sep 2017 09:03:42 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Richard Guy Briggs <rgb@redhat.com>
Cc: Paul Moore <paul@paul-moore.com>,
        David Howells <dhowells@redhat.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        cgroups@vger.kernel.org, linux-api@vger.kernel.org,
        containers@lists.linux-foundation.org, linux-audit@redhat.com,
        mszeredi@redhat.com, jlayton@redhat.com, viro@zeniv.linux.org.uk,
        luto@kernel.org, trondmy@primarydata.com, serge@hallyn.com,
        ebiederm@xmission.com
Subject: Re: [PATCH 2/9] Implement containers as kernel objects
Message-ID: <20170906140341.GA8729@mail.hallyn.com>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
 <149547016213.10599.1969443294414531853.stgit@warthog.procyon.org.uk>
 <20170814054711.GB29957@madcap2.tricolour.ca>
 <CAHC9VhRgPRa7KeMt8G700aeFvqVYc0gMx__82K31TYY6oQQqTw@mail.gmail.com>
 <20170818080300.GQ7187@madcap2.tricolour.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170818080300.GQ7187@madcap2.tricolour.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Quoting Richard Guy Briggs (rgb@redhat.com):
...
> > I believe we are going to need a container ID to container definition
> > (namespace, etc.) mapping mechanism regardless of if the container ID
> > is provided by userspace or a kernel generated serial number.  This
> > mapping should be recorded in the audit log when the container ID is
> > created/defined.
> 
> Agreed.
> 
> > > As was suggested in one of the previous threads, if there are any events not
> > > associated with a task (incoming network packets) we log the namespace ID and
> > > then only concern ourselves with its container serial number or container name
> > > once it becomes associated with a task at which point that tracking will be
> > > more important anyways.
> > 
> > Agreed.  After all, a single namespace can be shared between multiple
> > containers.  For those security officers who need to track individual
> > events like this they will have the container ID mapping information
> > in the logs as well so they should be able to trace the unassociated
> > event to a set of containers.
> > 
> > > I'm not convinced that a userspace or kernel generated UUID is that useful
> > > since they are large, not human readable and may not be globally unique given
> > > the "pets vs cattle" direction we are going with potentially identical
> > > conditions in hosts or containers spawning containers, but I see no need to
> > > restrict them.
> > 
> > From a kernel perspective I think an int should suffice; after all,
> > you can't have more containers then you have processes.  If the
> > container engine requires something more complex, it can use the int
> > as input to its own mapping function.
> 
> PIDs roll over.  That already causes some ambiguity in reporting.  If a
> system is constantly spawning and reaping containers, especially
> single-process containers, I don't want to have to worry about that ID
> rolling to keep track of it even though there should be audit records of
> the spawn and death of each container.  There isn't significant cost
> added here compared with some of the other overhead we're dealing with.

Strawman proposal:

1. Each clone/unshare/setns involving a namespace type generates an audit
message along the lines of:

PID 9512 (pid in init_pid_ns) in auditnsid 00000001 cloned CLONE_NEWNS|CLONE_NEWNET
new auditnsid: 00000002
associated namespaces: (list of all namespace filesystem inode numbers)

2. Userspace (i.e. the container logging deamon here) can watch the audit log
for all messages relating to auditnsid 00000002.  Presumably there will be
messages along the lines of "PID 9513 in auditnsid 00000002 cloned...".  The
container logging daemon can track those messages and add the new auditnsids
to the list it watches.

3. If a container is migrated (checkpointed and restored here or elsewhere),
userspace can just follow the appropriate logs for the new containers.

Userspace does not ever *request* a auditnsid.  They are ephemeral, just a
tool to track the namespaces through the audit log.  They are however guaranteed
to never be re-used until reboot.

(Feels like someone must have proposed this before)

-serge
