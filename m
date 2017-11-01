Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:47289 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754973AbdKARYX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Nov 2017 13:24:23 -0400
Received: by mail-qt0-f171.google.com with SMTP id z50so3571290qtj.4
        for <linux-nfs@vger.kernel.org>; Wed, 01 Nov 2017 10:24:23 -0700 (PDT)
Message-ID: <1509557061.4755.27.camel@redhat.com>
Subject: Re: NFS Force Unmounting
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Joshua Watt <jpewhacker@gmail.com>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
Date: Wed, 01 Nov 2017 13:24:21 -0400
In-Reply-To: <87h8ugwdev.fsf@notabene.neil.brown.name>
References: <1508951506.2542.51.camel@gmail.com>
         <20171030202045.GA6168@fieldses.org>
         <87h8ugwdev.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-10-31 at 08:09 +1100, NeilBrown wrote:
> On Mon, Oct 30 2017, J. Bruce Fields wrote:
> 
> > On Wed, Oct 25, 2017 at 12:11:46PM -0500, Joshua Watt wrote:
> > > I'm working on a networking embedded system where NFS servers can come
> > > and go from the network, and I've discovered that the Kernel NFS server
> > 
> > For "Kernel NFS server", I think you mean "Kernel NFS client".
> > 
> > > make it difficult to cleanup applications in a timely manner when the
> > > server disappears (and yes, I am mounting with "soft" and relatively
> > > short timeouts). I currently have a user space mechanism that can
> > > quickly detect when the server disappears, and does a umount() with the
> > > MNT_FORCE and MNT_DETACH flags. Using MNT_DETACH prevents new accesses
> > > to files on the defunct remote server, and I have traced through the
> > > code to see that MNT_FORCE does indeed cancel any current RPC tasks
> > > with -EIO. However, this isn't sufficient for my use case because if a
> > > user space application isn't currently waiting on an RCP task that gets
> > > canceled, it will have to timeout again before it detects the
> > > disconnect. For example, if a simple client is copying a file from the
> > > NFS server, and happens to not be waiting on the RPC task in the read()
> > > call when umount() occurs, it will be none the wiser and loop around to
> > > call read() again, which must then try the whole NFS timeout + recovery
> > > before the failure is detected. If a client is more complex and has a
> > > lot of open file descriptor, it will typical have to wait for each one
> > > to timeout, leading to very long delays.
> > > 
> > > The (naive?) solution seems to be to add some flag in either the NFS
> > > client or the RPC client that gets set in nfs_umount_begin(). This
> > > would cause all subsequent operations to fail with an error code
> > > instead of having to be queued as an RPC task and the and then timing
> > > out. In our example client, the application would then get the -EIO
> > > immediately on the next (and all subsequent) read() calls.
> > > 
> > > There does seem to be some precedence for doing this (especially with
> > > network file systems), as both cifs (CifsExiting) and ceph
> > > (CEPH_MOUNT_SHUTDOWN) appear to implement this behavior (at least from
> > > looking at the code. I haven't verified runtime behavior).
> > > 
> > > Are there any pitfalls I'm oversimplifying?
> > 
> > I don't know.
> > 
> > In the hard case I don't think you'd want to do something like
> > this--applications expect mounts to be stay pinned while they're using
> > them, not to get -EIO.  In the soft case maybe an exception like this
> > makes sense.
> 
> Applications also expect to get responses to read() requests, and expect
> fsync() to complete, but if the servers has melted down, that isn't
> going to happen.  Sometimes unexpected errors are better than unexpected
> infinite delays.
> 
> I think we need a reliable way to unmount an NFS filesystem mounted from
> a non-responsive server.  Maybe that just means fixing all the places
> where use we use TASK_UNINTERRUTIBLE when waiting for the server.  That
> would allow processes accessing the filesystem to be killed.  I don't
> know if that would meet Joshua's needs.
> 

I don't quite grok why rpc_kill on all of the RPCs doesn't do the right
thing here. Are we ending up stuck because dirty pages remain after
that has gone through?

> Last time this came up, Trond didn't want to make MNT_FORCE too strong as
> it only makes sense to be forceful on the final unmount, and we cannot
> know if this is the "final" unmount (no other bind-mounts around) until
> much later than ->umount_prepare. 

We can't know for sure that one won't race in while we're tearing things
down, but do we really care so much? If the mount is stuck enough to
require MNT_FORCE then it's likely that you'll end up stuck before you
can do anything on that new bind mount anyway.

Just to dream here for a minute...

We could do a check for bind-mountedness during umount_begin. If it
looks like there is one, we do a MNT_DETACH instead. If not, we flag the
sb in such a way to block (or deny) any new bind mounts until we've had
a chance to tear down the RPCs.

I do realize that the mnt table locking is pretty hairy (we'll probably
need Al Viro's help and support there), but it seems like that's where
we should be aiming.

>  Maybe umount is the wrong interface.
> Maybe we should expose "struct nfs_client" (or maybe "struct
> nfs_server") objects via sysfs so they can be marked "dead" (or similar)
> meaning that all IO should fail.
> 

Now that I've thought about it more, I rather like using umount with
MNT_FORCE for this, really. It seems like that's what its intended use
was, and the fact that it doesn't quite work that way has always been a
point of confusion for users. It'd be nice if that magically started
working more like they expect.
-- 
Jeff Layton <jlayton@redhat.com>
