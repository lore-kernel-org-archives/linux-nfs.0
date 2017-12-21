Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47630 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755330AbdLUUvf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Dec 2017 15:51:35 -0500
From: NeilBrown <neilb@suse.com>
To: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 22 Dec 2017 07:51:23 +1100
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH/RFC] NFS: add nostatflush mount option.
In-Reply-To: <4B4DA4D4-8068-4C10-92BE-F03632522C75@oracle.com>
References: <87k1xgkct1.fsf@notabene.neil.brown.name> <4B4DA4D4-8068-4C10-92BE-F03632522C75@oracle.com>
Message-ID: <87h8sjkdo4.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 21 2017, Chuck Lever wrote:

> Hi Neil-
>
>
>> On Dec 20, 2017, at 9:57 PM, NeilBrown <neilb@suse.com> wrote:
>>=20
>>=20
>> When an i_op->getattr() call is made on an NFS file
>> (typically from a 'stat' family system call), NFS
>> will first flush any dirty data to the server.
>>=20
>> This ensures that the mtime reported is correct and stable,
>> but has a performance penalty.  'stat' is normally thought
>> to be a quick operation, and imposing this cost can be
>> surprising.
>
> To be clear, this behavior is a POSIX requirement.

Ah, that would be:

 http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap04.html#ta=
g_04_09

which says:

  All timestamps that are marked for update shall be updated when the
  file ceases to be open by any process or before a fstat(), fstatat(),
  fsync(), futimens(), lstat(), stat(), utime(), utimensat(), or
  utimes() is successfully performed on the file.

Suppose that when handling a stat(), if we find there are dirty pages,
we send a SETATTR to the server to set the mtime to the current time,
and use the result for the mtime?  That would avoid the costly flush, but s=
till
give the appearance of the mtime being correctly updated.

>
>
>> I have seen problems when one process is writing a large
>> file and another process performs "ls -l" on the containing
>> directory and is blocked for as long as it take to flush
>> all the dirty data to the server, which can be minutes.
>
> Yes, a well-known annoyance that cannot be addressed
> even with a write delegation.
>
>
>> I have also seen a legacy application which frequently calls
>> "fstat" on a file that it is writing to.  On a local
>> filesystem (and in the Solaris implementation of NFS) this
>> fstat call is cheap.  On Linux/NFS, the causes a noticeable
>> decrease in throughput.
>
> If the preceding write is small, Linux could be using
> a FILE_SYNC write, but Solaris could be using UNSTABLE.

No, what is actually happening is that Linux is flushing out data and
Solaris isn't.  There are differences in stability and in write size,
but they aren't the main contributors to the performance difference.

>
>
>> The only circumstances where an application calling 'stat()'
>> might get an mtime which is not stable are times when some
>> other process is writing to the file and the two processes
>> are not using locking to ensure consistency, or when the one
>> process is both writing and stating.  In neither of these
>> cases is it reasonable to expect the mtime to be stable.
>
> I'm not convinced this is a strong enough rationale
> for claiming it is safe to disable the existing
> behavior.
>
> You've explained cases where the new behavior is
> reasonable, but do you have any examples where the
> new behavior would be a problem? There must be a
> reason why POSIX explicitly requires an up-to-date
> mtime.

I honestly cannot think of any credible scenario where the current
behaviour would be required.
If I write to a file from one NFS client, and request a stat() from
another NFS client, the stat doesn't flush any data (though it could
with NFSv4 if write delegations were being given).  So depending on a
stat() returning precise timestamps when there is no other co-ordination
between processes will already fail.  Why do we need to provide a
guarantee to processes running on the same client that we don't provide
to processes running on different clients?

>
> What guidance would nfs(5) give on when it is safe
> to specify the new mount option?

That is an excellent question to which I don't have an excellent answer.

 nostatflush:  A strict reading of the Posix specification requires that
  any cached writes be flushed to the server before responding to
  stat() and related operations, so that the timestamps are accurate
  and stable. NFS does not guarantee this between applications on
  different clients, but does when the writer and the caller of stat()
  are on the same host.  This flush can sometimes negatively impact
  performance.  Specifying the nostatflush option causes NFS to ignore
  this requirement of Posix.  A stat call when there is dirty data may
  report a different modify timestamp to the one that would be reported
  after that data was subsequently flushed to the server.  There are no
  known use cases where this inconsistency would cause a problem, but as
  avoiding it is a Posix requirement, the default behavior to force a
  flush on every stat() call.

???

=20=20

>
>
>> In the most common cases where mtime is important
>> (e.g. make), no other process has the file open, so there
>> will be no dirty data and the mtime will be stable.
>
> Isn't it also the case that make is a multi-process
> workload where one process modifies a file, then
> closes it (which triggers a flush), and then another
> process stats the file? The new mount option does
> not change the behavior of close(2), does it?

