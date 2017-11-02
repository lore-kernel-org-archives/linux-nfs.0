Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:50479 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933448AbdKBOyF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Nov 2017 10:54:05 -0400
Received: by mail-oi0-f49.google.com with SMTP id q4so9054022oic.7
        for <linux-nfs@vger.kernel.org>; Thu, 02 Nov 2017 07:54:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1509624549.4569.28.camel@redhat.com>
References: <1508951506.2542.51.camel@gmail.com> <20171030202045.GA6168@fieldses.org>
 <87h8ugwdev.fsf@notabene.neil.brown.name> <1509557061.4755.27.camel@redhat.com>
 <87efphvbhy.fsf@notabene.neil.brown.name> <1509624549.4569.28.camel@redhat.com>
From: Joshua Watt <jpewhacker@gmail.com>
Date: Thu, 2 Nov 2017 09:54:03 -0500
Message-ID: <CAJdd5GZ-EMj8f3RaV_WUdeZs6aWbEAeC6xX8BadMD-aOFL3_jA@mail.gmail.com>
Subject: Re: NFS Force Unmounting
To: Jeff Layton <jlayton@redhat.com>
Cc: NeilBrown <neilb@suse.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 2, 2017 at 7:09 AM, Jeff Layton <jlayton@redhat.com> wrote:
> On Thu, 2017-11-02 at 10:13 +1100, NeilBrown wrote:
>> On Wed, Nov 01 2017, Jeff Layton wrote:
>>
>> > On Tue, 2017-10-31 at 08:09 +1100, NeilBrown wrote:
>> > > On Mon, Oct 30 2017, J. Bruce Fields wrote:
>> > >
>> > > > On Wed, Oct 25, 2017 at 12:11:46PM -0500, Joshua Watt wrote:
>> > > > > I'm working on a networking embedded system where NFS servers can come
>> > > > > and go from the network, and I've discovered that the Kernel NFS server
>> > > >
>> > > > For "Kernel NFS server", I think you mean "Kernel NFS client".
>> > > >
>> > > > > make it difficult to cleanup applications in a timely manner when the
>> > > > > server disappears (and yes, I am mounting with "soft" and relatively
>> > > > > short timeouts). I currently have a user space mechanism that can
>> > > > > quickly detect when the server disappears, and does a umount() with the
>> > > > > MNT_FORCE and MNT_DETACH flags. Using MNT_DETACH prevents new accesses
>> > > > > to files on the defunct remote server, and I have traced through the
>> > > > > code to see that MNT_FORCE does indeed cancel any current RPC tasks
>> > > > > with -EIO. However, this isn't sufficient for my use case because if a
>> > > > > user space application isn't currently waiting on an RCP task that gets
>> > > > > canceled, it will have to timeout again before it detects the
>> > > > > disconnect. For example, if a simple client is copying a file from the
>> > > > > NFS server, and happens to not be waiting on the RPC task in the read()
>> > > > > call when umount() occurs, it will be none the wiser and loop around to
>> > > > > call read() again, which must then try the whole NFS timeout + recovery
>> > > > > before the failure is detected. If a client is more complex and has a
>> > > > > lot of open file descriptor, it will typical have to wait for each one
>> > > > > to timeout, leading to very long delays.
>> > > > >
>> > > > > The (naive?) solution seems to be to add some flag in either the NFS
>> > > > > client or the RPC client that gets set in nfs_umount_begin(). This
>> > > > > would cause all subsequent operations to fail with an error code
>> > > > > instead of having to be queued as an RPC task and the and then timing
>> > > > > out. In our example client, the application would then get the -EIO
>> > > > > immediately on the next (and all subsequent) read() calls.
>> > > > >
>> > > > > There does seem to be some precedence for doing this (especially with
>> > > > > network file systems), as both cifs (CifsExiting) and ceph
>> > > > > (CEPH_MOUNT_SHUTDOWN) appear to implement this behavior (at least from
>> > > > > looking at the code. I haven't verified runtime behavior).
>> > > > >
>> > > > > Are there any pitfalls I'm oversimplifying?
>> > > >
>> > > > I don't know.
>> > > >
>> > > > In the hard case I don't think you'd want to do something like
>> > > > this--applications expect mounts to be stay pinned while they're using
>> > > > them, not to get -EIO.  In the soft case maybe an exception like this
>> > > > makes sense.
>> > >
>> > > Applications also expect to get responses to read() requests, and expect
>> > > fsync() to complete, but if the servers has melted down, that isn't
>> > > going to happen.  Sometimes unexpected errors are better than unexpected
>> > > infinite delays.
>> > >
>> > > I think we need a reliable way to unmount an NFS filesystem mounted from
>> > > a non-responsive server.  Maybe that just means fixing all the places
>> > > where use we use TASK_UNINTERRUTIBLE when waiting for the server.  That
>> > > would allow processes accessing the filesystem to be killed.  I don't
>> > > know if that would meet Joshua's needs.
>> > >
>> >
>> > I don't quite grok why rpc_kill on all of the RPCs doesn't do the right
>> > thing here. Are we ending up stuck because dirty pages remain after
>> > that has gone through?
>>
>> Simply because the caller might submit a new RPC that could then block.
>> I've (long ago) had experiences where I had to run "umount -f" several
>> times before the processes would die and the filesystem could be
>> unmounted.
>>
>
> Ok, makes sense, thanks, and I've seen that too.
>
>> >
>> > > Last time this came up, Trond didn't want to make MNT_FORCE too strong as
>> > > it only makes sense to be forceful on the final unmount, and we cannot
>> > > know if this is the "final" unmount (no other bind-mounts around) until
>> > > much later than ->umount_prepare.
>> >
>> > We can't know for sure that one won't race in while we're tearing things
>> > down, but do we really care so much? If the mount is stuck enough to
>> > require MNT_FORCE then it's likely that you'll end up stuck before you
>> > can do anything on that new bind mount anyway.
>>
>> I might be happy to wait for 5 seconds, you might be happy to wait for 5
>> minutes.
>> So it is fair for me to use MNT_FORCE on a filesystem that both of us
>> have mounted in different places?
>>
>
> Arguably, yes.
>
> MNT_FORCE is an administrative decision. It's only used if root (or the
> equivalent) requests it. root had better know what he's doing if he does
> request it.

