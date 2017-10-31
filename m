Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:49131 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752335AbdJaREU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Oct 2017 13:04:20 -0400
Received: by mail-io0-f195.google.com with SMTP id j17so258156iod.5
        for <linux-nfs@vger.kernel.org>; Tue, 31 Oct 2017 10:04:20 -0700 (PDT)
From: Joshua Watt <jpewhacker@gmail.com>
Message-ID: <1509469458.6057.65.camel@gmail.com>
Subject: Re: NFS Force Unmounting
To: Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neilb@suse.com>, Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Tue, 31 Oct 2017 12:04:18 -0500
In-Reply-To: <D98F43F0-6757-481D-B8C9-588A8EA8FF56@oracle.com>
References: <1508951506.2542.51.camel@gmail.com>
         <20171030202045.GA6168@fieldses.org>
         <87h8ugwdev.fsf@notabene.neil.brown.name>
         <1509460909.4553.37.camel@kernel.org>
         <D98F43F0-6757-481D-B8C9-588A8EA8FF56@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-10-31 at 10:55 -0400, Chuck Lever wrote:
> > On Oct 31, 2017, at 10:41 AM, Jeff Layton <jlayton@kernel.org>
> > wrote:
> > 
> > On Tue, 2017-10-31 at 08:09 +1100, NeilBrown wrote:
> > > On Mon, Oct 30 2017, J. Bruce Fields wrote:
> > > 
> > > > On Wed, Oct 25, 2017 at 12:11:46PM -0500, Joshua Watt wrote:
> > > > > I'm working on a networking embedded system where NFS servers
> > > > > can come
> > > > > and go from the network, and I've discovered that the Kernel
> > > > > NFS server
> > > > 
> > > > For "Kernel NFS server", I think you mean "Kernel NFS client".
> > > > 
> > > > > make it difficult to cleanup applications in a timely manner
> > > > > when the
> > > > > server disappears (and yes, I am mounting with "soft" and
> > > > > relatively
> > > > > short timeouts). I currently have a user space mechanism that
> > > > > can
> > > > > quickly detect when the server disappears, and does a
> > > > > umount() with the
> > > > > MNT_FORCE and MNT_DETACH flags. Using MNT_DETACH prevents new
> > > > > accesses
> > > > > to files on the defunct remote server, and I have traced
> > > > > through the
> > > > > code to see that MNT_FORCE does indeed cancel any current RPC
> > > > > tasks
> > > > > with -EIO. However, this isn't sufficient for my use case
> > > > > because if a
> > > > > user space application isn't currently waiting on an RCP task
> > > > > that gets
> > > > > canceled, it will have to timeout again before it detects the
> > > > > disconnect. For example, if a simple client is copying a file
> > > > > from the
> > > > > NFS server, and happens to not be waiting on the RPC task in
> > > > > the read()
> > > > > call when umount() occurs, it will be none the wiser and loop
> > > > > around to
> > > > > call read() again, which must then try the whole NFS timeout
> > > > > + recovery
> > > > > before the failure is detected. If a client is more complex
> > > > > and has a
> > > > > lot of open file descriptor, it will typical have to wait for
> > > > > each one
> > > > > to timeout, leading to very long delays.
> > > > > 
> > > > > The (naive?) solution seems to be to add some flag in either
> > > > > the NFS
> > > > > client or the RPC client that gets set in nfs_umount_begin().
> > > > > This
> > > > > would cause all subsequent operations to fail with an error
> > > > > code
> > > > > instead of having to be queued as an RPC task and the and
> > > > > then timing
> > > > > out. In our example client, the application would then get
> > > > > the -EIO
> > > > > immediately on the next (and all subsequent) read() calls.
> > > > > 
> > > > > There does seem to be some precedence for doing this
> > > > > (especially with
> > > > > network file systems), as both cifs (CifsExiting) and ceph
> > > > > (CEPH_MOUNT_SHUTDOWN) appear to implement this behavior (at
> > > > > least from
> > > > > looking at the code. I haven't verified runtime behavior).
> > > > > 
> > > > > Are there any pitfalls I'm oversimplifying?
> > > > 
> > > > I don't know.
> > > > 
> > > > In the hard case I don't think you'd want to do something like
> > > > this--applications expect mounts to be stay pinned while
> > > > they're using
> > > > them, not to get -EIO.  In the soft case maybe an exception
> > > > like this
> > > > makes sense.
> > > 
> > > Applications also expect to get responses to read() requests, and
> > > expect
> > > fsync() to complete, but if the servers has melted down, that
> > > isn't
> > > going to happen.  Sometimes unexpected errors are better than
> > > unexpected
> > > infinite delays.
> > > 
> > > I think we need a reliable way to unmount an NFS filesystem
> > > mounted from
> > > a non-responsive server.  Maybe that just means fixing all the
> > > places
> > > where use we use TASK_UNINTERRUTIBLE when waiting for the
> > > server.  That
> > > would allow processes accessing the filesystem to be killed.  I
> > > don't
> > > know if that would meet Joshua's needs.

No, it doesn't. I unfortunately cannot just kill off my processes that
are accessing NFS when it dies :)