No, the mount option doesn't change the behaviour of close(2).
A separate mount option (nocto) can do that.

I think your point is that close() can be delayed by flush in the same
way that stat() can.  I think that is true, but not very relevant.
stat() can be called more often that close() is likely to be, and
close() only imposes a delay on the process that did the writing, after
it has finished writing.  stat() can impose a delay on arbitrary other
processes and at other times.

>
>
>> Rather than unilaterally changing this behavior of 'stat',
>> this patch adds a "nosyncflush" mount option to allow
>> sysadmins to have applications which are hurt by the current
>> behavior to disable it.
>
> IMO a mount option is at the wrong granularity. A
> mount point will be shared between applications that
> can tolerate the non-POSIX behavior and those that
> cannot, for instance.

It is a better granularity than a module parameter, which was my first
approach ;-)

Yes, if we could create a control-group which avoided flush-on-stat, and
ran the problematic programs in that control group, that might be ideal
... for some values of "ideal".

You *could* mount the same filesystem in two places with nosharecache
and with only one having nosyncflush.  But you probably wouldn't.

>
> I would rather see us address the underlying cause
> of the delay, which is that the GETATTR gets starved
> by an ongoing stream of WRITE requests. You could:

I don't think starving is the issue.
Of the two specific cases that I have seen,
in one the issue was that the dirty_ratio multiplied by the amount of
memory, divided by the throughput to the server, resulted in many
minutes to flush out all the dirty data.  Having "ls -l" wait for that
flush was quite inconvenient. (We asked the customer to tune dirty_ratio
way down).

In the other (more recent) case the file being written was some sort of
data-base being restored from a dump (or something like that).  So some
blocks (presumably indexing blocks) were being written multiple times.
When we disabled flush-on-sync the total number of bytes written went
down by about 20% (vague memory .. certainly a non-trivial amount)
because these index block were only written to the server once instead
of multiple times.  So that flush-on-stat slowed down throughput in part
by pushing more data over the wire.

>
> - Make active writers wait for the GETATTR so the
> GETATTR is not starved
>
> - Start flushing dirty pages earlier so there is
> less to flush when a stat(2) is done
>
> - Ensure that GETATTR is not also waiting for a
> COMMIT
>
> Or maybe there's some other problem?
>
> I recall nfs_getattr used to grab i_mutex to hold
> up active writers. But i_mutex is gone now. Is
> there some other mechanism that can block writers
> while the client flushes the file and handles the
> GETATTR request?

I vaguely remember when i_mutex locking was added to nfs_getattr to
avoid the starvation :-)
Today nfs_getattr() calls filemap_write_and_wait() which first triggers
writes on all dirty pages, then waits for all writeback pages.
The first stage should be fairly quick, and writes during the second
stage shouldn't slow it down.  If some process were calling fsync often
(e.g. using O_SYNC) that might starve nfs_getattr(), but I don't think
normal usage would.

I do agree that a "real" fix would be better than a mount option.
The only path to a "real" fix that I can think of is to provide some
alternate source of producing a credible mtime without flushing all the
data.
Might a SETATTR using SET_TO_SERVER_TIME be a workable way forward?

Thank for your thoughts!

NeilBrown

