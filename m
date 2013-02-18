Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:20892 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754168Ab3BRPhn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2013 10:37:43 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: More fun with unmounting ESTALE directories.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130218074105.38cf49ea@tlielax.poochiereds.net>
Date: Mon, 18 Feb 2013 10:36:52 -0500
Cc: NeilBrown <neilb@suse.de>, "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        NFS <linux-nfs@vger.kernel.org>, steved@redhat.com
Message-Id: <343C8851-62FD-448D-BFD6-5CBAB8C9DCB5@oracle.com>
References: <20130212113813.427b8e05@notabene.brown> <20130214104230.013b7f71@tlielax.poochiereds.net> <20130218132509.0ce779de@notabene.brown> <20130218074105.38cf49ea@tlielax.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 18, 2013, at 7:41 AM, Jeff Layton <jlayton@redhat.com> wrote:

> On Mon, 18 Feb 2013 13:25:09 +1100
> NeilBrown <neilb@suse.de> wrote:
> 
>> On Thu, 14 Feb 2013 10:42:30 -0500 Jeff Layton <jlayton@redhat.com> wrote:
>> 
>>> On Tue, 12 Feb 2013 11:38:13 +1100
>>> NeilBrown <neilb@suse.de> wrote:
>>> 
>>>> 
>>>> I've been exploring difficulties with unmounting stale directories and
>>>> discovered another bug.
>>>> 
>>>> If I:
>>>> 
>>>> SERVER:  mkdir /foo/bar  #and make sure it is exported
>>>> CLIENT:  mount -o vers=4 server:/foo/bar /mnt
>>>> SERVER:  rm -r /foo
>>>> CLIENT:  > /mnt/baz # gets an error of course
>>>> CLIENT:  ls -l /mnt # error again
>>>> CLIENT:  umount /mnt
>>>> 
>>>> The result of that last command is:
>>>> 
>>>> /mnt was not found in /proc/mounts
>>>> /mnt was not found in /proc/mounts
>>>> 
>>>> Strange?
>>>> 
>>>> cat /proc/mounts
>>>> 
>>>> .....
>>>> 10.0.2.2://foo/bar /mnt\040(deleted) nfs4 rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.0.2.15,minorversion=0,local_lock=none,addr=10.0.2.2 0 0
>>>> ....
>>>> 
>>>> Notice the "\040(deleted)".
>>>> 
>>>> NFS has unhashed that directory because it is obviously bad, and d_path()
>>>> notices and adds " (deleted)".
>>>> 
>>>> Now I might be able to argue that NFS shouldn't be unhashing a directory that
>>>> is a mountpoint - it certainly seems strange behaviour.
>>>> 
>>>> But I think I can more strongly argue that /proc/mounts shouldn't be showing
>>>> the mounted directory, but instead the directory that it is mounted on.
>>>> Obviously these both have the same name so it shouldn't matter ... except
>>>> that here is a case where it does.
>>>> 
>>>> I "fixed" it with
>>>> 
>>>> --- a/fs/proc_namespace.c
>>>> +++ b/fs/proc_namespace.c
>>>> @@ -93,7 +93,7 @@ static int show_vfsmnt(struct seq_file *m, struct vfsmount *mnt)
>>>> {
>>>> 	struct mount *r = real_mount(mnt);
>>>> 	int err = 0;
>>>> -	struct path mnt_path = { .dentry = mnt->mnt_root, .mnt = mnt };
>>>> +	struct path mnt_path = { .dentry = r->mnt_mountpoint, .mnt = &(r->mnt_parent)->mnt };
>>>> 	struct super_block *sb = mnt_path.dentry->d_sb;
>>>> 
>>>> 	if (sb->s_op->show_devname) {
>>>> 
>>>> though I suspect that isn't safe and needs some locking.
>>>> 
>>>> Probably both should be fixed:  NFS should not invalidate any mounted
>>>> directory, and show_vfsmnt() should report the mointpoint, not the mounted
>>>> directory.
>>>> 
>>>> I can't figure out any way to get NFS to not invalidate the mounted directory.
>>>> I think it happens in nfs_lookup_revalidate() when it calls d_drop(), but I
>>>> don't know how to tell if a given dentry is a mnt_root for any mountpoint.
>>>> 
>>>> Suggestions?  Thoughts?
>>>> 
>>>> Thanks,
>>>> NeilBrown
>>>> 
>>> 
>>> I've also been looking at some weird ESTALE problems. Here's another
>>> fun one that doesn't involve mountpoints. Assume here that we're
>>> working in the same exported directory on client and server:
>>> 
>>>    server# mkdir a
>>>    client# cd a
>>>    server# mv a a.bak
>>>    client# sleep 30  # (or whatever the dir attrcache timeout is)
>>>    client# stat .
>>>    stat: cannot stat ‘.’: Stale NFS file handle
>>> 
>>> Obviously, "." should not be stale. It got renamed, but the inode still
>>> exists on the server.
>>> 
>>> If you sniff on the wire, you'll see that the server doesn't ever send
>>> an ESTALE here. What happens is that due to FS_REVAL_DOT being set, we
>>> end up trying to revalidate the dentry that "." refers to. We find that
>>> the parent changed (obviously) and then try to redo the lookup of "a".
>>> At that point we notice that it doesn't exist and turn it into ESTALE.
>>> 
>>> I don't really understand the point of FS_REVAL_DOT. What does that
>>> actually buy us? I wonder if removing it would also help your testcase?
>>> 
>> 
>> I think that is a slightly different issue, but certainly related. 
>> I have hit your problem before and have the following patch in SLES.  I think
>> I tried pushing it upstream, but didn't get much in the way of a useful
>> response.
>> (patch is space-damaged - don't try to apply with 'patch').
>> 
>> BTW I have another problem, related to this one and which could be fixed by
>> removing FS_REVAL_DOT.
>> 
>> If you
>>   mount -o vers=4,noac server:/some/path /mnt
>> then stop nfsd on the server and
>>   umount /mnt
>> 
>> it hangs.
>> Partly it hangs because  'mount' tries to do a 'readlink' on the mountpoint.
>> I can probably get it to not do that (or use --no-canonicalize).
>> But then sys_umount hangs because it tries to check with the server that the
>> thing being unmounted really is still a directory...
>> 
>> I would be really nice if sys_unmount used a LOOKUP_MOUNTPOINT flag that
>> works a bit like LOOKUP_PARENT and LOOKUP_NOFOLLOW in that it skips the very
>> last step and returns the mounted-on directory, not the mountpoint that is
>> mounted there - or at least makes sure not revalidate happens on that final
>> mounted directory.
>> 
>> 
>> I think FS_REVAL_DOT is needed so that if you call stat("."), it will update
>> attributes from the server if the cache is old.  However it seems to do a
>> whole lot more than that, including "lookup" calls which it I'm sure is wrong.
>> 
>> 
>> 
>> Subject: [PATCH] nfs - handle d_revalidate of 'dot' correctly.
>> 
>> When d_revalidate is called on a dentry because FS_REVAL_DOT is set
>> it isn't really appropriate to revalidate the name.
>> 
>> If the path was simply ".", then the current-working-directory could
>> have been renamed on the server and should still be accessible as "."
>> even if it has a new name.
>> 
>> If the path was "/some/long/path/.", then the final component ("path" in
>> this case) has already been revalidated and there is no particular
>> need to do it again.
>> 
>> If we change nd->last_type to refer to "the last component looked at"
>> rather than just "the last component", then these cases can be
>> detected by "nd->last_type != LAST_NORM".
>> 
>> Signed-off-by: NeilBrown <neilb@suse.de>
>> 
>> ---
>> fs/namei.c   |    2 +-
>> fs/nfs/dir.c |    9 +++++++++
>> 2 files changed, 10 insertions(+), 1 deletion(-)
>> 
>> --- linux-3.0-SLE11-SP2.orig/fs/namei.c
>> +++ linux-3.0-SLE11-SP2/fs/namei.c
>> @@ -1460,6 +1460,7 @@ static int link_path_walk(const char *na
>>                        }
>>                }
>> 
>> +               nd->last_type = type;
>>                /* remove trailing slashes? */
>>                if (!c)
>>                        goto last_component;
>> @@ -1486,7 +1487,6 @@ last_component:
>>                /* Clear LOOKUP_CONTINUE iff it was previously unset */
>>                nd->flags &= lookup_flags | ~LOOKUP_CONTINUE;
>>                nd->last = this;
>> -               nd->last_type = type;
>>                return 0;
>>        }
>>        terminate_walk(nd);
>> --- linux-3.0-SLE11-SP2.orig/fs/nfs/dir.c
>> +++ linux-3.0-SLE11-SP2/fs/nfs/dir.c
>> @@ -1138,6 +1138,15 @@ static int nfs_lookup_revalidate(struct
>>        if (NFS_STALE(inode))
>>                goto out_bad;
>> 
>> +       if (nd->last_type != LAST_NORM) {
>> +               /* name not relevant, just inode */
>> +               error = nfs_revalidate_inode(NFS_SERVER(inode), inode);
>> +               if (error)
>> +                       goto out_bad;
>> +               else
>> +                       goto out_valid;
>> +       }
>> +
>>        error = -ENOMEM;
>>        fhandle = nfs_alloc_fhandle();
>>        fattr = nfs_alloc_fattr();
> 
> Ahh thanks -- that is the same problem exactly. I'll have to look over
> your patch and see whether and how it could be applied to current
> mainline code.
> 
> I think the umount thing may be the same problem that steved was
> talking about the other day (V4 unmount causes a GETATTR). I hadn't put
> the two together, but you're probably right.
> 
> LOOKUP_MOUNTPOINT is a very interesting idea and might even be
> reasonable in conjunction with removing FS_REVAL_DOT as it would make
> the needs of umount more explicit.
> 
> As far as FS_REVAL_DOT goes though, in the current mainline code, the
> only place that looks at it is complete_walk(), and it just means that
> we won't skip doing a d_revalidate on the final component (which will
> only have not been done if it's a '.', right?).
> 
> If we remove FS_REVAL_DOT altogether, then we can chop off the bottom
> half of that function, which has a certain appeal. I guess the question
> we have to answer is -- if we remove FS_REVAL_DOT, what (if anything)
> will break?

Before removing FS_REVAL_DOT, I recommend some archaeology:  find out what was fixed by adding that for NFS.  I worked on something related years ago and have a vague recollection about this that there is a situation where revalidating dot is important.

Unfortunately I don't see it in a quick browse through the commit log for fs/nfs/dir.c.  It may be in BitKeeper.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




