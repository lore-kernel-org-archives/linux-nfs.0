Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:28284 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932210AbdKACWY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Oct 2017 22:22:24 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: NFS Force Unmounting
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <8760aux1j5.fsf@notabene.neil.brown.name>
Date: Tue, 31 Oct 2017 22:22:14 -0400
Cc: Jeff Layton <jlayton@kernel.org>,
        Bruce Fields <bfields@fieldses.org>,
        Joshua Watt <jpewhacker@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <8EB53737-9126-4D26-A22F-D09639BE5130@oracle.com>
References: <1508951506.2542.51.camel@gmail.com> <20171030202045.GA6168@fieldses.org> <87h8ugwdev.fsf@notabene.neil.brown.name> <1509460909.4553.37.camel@kernel.org> <8760aux1j5.fsf@notabene.neil.brown.name>
To: NeilBrown <neilb@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 31, 2017, at 8:53 PM, NeilBrown <neilb@suse.com> wrote:
> 
> On Tue, Oct 31 2017, Jeff Layton wrote:
> 
>> On Tue, 2017-10-31 at 08:09 +1100, NeilBrown wrote:
>>> On Mon, Oct 30 2017, J. Bruce Fields wrote:
>>> 
>>>> On Wed, Oct 25, 2017 at 12:11:46PM -0500, Joshua Watt wrote:
>>>>> I'm working on a networking embedded system where NFS servers can come
>>>>> and go from the network, and I've discovered that the Kernel NFS server
>>>> 
>>>> For "Kernel NFS server", I think you mean "Kernel NFS client".
>>>> 
>>>>> make it difficult to cleanup applications in a timely manner when the
>>>>> server disappears (and yes, I am mounting with "soft" and relatively
>>>>> short timeouts). I currently have a user space mechanism that can
>>>>> quickly detect when the server disappears, and does a umount() with the
>>>>> MNT_FORCE and MNT_DETACH flags. Using MNT_DETACH prevents new accesses
>>>>> to files on the defunct remote server, and I have traced through the
>>>>> code to see that MNT_FORCE does indeed cancel any current RPC tasks
>>>>> with -EIO. However, this isn't sufficient for my use case because if a
>>>>> user space application isn't currently waiting on an RCP task that gets
>>>>> canceled, it will have to timeout again before it detects the
>>>>> disconnect. For example, if a simple client is copying a file from the
>>>>> NFS server, and happens to not be waiting on the RPC task in the read()
>>>>> call when umount() occurs, it will be none the wiser and loop around to
>>>>> call read() again, which must then try the whole NFS timeout + recovery
>>>>> before the failure is detected. If a client is more complex and has a
>>>>> lot of open file descriptor, it will typical have to wait for each one
>>>>> to timeout, leading to very long delays.
>>>>> 
>>>>> The (naive?) solution seems to be to add some flag in either the NFS
>>>>> client or the RPC client that gets set in nfs_umount_begin(). This
>>>>> would cause all subsequent operations to fail with an error code
>>>>> instead of having to be queued as an RPC task and the and then timing
>>>>> out. In our example client, the application would then get the -EIO
>>>>> immediately on the next (and all subsequent) read() calls.
>>>>> 
>>>>> There does seem to be some precedence for doing this (especially with
>>>>> network file systems), as both cifs (CifsExiting) and ceph
>>>>> (CEPH_MOUNT_SHUTDOWN) appear to implement this behavior (at least from
>>>>> looking at the code. I haven't verified runtime behavior).
>>>>> 
>>>>> Are there any pitfalls I'm oversimplifying?
>>>> 
>>>> I don't know.
>>>> 
>>>> In the hard case I don't think you'd want to do something like
>>>> this--applications expect mounts to be stay pinned while they're using
>>>> them, not to get -EIO.  In the soft case maybe an exception like this
>>>> makes sense.
>>> 
>>> Applications also expect to get responses to read() requests, and expect
>>> fsync() to complete, but if the servers has melted down, that isn't
>>> going to happen.  Sometimes unexpected errors are better than unexpected
>>> infinite delays.
>>> 
>>> I think we need a reliable way to unmount an NFS filesystem mounted from
>>> a non-responsive server.  Maybe that just means fixing all the places
>>> where use we use TASK_UNINTERRUTIBLE when waiting for the server.  That
>>> would allow processes accessing the filesystem to be killed.  I don't
>>> know if that would meet Joshua's needs.
>>> 
>>> Last time this came up, Trond didn't want to make MNT_FORCE too strong as
>>> it only makes sense to be forceful on the final unmount, and we cannot
>>> know if this is the "final" unmount (no other bind-mounts around) until
>>> much later than ->umount_prepare.  Maybe umount is the wrong interface.
>>> Maybe we should expose "struct nfs_client" (or maybe "struct
>>> nfs_server") objects via sysfs so they can be marked "dead" (or similar)
>>> meaning that all IO should fail.
>>> 
>> 
>> I like this idea.
>> 
>> Note that we already have some per-rpc_xprt / per-rpc_clnt info in
>> debugfs sunrpc dir. We could make some writable files in there, to allow
>> you to kill off individual RPCs or maybe mark a whole clnt and/or xprt
>> dead in some fashion.
>> 
>> I don't really have a good feel for what this interface should look like
>> yet. debugfs is attractive here, as it's supposedly not part of the
>> kernel ABI guarantee. That allows us to do some experimentation in this
>> area, without making too big an initial commitment.
> 
> debugfs might be attractive to kernel developers: "all care but not
> responsibility", but not so much to application developers (though I do
> realize that your approch was "something to experiment with" so maybe
> that doesn't matter).

I read Jeff's suggestion as "start in debugfs and move to /sys
with the other long-term administrative interfaces". <shrug>


> My particular focus is to make systemd shutdown completely reliable.

In particular: umount.nfs has to be reliable, and/or stuck NFS
mounts have to avoid impacting other aspects of system
operation (like syncing other filesystems).


> It should not block indefinitely on any condition, including inaccessible
> servers and broken networks.

There are occasions where a "hard" semantic is appropriate,
and killing everything unconditionally can result in unexpected
and unwanted consequences. I would strongly object to any
approach that includes automatically discarding data without
user/administrator choice in the matter. One size does not fit
all here.

At least let's stop and think about consequences. I'm sure I
don't understand all of them yet.


> In stark contrast to Chuck's suggestion that
> 
> 
>   Any RPC that might alter cached data/metadata is not, but others
>   would be safe.
> 
> ("safe" here meaning "safe to kill the RPC"), I think that everything
> can and should be killed.  Maybe the first step is to purge any dirty
> pages from the cache.
> - the server is up, we write the data
> - if we are happy to wait, we wait
> - otherwise (the case I'm interested in), we just destroy anything
>  that gets in the way of unmounting the filesystem.

(The technical issue still to be resolved is how to kill
processes that are sleeping uninterruptibly, but for the
moment let's assume we can do that, and think about the
policy questions).

How do you decide the server is "up" without possibly hanging
or human intervention? Certainly there is a point where we
want to scorch the earth, but I think the user and administrator
get to decide where that is. systemd is not the place for that
decision.

Actually, I think that dividing the RPC world into "safe to
kill" and "need to ask first" is roughly the same as the
steps you outline above: at some point we both eventually get
to kill_all. The question is how to get there allowing as much
automation as possible and without compromising data integrity.

There are RPCs that are always safe to kill, eg NFS READ and
GETATTR. If those are the only waiters, then they can always be
terminated on umount. That is already a good start at making
NFSv3 umount more reliable, since often the only thing it is
waiting for is a single GETATTR.

Question marks arise when we are dealing with WRITE, SETATTR,
and so on, when we know the server is still there somewhere,
and even when we're not sure whether the server is still
available. It is here where we assess our satisfaction for
waiting out a network partition or server restart.

There's no way to automate that safely, unless you state in
advance that "your data is not protected during an umount."
There are some environments where that is OK, and some where
it is absolute disaster. Again, the user and administrator get
to make that choice, IMO. Maybe a new mount option?

Data integrity is critical up until some point where it isn't.
A container is no longer needed, all the data it cared about
can be discarded. I think that line needs to be drawn while
the system is still operational. It's not akin to umount at
all, since it involves possible destruction of data. It's more
like TRIM.


> I'd also like to make the interface completely generic.  I'd rather
> systemd didn't need to know any specific details about nfs (it already
> does to some extend - it knows it is a "remote" filesystem) but
> I'd rather not require more.

> Maybe I could just sweep the problem under the carpet and use lazy
> unmounts.  That hides some of the problem, but doesn't stop sync(2) from
> blocking indefinitely.  And once you have done the lazy unmount, there
> is no longer any opportunity to use MNT_FORCE.

IMO a partial answer could be data caching in local files. If
the client can't flush, then it can preserve the files until
after the umount and reboot (using, say, fscache). Multi-client
sharing is still hazardous, but that isn't a very frequent use
case.


> Another way to think about this is to consider the bdi rather than the
> mount point.  If the NFS server is never coming back, then the "backing
> device" is broken.  If /sys/class/bdi/* contained suitable information
> to identify the right backing device, and had some way to "terminate
> with extreme prejudice", then and admin process (like systemd or
> anything else) could choose to terminate a bdi that was not working
> properly.
> 
> We would need quite a bit of integration so that this "terminate"
> command would take effect, cause various syscalls to return EIO, purge
> dirty memory, avoid stalling sync().  But it hopefully it would be
> a well defined interface and a good starting point.

Unhooking the NFS filesystem's "sync" method might be helpful,
though, to let the system preserve other filesystems before
shutdown. The current situation can indeed result in local
data corruption, and should be considered a bug IMO.


> If the bdi provided more information and more control, it would be a lot
> safer to use lazy unmounts, as we could then work with the filesystem
> even after it had been unmounted.
> 
> Maybe I'll trying playing with bdis in my spare time (if I ever find out
> what "spare time" is).
> 
> Thanks,
> NeilBrown

--
Chuck Lever



