Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:42039 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752227AbdLVQmz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Dec 2017 11:42:55 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH/RFC] NFS: add nostatflush mount option.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <87h8sjkdo4.fsf@notabene.neil.brown.name>
Date: Fri, 22 Dec 2017 11:38:43 -0500
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org
Message-Id: <44DD6748-B8A4-43DB-95A4-21E588F5E84B@oracle.com>
References: <87k1xgkct1.fsf@notabene.neil.brown.name> <4B4DA4D4-8068-4C10-92BE-F03632522C75@oracle.com> <87h8sjkdo4.fsf@notabene.neil.brown.name>
To: NeilBrown <neilb@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 21, 2017, at 3:51 PM, NeilBrown <neilb@suse.com> wrote:
>=20
> On Thu, Dec 21 2017, Chuck Lever wrote:
>=20
>> Hi Neil-
>>=20
>>=20
>>> On Dec 20, 2017, at 9:57 PM, NeilBrown <neilb@suse.com> wrote:
>>>=20
>>>=20
>>> When an i_op->getattr() call is made on an NFS file
>>> (typically from a 'stat' family system call), NFS
>>> will first flush any dirty data to the server.
>>>=20
>>> This ensures that the mtime reported is correct and stable,
>>> but has a performance penalty.  'stat' is normally thought
>>> to be a quick operation, and imposing this cost can be
>>> surprising.
>>=20
>> To be clear, this behavior is a POSIX requirement.
>=20
> Ah, that would be:
>=20
> =
http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap04.html#ta=
g_04_09
>=20
> which says:
>=20
>  All timestamps that are marked for update shall be updated when the
>  file ceases to be open by any process or before a fstat(), fstatat(),
>  fsync(), futimens(), lstat(), stat(), utime(), utimensat(), or
>  utimes() is successfully performed on the file.
>=20
> Suppose that when handling a stat(), if we find there are dirty pages,
> we send a SETATTR to the server to set the mtime to the current time,
> and use the result for the mtime?  That would avoid the costly flush, =
but still
> give the appearance of the mtime being correctly updated.
>=20
>>=20
>>=20
>>> I have seen problems when one process is writing a large
>>> file and another process performs "ls -l" on the containing
>>> directory and is blocked for as long as it take to flush
>>> all the dirty data to the server, which can be minutes.
>>=20
>> Yes, a well-known annoyance that cannot be addressed
>> even with a write delegation.
>>=20
>>=20
>>> I have also seen a legacy application which frequently calls
>>> "fstat" on a file that it is writing to.  On a local
>>> filesystem (and in the Solaris implementation of NFS) this
>>> fstat call is cheap.  On Linux/NFS, the causes a noticeable
>>> decrease in throughput.
>>=20
>> If the preceding write is small, Linux could be using
>> a FILE_SYNC write, but Solaris could be using UNSTABLE.
>=20
> No, what is actually happening is that Linux is flushing out data and
> Solaris isn't.  There are differences in stability and in write size,
> but they aren't the main contributors to the performance difference.
>=20
>>=20
>>=20
>>> The only circumstances where an application calling 'stat()'
>>> might get an mtime which is not stable are times when some
>>> other process is writing to the file and the two processes
>>> are not using locking to ensure consistency, or when the one
>>> process is both writing and stating.  In neither of these
>>> cases is it reasonable to expect the mtime to be stable.
>>=20
>> I'm not convinced this is a strong enough rationale
>> for claiming it is safe to disable the existing
>> behavior.
>>=20
>> You've explained cases where the new behavior is
>> reasonable, but do you have any examples where the
>> new behavior would be a problem? There must be a
>> reason why POSIX explicitly requires an up-to-date
>> mtime.
>=20
> I honestly cannot think of any credible scenario where the current
> behaviour would be required.

I can't either, but:
- We have years of this behavior in place
- It is required by an aged standard

I don't mind creative thinking, but perhaps we do
need a higher bar than "can you remember why we do
this? <shrug>" before mitigating this particular
behavior. :-)


> If I write to a file from one NFS client, and request a stat() from
> another NFS client, the stat doesn't flush any data (though it could
> with NFSv4 if write delegations were being given).  So depending on a
> stat() returning precise timestamps when there is no other =
co-ordination
> between processes will already fail.  Why do we need to provide a
> guarantee to processes running on the same client that we don't =
provide
> to processes running on different clients?