I agree with this. If we are punting this complication to the the
system administator (which makes sense to me), can't the administrator
mark the NFS mount as unbindable if they don't want to deal with that
particular problem (Full disclosure, I'm not fully up to speed on what
MS_UNBINDABLE does, so I might be missing something here)? Some
documentation might be in order to suggest that?

I think there is some disparity about what MNT_FORCE applies to. Is it
intended to apply to the superblock, or the specific mount? As I
pointed out, CEPH and CIFS already have some sort of mechanism to deal
with MNT_FORCE that appears to prevent future accesses (as I am
proposing), and it appears to apply at the superblock level (at least
in a cursory reading, we need to dig further to figure out what it is
actually doing), so perhaps there is some precedent for this?

>
> That said, we don't make that part easy and it's very poorly documented.
> Seeing errors on a seemingly unrelated bind mount is probably rather
> surprising for most folks.
>
>> >
>> > Just to dream here for a minute...
>> >
>> > We could do a check for bind-mountedness during umount_begin. If it
>> > looks like there is one, we do a MNT_DETACH instead. If not, we flag the
>> > sb in such a way to block (or deny) any new bind mounts until we've had
>> > a chance to tear down the RPCs.
>>
>> MNT_DETACH mustn't be used when it isn't requested.
>> Without MNT_DETACH, umount checks for any open file descriptions
>> (including executables and cwd etc).  If it finds any, it fails.
>> With MNT_DETACH that check is skipped.  So they have very different
>> semantics.
>>
>> The point of MNT_FORCE (as I understand it), is to release processes
>> that are blocking in uninterruptible waits so they can respond to
>> signals (that have already been sent) and can close all fds and die, so
>> that there will be no more open-file-description on that mount
>> (different binds mounts have different sets of ofds) so that the
>> unmount can complete.
>>
>
> The manpage is a bit more vague in this regard (and the Only for NFS
> mounts comment is clearly wrong -- we should fix that):
>
>        MNT_FORCE (since Linux 2.1.116)
>               Force  unmount  even  if  busy.  This can cause data loss.
>               (Only for NFS mounts.)
>
> So it doesn't quite say anything about releasing processes, though I'm
> pretty sure that is how it has worked historically.
>
>> If we used TASK_KILLABLE everywhere so that any process blocked in NFS
>> could be killed, then we could move the handling of MNT_FORCE out of
>> umount_begin and into nfs_kill_super.... maybe.  Then
>> MNT_FORCE|MNT_DETACH might be able to make sense.  Maybe the MNT_FORCE

Somewhat of a side note: The userspace umount program won't let you
specify both --lazy and --force even though the kernel doesn't appear
to care:
see https://marc.info/?l=util-linux-ng&m=150939967502180&w=2

Anyone here happen to know why?

>> from the last unmount wins?  If it is set, then any dirty pages are
>> discarded.  If not set, we keep trying to write dirty pages. (though
>> with current code, dirty pages will stop nfs_kill_super() from even
>> being called).
>>
>> For Joshua's use case, he doesn't want to signal those processes but he
>> presumably trusts them to close file descriptors when they get EIO, and
>> maybe they never chdir into an NFS filesystem or exec a binary stored there.
>> So he really does want a persistent "kill all future rpcs".
>> I don't really think this is an "unmount" function at all.
>> Maybe it is more like "mount -o remount,soft,timeo=1,retrans=0"
>> Except that you cannot change any of those with a remount (and when you
>> try, mount doesn't tell you it failed, unless you use "-v").
>> I wonder if it is safe to allow them to change if nosharecache is
>> given. Or maybe even if it isn't but the nfs_client isn't shared.
>>
>> >
>> > I do realize that the mnt table locking is pretty hairy (we'll probably
>> > need Al Viro's help and support there), but it seems like that's where
>> > we should be aiming.
>> >
>> > >  Maybe umount is the wrong interface.
>> > > Maybe we should expose "struct nfs_client" (or maybe "struct
>> > > nfs_server") objects via sysfs so they can be marked "dead" (or similar)
>> > > meaning that all IO should fail.
>> > >
>> >
>> > Now that I've thought about it more, I rather like using umount with
>> > MNT_FORCE for this, really. It seems like that's what its intended use
>> > was, and the fact that it doesn't quite work that way has always been a
>> > point of confusion for users. It'd be nice if that magically started
>> > working more like they expect.
>>
>> So what, exactly, would you suggest be the semantics of MNT_FORCE?
>> How does it interact with MNT_DETACH?
>>
>
> My (admittedly half-baked) thinking was to "reinterpret" MNT_FORCE to
> act like MNT_DETACH in the case where there are other bind mounts
> present.
>
> It was all smoke and mirrors to get the thing detached from the tree,
> and hopefully to clean stuff up once it's detached. Now that you've
> pointed out the difficulties here though, I think it's not really
> sufficient.
>
> You could still have processes with open fd's, for instance and that
> doesn't really do anything about them. It's a pity that the revoke()
> syscall work never came to fruition, that could be useful here.

Yes revoke() was my first though for solving this.... I (and probably
the rest of the embedded Linux world) will owe whoever finally
implements that a beer.

> --
> Jeff Layton <jlayton@redhat.com>