>
>
>> Note that this option should probably *not* be used together
>> with "nocto".  In that case, mtime could be unstable even
>> when no process has the file open.
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>> fs/nfs/inode.c                 |  3 ++-
>> fs/nfs/super.c                 | 10 ++++++++++
>> include/uapi/linux/nfs_mount.h |  6 ++++--
>> 3 files changed, 16 insertions(+), 3 deletions(-)
>>=20
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index b992d2382ffa..16629a34dd62 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -740,7 +740,8 @@ int nfs_getattr(const struct path *path, struct ksta=
t *stat,
>>=20
>> 	trace_nfs_getattr_enter(inode);
>> 	/* Flush out writes to the server in order to update c/mtime.  */
>> -	if (S_ISREG(inode->i_mode)) {
>> +	if (S_ISREG(inode->i_mode) &&
>> +	    !(NFS_SERVER(inode)->flags & NFS_MOUNT_NOSTATFLUSH)) {
>> 		err =3D filemap_write_and_wait(inode->i_mapping);
>> 		if (err)
>> 			goto out;
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index 29bacdc56f6a..2351c0be98f5 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -90,6 +90,7 @@ enum {
>> 	Opt_resvport, Opt_noresvport,
>> 	Opt_fscache, Opt_nofscache,
>> 	Opt_migration, Opt_nomigration,
>> +	Opt_statflush, Opt_nostatflush,
>>=20
>> 	/* Mount options that take integer arguments */
>> 	Opt_port,
>> @@ -151,6 +152,8 @@ static const match_table_t nfs_mount_option_tokens =
=3D {
>> 	{ Opt_nofscache, "nofsc" },
>> 	{ Opt_migration, "migration" },
>> 	{ Opt_nomigration, "nomigration" },
>> +	{ Opt_statflush, "statflush" },
>> +	{ Opt_nostatflush, "nostatflush" },
>>=20
>> 	{ Opt_port, "port=3D%s" },
>> 	{ Opt_rsize, "rsize=3D%s" },
>> @@ -637,6 +640,7 @@ static void nfs_show_mount_options(struct seq_file *=
m, struct nfs_server *nfss,
>> 		{ NFS_MOUNT_NORDIRPLUS, ",nordirplus", "" },
>> 		{ NFS_MOUNT_UNSHARED, ",nosharecache", "" },
>> 		{ NFS_MOUNT_NORESVPORT, ",noresvport", "" },
>> +		{ NFS_MOUNT_NOSTATFLUSH, ",nostatflush", "" },
>> 		{ 0, NULL, NULL }
>> 	};
>> 	const struct proc_nfs_info *nfs_infop;
>> @@ -1334,6 +1338,12 @@ static int nfs_parse_mount_options(char *raw,
>> 		case Opt_nomigration:
>> 			mnt->options &=3D ~NFS_OPTION_MIGRATION;
>> 			break;
>> +		case Opt_statflush:
>> +			mnt->flags &=3D ~NFS_MOUNT_NOSTATFLUSH;
>> +			break;
>> +		case Opt_nostatflush:
>> +			mnt->flags |=3D NFS_MOUNT_NOSTATFLUSH;
>> +			break;
>>=20
>> 		/*
>> 		 * options that take numeric values
>> diff --git a/include/uapi/linux/nfs_mount.h b/include/uapi/linux/nfs_mou=
nt.h
>> index e44e00616ab5..d7c6f809d25d 100644
>> --- a/include/uapi/linux/nfs_mount.h
>> +++ b/include/uapi/linux/nfs_mount.h
>> @@ -72,7 +72,9 @@ struct nfs_mount_data {
>> #define NFS_MOUNT_NORESVPORT		0x40000
>> #define NFS_MOUNT_LEGACY_INTERFACE	0x80000
>>=20
>> -#define NFS_MOUNT_LOCAL_FLOCK	0x100000
>> -#define NFS_MOUNT_LOCAL_FCNTL	0x200000
>> +#define NFS_MOUNT_LOCAL_FLOCK		0x100000
>> +#define NFS_MOUNT_LOCAL_FCNTL		0x200000
>> +
>> +#define NFS_MOUNT_NOSTATFLUSH		0x400000
>>=20
>> #endif
>> --=20
>> 2.14.0.rc0.dirty
>>=20
>
> --
> Chuck Lever

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlo8HswACgkQOeye3VZi
gbmttxAAi/swfvaeildz9G+oiTYdJvqEi9iTMqS+iykkqdC/NUw+nJquR9nm2G4f
rMHK0co3DxvQ9vJ+w2XlMSYxZiWc6AIinpyX0EUIgkVHS0V5Fhn+83EzgHmV6qF+
cfC8RswfEPhejDw/TbmCQaQByGz/skJbgidB5CFETgqcLir+NWo+djTcDc39mSN1
KwBCXauJGsFvGhMEcHF/Tuc3hOYpDgD73RVaPn5frIhiDFS3q8InEUemdRe4BFGT
mRipYYwBnPS8Mtnz9MTqWOMayLlVU5fPhBdFR5VFLRItu9KWqK0eXM6F0liAitAX
mGKMc7/32G683HGZKmKnAz0/Wpj0CoPcit2Qhp29DyrLZp9J1kteYQn+LDBZPDzc
JOE6cnzmr8c5BDlX7jM/LIu1aFKcsIsZOtvOHyKVn5GGshQtbB7dfD4HyOpRW1q+
tEdxLlaYb7ssJQTdQdc3wyl8kzdFdNppL8Hzz/B5ikZlWRfelRFoCPZ7uKf9dkvm
ol9baIa/zuDSPg3z09un0bMkf+ojg0RJJCMepuYbE8cxqS+03MdQc/FIcBuNJYOB
okZVbxdYKLiuMnh6I4niqyYG+54G94cXqXATRkjZJX2GZTJbOzV1RkYtcsUUGyCy
TS9s0xST2tbMRxJ5EwO893LPAEr34ahNdevxbR9R0M9lEsW+kpE=
=8YsM
-----END PGP SIGNATURE-----
--=-=-=--
