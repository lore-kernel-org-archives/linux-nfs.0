Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:48640 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751888AbdJ3VEU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Oct 2017 17:04:20 -0400
Received: by mail-io0-f194.google.com with SMTP id j17so30341663iod.5
        for <linux-nfs@vger.kernel.org>; Mon, 30 Oct 2017 14:04:20 -0700 (PDT)
From: Joshua Watt <jpewhacker@gmail.com>
Message-ID: <1509397459.6057.20.camel@gmail.com>
Subject: Re: NFS Force Unmounting
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 30 Oct 2017 16:04:19 -0500
In-Reply-To: <20171030202045.GA6168@fieldses.org>
References: <1508951506.2542.51.camel@gmail.com>
         <20171030202045.GA6168@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-10-30 at 16:20 -0400, J. Bruce Fields wrote:
> On Wed, Oct 25, 2017 at 12:11:46PM -0500, Joshua Watt wrote:
> > I'm working on a networking embedded system where NFS servers can
> > come
> > and go from the network, and I've discovered that the Kernel NFS
> > server
> 
> For "Kernel NFS server", I think you mean "Kernel NFS client".

Yes, sorry. I was digging through the code and saw "struct nfs_server",
which is really "The local client object that represents the remote
server", and it inadvertently crept into my e-mail.

> 
> > make it difficult to cleanup applications in a timely manner when
> > the
> > server disappears (and yes, I am mounting with "soft" and
> > relatively
> > short timeouts). I currently have a user space mechanism that can
> > quickly detect when the server disappears, and does a umount() with
> > the
> > MNT_FORCE and MNT_DETACH flags. Using MNT_DETACH prevents new
> > accesses
> > to files on the defunct remote server, and I have traced through
> > the
> > code to see that MNT_FORCE does indeed cancel any current RPC tasks
> > with -EIO. However, this isn't sufficient for my use case because
> > if a
> > user space application isn't currently waiting on an RCP task that
> > gets
> > canceled, it will have to timeout again before it detects the
> > disconnect. For example, if a simple client is copying a file from
> > the
> > NFS server, and happens to not be waiting on the RPC task in the
> > read()
> > call when umount() occurs, it will be none the wiser and loop
> > around to
> > call read() again, which must then try the whole NFS timeout +
> > recovery
> > before the failure is detected. If a client is more complex and has
> > a
> > lot of open file descriptor, it will typical have to wait for each
> > one
> > to timeout, leading to very long delays.
> > 
> > The (naive?) solution seems to be to add some flag in either the
> > NFS
> > client or the RPC client that gets set in nfs_umount_begin(). This
> > would cause all subsequent operations to fail with an error code
> > instead of having to be queued as an RPC task and the and then
> > timing
> > out. In our example client, the application would then get the -EIO
> > immediately on the next (and all subsequent) read() calls.
> > 
> > There does seem to be some precedence for doing this (especially
> > with
> > network file systems), as both cifs (CifsExiting) and ceph
> > (CEPH_MOUNT_SHUTDOWN) appear to implement this behavior (at least
> > from
> > looking at the code. I haven't verified runtime behavior).
> > 
> > Are there any pitfalls I'm oversimplifying?
> 
> I don't know.
> 
> In the hard case I don't think you'd want to do something like
> this--applications expect mounts to be stay pinned while they're
> using
> them, not to get -EIO.  In the soft case maybe an exception like this
> makes sense.

Yes, I agree... maybe it should only do anything in the "soft" case (at
least, that works for my use case), however as a bit of a counter
argument, you *can* get -EIO even when mounted with "hard" because
nfs_umount_begin() still calls rpc_killall_tasks(), which will abort
any *pending* operations with -EIO, just not any future ones.

I also found that it causes a little havoc if you mount with the
"sharedcache" mount option because putting one mount into the force
unmounting state also causes all the other mounts to start returning
-EIO, as they are all sharing a superblock. Perhaps this is the correct
behavior anyway, but it certainly seems non-intuitive to a user that
force unmounting one directory would have such an effect on others so I
suspect not. I'm not sure of a decent way around this one (other than
mounting with "nosharedcache"). Is it even reasonable to detect if you
are force unmounting a superblock mounted in multiple locations and
then somehow split it up so that one mounted location can diverge in
behavior from the others (or some other mechanism I haven't thought
of)? Again however, the same counter argument as above still applies
here: if you force unmount one of the mounts that shares a superblock,
you can get -EIO on the others if they happen to have a pending
operation at the time.


> 
> --b.

Thanks,
Joshua Watt

