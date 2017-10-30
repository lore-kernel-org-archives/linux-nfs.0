Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60916 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752205AbdJ3UUq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Oct 2017 16:20:46 -0400
Date: Mon, 30 Oct 2017 16:20:45 -0400
To: Joshua Watt <jpewhacker@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS Force Unmounting
Message-ID: <20171030202045.GA6168@fieldses.org>
References: <1508951506.2542.51.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1508951506.2542.51.camel@gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 25, 2017 at 12:11:46PM -0500, Joshua Watt wrote:
> I'm working on a networking embedded system where NFS servers can come
> and go from the network, and I've discovered that the Kernel NFS server

For "Kernel NFS server", I think you mean "Kernel NFS client".

> make it difficult to cleanup applications in a timely manner when the
> server disappears (and yes, I am mounting with "soft" and relatively
> short timeouts). I currently have a user space mechanism that can
> quickly detect when the server disappears, and does a umount() with the
> MNT_FORCE and MNT_DETACH flags. Using MNT_DETACH prevents new accesses
> to files on the defunct remote server, and I have traced through the
> code to see that MNT_FORCE does indeed cancel any current RPC tasks
> with -EIO. However, this isn't sufficient for my use case because if a
> user space application isn't currently waiting on an RCP task that gets
> canceled, it will have to timeout again before it detects the
> disconnect. For example, if a simple client is copying a file from the
> NFS server, and happens to not be waiting on the RPC task in the read()
> call when umount() occurs, it will be none the wiser and loop around to
> call read() again, which must then try the whole NFS timeout + recovery
> before the failure is detected. If a client is more complex and has a
> lot of open file descriptor, it will typical have to wait for each one
> to timeout, leading to very long delays.
> 
> The (naive?) solution seems to be to add some flag in either the NFS
> client or the RPC client that gets set in nfs_umount_begin(). This
> would cause all subsequent operations to fail with an error code
> instead of having to be queued as an RPC task and the and then timing
> out. In our example client, the application would then get the -EIO
> immediately on the next (and all subsequent) read() calls.
> 
> There does seem to be some precedence for doing this (especially with
> network file systems), as both cifs (CifsExiting) and ceph
> (CEPH_MOUNT_SHUTDOWN) appear to implement this behavior (at least from
> looking at the code. I haven't verified runtime behavior).
> 
> Are there any pitfalls I'm oversimplifying?

I don't know.

In the hard case I don't think you'd want to do something like
this--applications expect mounts to be stay pinned while they're using
them, not to get -EIO.  In the soft case maybe an exception like this
makes sense.

--b.