When multiple clients are in play, as you pointed out
earlier, we do require explicit locking for correct
behavior. This usage scenario is clearly one that can
be done only in the context of a distributed file
system (ie., not on non-clustered local file systems).
Thus explicit locking is a tolerable and expected
requirement.


>> What guidance would nfs(5) give on when it is safe
>> to specify the new mount option?
>=20
> That is an excellent question to which I don't have an excellent =
answer.
>=20
> nostatflush:  A strict reading of the Posix specification requires =
that
>  any cached writes be flushed to the server before responding to
>  stat() and related operations, so that the timestamps are accurate
>  and stable. NFS does not guarantee this between applications on
>  different clients, but does when the writer and the caller of stat()
>  are on the same host.  This flush can sometimes negatively impact
>  performance.  Specifying the nostatflush option causes NFS to ignore
>  this requirement of Posix.  A stat call when there is dirty data may
>  report a different modify timestamp to the one that would be reported
>  after that data was subsequently flushed to the server.  There are no
>  known use cases where this inconsistency would cause a problem, but =
as
>  avoiding it is a Posix requirement, the default behavior to force a
>  flush on every stat() call.
>=20
> ???
>=20
>=20
>=20
>>=20
>>=20
>>> In the most common cases where mtime is important
>>> (e.g. make), no other process has the file open, so there
>>> will be no dirty data and the mtime will be stable.
>>=20
>> Isn't it also the case that make is a multi-process
>> workload where one process modifies a file, then
>> closes it (which triggers a flush), and then another
>> process stats the file? The new mount option does
>> not change the behavior of close(2), does it?
>=20
> No, the mount option doesn't change the behaviour of close(2).
> A separate mount option (nocto) can do that.
>=20
> I think your point is that close() can be delayed by flush in the same
> way that stat() can.  I think that is true, but not very relevant.

Agreed, it isn't relevant. So I'm wondering why we
should consider "make" at all in this case.


> stat() can be called more often that close() is likely to be, and
> close() only imposes a delay on the process that did the writing, =
after
> it has finished writing.

I don't believe that's true. The file's data cache is
shared across all applications on a client, and a
writeback on close is so that a subsequent GETATTR
reflects information about the file can be used to
verify the data cached the next time an application
on this client opens this file (close-to-open).

For NFSv4, of course, the client must flush dirty
data before it relinquishes the valid state ID at
CLOSE time.


> stat() can impose a delay on arbitrary other
> processes and at other times.

Eliminating unexpected latency is a noble goal. However,
write(2) can occasionally take a long time when the
application has unintentionally exceeded a dirty limit
for example.

More frequent writeback is part of the "sharing tax"
that network file systems have to pay. It can be
reduced somewhat in NFSv4 with delegation, though a
file's current mtime is still managed by the physical
file system on the NFS server.


>>> Rather than unilaterally changing this behavior of 'stat',
>>> this patch adds a "nosyncflush" mount option to allow
>>> sysadmins to have applications which are hurt by the current
>>> behavior to disable it.
>>=20
>> IMO a mount option is at the wrong granularity. A
>> mount point will be shared between applications that
>> can tolerate the non-POSIX behavior and those that
>> cannot, for instance.
>=20
> It is a better granularity than a module parameter, which was my first
> approach ;-)
>=20
> Yes, if we could create a control-group which avoided flush-on-stat, =
and
> ran the problematic programs in that control group, that might be =
ideal
> ... for some values of "ideal".
>=20
> You *could* mount the same filesystem in two places with nosharecache
> and with only one having nosyncflush.  But you probably wouldn't.

>> I would rather see us address the underlying cause
>> of the delay, which is that the GETATTR gets starved
>> by an ongoing stream of WRITE requests. You could:
>=20
> I don't think starving is the issue.
> Of the two specific cases that I have seen,
> in one the issue was that the dirty_ratio multiplied by the amount of
> memory, divided by the throughput to the server, resulted in many
> minutes to flush out all the dirty data.  Having "ls -l" wait for that
> flush was quite inconvenient. (We asked the customer to tune =
dirty_ratio
> way down).