> > > 
> > > Last time this came up, Trond didn't want to make MNT_FORCE too
> > > strong as
> > > it only makes sense to be forceful on the final unmount, and we
> > > cannot
> > > know if this is the "final" unmount (no other bind-mounts around)
> > > until
> > > much later than ->umount_prepare.  Maybe umount is the wrong
> > > interface.
> > > Maybe we should expose "struct nfs_client" (or maybe "struct
> > > nfs_server") objects via sysfs so they can be marked "dead" (or
> > > similar)
> > > meaning that all IO should fail.
> > > 
> > 
> > I like this idea.
> > 
> > Note that we already have some per-rpc_xprt / per-rpc_clnt info in
> > debugfs sunrpc dir. We could make some writable files in there, to
> > allow
> > you to kill off individual RPCs or maybe mark a whole clnt and/or
> > xprt
> > dead in some fashion.
> 
> Listing individual RPCs seems like overkill. It would be
> straightforward
> to identify these transports by the IP addresses of the remotes, and
> just
> mark the specific transports for a dead server. Maybe the --force
> option
> of umount could do this.

If we simply want --force to do it, the patch is pretty simple (I will
push it up as an RFC), and there is no need for any debugfs support,
although that leads back what --force should be doing. IMHO, --force is
a little strange in its current implementation because while it aborts
all the current pending RPC calls, you could *just* miss an RPC call
that comes in later, which could then block for long periods of time
(and prevent unmounting). Perhaps some light on the actual intended use
of --force would be useful? It seems to me like its more of an
indication that the user wants to abort any pending operations than an
indication that they *really* want to unmount the file system (but
again, I've noted this seems to vary between the different filesystems
than handle --force).

If we are going to debugfs support, it seems like the simplest thing is
for --force to continue to do whatever it does today unchanged, and the
new debugfs API is the sole mechanism for killing off a server.

Were you trying to say that there should be some sequence of --force
and debugfs operations to kill off a dead server? If so, I'm not quite
sure I follow (sorry).

> 
> The RPC client can then walk through the dead transport's list of RPC
> tasks and terminate all of them.
> 
> That makes it easy to find these things. But it doesn't take care of
> killing processes that are not interruptible, though.

IIUC, if a process is waiting on an RPC, and that RPC gets rpc_exit(-
EIO) called on it, the call will return with -EIO regardless of the
interruptable status of the process? Am I misreading the code? Maybe
better put is the question: Is it acceptable for a non-interruptable
task to get -EIO from a syscall? I *think* the answer is yes (but I
haven't been doing this very long).

> 
> 
> > I don't really have a good feel for what this interface should look
> > like
> > yet. debugfs is attractive here, as it's supposedly not part of the
> > kernel ABI guarantee. That allows us to do some experimentation in
> > this
> > area, without making too big an initial commitment.
> > -- 
> > Jeff Layton <jlayton@kernel.org>
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-
> > nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 

Thanks,
Joshua Watt