This is the classic remedy for this problem. The default
dirty_ratio setting is antique for contemporary hardware.


> In the other (more recent) case the file being written was some sort =
of
> data-base being restored from a dump (or something like that).  So =
some
> blocks (presumably indexing blocks) were being written multiple times.
> When we disabled flush-on-sync

flush-on-sync? That seems like a good thing! Do you mean
flush-on-getattr?


> the total number of bytes written went
> down by about 20% (vague memory .. certainly a non-trivial amount)
> because these index block were only written to the server once instead
> of multiple times.  So that flush-on-stat slowed down throughput in =
part
> by pushing more data over the wire.

That behavior is disappointing, but arguments that the
application should be modified to address this issue (use
statx or avoid stat(2)) are convincing to me.


>> - Make active writers wait for the GETATTR so the
>> GETATTR is not starved
>>=20
>> - Start flushing dirty pages earlier so there is
>> less to flush when a stat(2) is done
>>=20
>> - Ensure that GETATTR is not also waiting for a
>> COMMIT
>>=20
>> Or maybe there's some other problem?
>>=20
>> I recall nfs_getattr used to grab i_mutex to hold
>> up active writers. But i_mutex is gone now. Is
>> there some other mechanism that can block writers
>> while the client flushes the file and handles the
>> GETATTR request?
>=20
> I vaguely remember when i_mutex locking was added to nfs_getattr to
> avoid the starvation :-)
> Today nfs_getattr() calls filemap_write_and_wait() which first =
triggers
> writes on all dirty pages, then waits for all writeback pages.
> The first stage should be fairly quick, and writes during the second
> stage shouldn't slow it down.  If some process were calling fsync =
often
> (e.g. using O_SYNC) that might starve nfs_getattr(), but I don't think
> normal usage would.
>=20
> I do agree that a "real" fix would be better than a mount option.
> The only path to a "real" fix that I can think of is to provide some
> alternate source of producing a credible mtime without flushing all =
the
> data.

Perhaps, but flushing sooner will get us most of the way
there IMO, and seems more straightforward then playing
merry mtime games.

Jens Axboe had some writeback improvements that might
make it possible to start writeback sooner, depending on
the aggregate writeback throughput limit of the backing
storage. Not sure these were ever applied to the NFS
client.

The downside to starting writeback sooner is that an
application that uses a file as temporary rather than
persistent storage might be penalized (similar to the
second scenario you mention above).


> Might a SETATTR using SET_TO_SERVER_TIME be a workable way forward?

I thought about this, but here we risk the following odd
behavior:

1. The application calls write(2), and the client caches
the dirtied pages.

2. The application calls stat(2), the client explicitly
updates the mtime, then does a GETATTR returning mtime "A"
to the application.

3. The client later flushes the dirty data, and the
server updates the mtime again to mtime "B"

4. The application does another stat(2), the client
emits another GETATTR, and sees mtime "B" even though
there have been no additional write(2) calls on that
file.

That might be surprising to applications that, like the
client itself, rely on the file's mtime to detect outside
modification of the file. And it certainly violates POSIX.

Perhaps we could add a mechanism to the NFS protocol that
allows a client to send a WRITE that does not update the
file's mtime while holding a write delegation. In other
words, introduce a mode where the client rather than the
server manages a file's mtime.

Maybe pNFS block layout would allow this already?


> Thank for your thoughts!
>=20
> NeilBrown
>=20
>>=20
>>=20
>>> Note that this option should probably *not* be used together
>>> with "nocto".  In that case, mtime could be unstable even
>>> when no process has the file open.
>>>=20
>>> Signed-off-by: NeilBrown <neilb@suse.com>
>>> ---
>>> fs/nfs/inode.c                 |  3 ++-
>>> fs/nfs/super.c                 | 10 ++++++++++
>>> include/uapi/linux/nfs_mount.h |  6 ++++--
>>> 3 files changed, 16 insertions(+), 3 deletions(-)
>>>=20
>>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>>> index b992d2382ffa..16629a34dd62 100644
>>> --- a/fs/nfs/inode.c
>>> +++ b/fs/nfs/inode.c
>>> @@ -740,7 +740,8 @@ int nfs_getattr(const struct path *path, struct =
kstat *stat,
>>>=20
>>> 	trace_nfs_getattr_enter(inode);
>>> 	/* Flush out writes to the server in order to update c/mtime.  =
*/
>>> -	if (S_ISREG(inode->i_mode)) {
>>> +	if (S_ISREG(inode->i_mode) &&
>>> +	    !(NFS_SERVER(inode)->flags & NFS_MOUNT_NOSTATFLUSH)) {
>>> 		err =3D filemap_write_and_wait(inode->i_mapping);
>>> 		if (err)
>>> 			goto out;
>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>> index 29bacdc56f6a..2351c0be98f5 100644
>>> --- a/fs/nfs/super.c
>>> +++ b/fs/nfs/super.c
>>> @@ -90,6 +90,7 @@ enum {
>>> 	Opt_resvport, Opt_noresvport,
>>> 	Opt_fscache, Opt_nofscache,
>>> 	Opt_migration, Opt_nomigration,
>>> +	Opt_statflush, Opt_nostatflush,
>>>=20
>>> 	/* Mount options that take integer arguments */
>>> 	Opt_port,
>>> @@ -151,6 +152,8 @@ static const match_table_t =
nfs_mount_option_tokens =3D {
>>> 	{ Opt_nofscache, "nofsc" },
>>> 	{ Opt_migration, "migration" },
>>> 	{ Opt_nomigration, "nomigration" },
>>> +	{ Opt_statflush, "statflush" },
>>> +	{ Opt_nostatflush, "nostatflush" },
>>>=20
>>> 	{ Opt_port, "port=3D%s" },
>>> 	{ Opt_rsize, "rsize=3D%s" },
>>> @@ -637,6 +640,7 @@ static void nfs_show_mount_options(struct =
seq_file *m, struct nfs_server *nfss,
>>> 		{ NFS_MOUNT_NORDIRPLUS, ",nordirplus", "" },
>>> 		{ NFS_MOUNT_UNSHARED, ",nosharecache", "" },
>>> 		{ NFS_MOUNT_NORESVPORT, ",noresvport", "" },
>>> +		{ NFS_MOUNT_NOSTATFLUSH, ",nostatflush", "" },
>>> 		{ 0, NULL, NULL }
>>> 	};
>>> 	const struct proc_nfs_info *nfs_infop;
>>> @@ -1334,6 +1338,12 @@ static int nfs_parse_mount_options(char *raw,
>>> 		case Opt_nomigration:
>>> 			mnt->options &=3D ~NFS_OPTION_MIGRATION;
>>> 			break;
>>> +		case Opt_statflush:
>>> +			mnt->flags &=3D ~NFS_MOUNT_NOSTATFLUSH;
>>> +			break;
>>> +		case Opt_nostatflush:
>>> +			mnt->flags |=3D NFS_MOUNT_NOSTATFLUSH;
>>> +			break;
>>>=20
>>> 		/*
>>> 		 * options that take numeric values
>>> diff --git a/include/uapi/linux/nfs_mount.h =
b/include/uapi/linux/nfs_mount.h
>>> index e44e00616ab5..d7c6f809d25d 100644
>>> --- a/include/uapi/linux/nfs_mount.h
>>> +++ b/include/uapi/linux/nfs_mount.h
>>> @@ -72,7 +72,9 @@ struct nfs_mount_data {
>>> #define NFS_MOUNT_NORESVPORT		0x40000
>>> #define NFS_MOUNT_LEGACY_INTERFACE	0x80000
>>>=20
>>> -#define NFS_MOUNT_LOCAL_FLOCK	0x100000
>>> -#define NFS_MOUNT_LOCAL_FCNTL	0x200000
>>> +#define NFS_MOUNT_LOCAL_FLOCK		0x100000
>>> +#define NFS_MOUNT_LOCAL_FCNTL		0x200000
>>> +
>>> +#define NFS_MOUNT_NOSTATFLUSH		0x400000
>>>=20
>>> #endif
>>> --=20
>>> 2.14.0.rc0.dirty
>>>=20
>>=20
>> --
>> Chuck Lever

--
Chuck Lever



