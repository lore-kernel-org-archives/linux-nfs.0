Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56424 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751055AbdHRGz6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Aug 2017 02:55:58 -0400
Subject: Re: Do we really need d_weak_revalidate???
From: Ian Kent <ikent@redhat.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mkoutny@suse.com" <mkoutny@suse.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        David Howells <dhowells@redhat.com>
References: <87bmnmrai9.fsf@notabene.neil.brown.name>
 <1502430944.3822.1.camel@primarydata.com>
 <1502449309.4950.2.camel@redhat.com>
 <87zib3niqn.fsf@notabene.neil.brown.name>
 <1502705432.4978.1.camel@redhat.com>
 <877ey4nsep.fsf@notabene.neil.brown.name>
 <1502883253.4847.6.camel@redhat.com>
 <1e4665a6-30d6-c16a-760a-2892fb147760@redhat.com>
 <878tihmora.fsf@notabene.neil.brown.name>
 <2e289bba-677b-cc50-5fa3-2d24d1f6b858@redhat.com>
Message-ID: <80b7064d-b0b6-b4bd-eeb2-8d3fb6f0ad63@redhat.com>
Date: Fri, 18 Aug 2017 14:55:50 +0800
MIME-Version: 1.0
In-Reply-To: <2e289bba-677b-cc50-5fa3-2d24d1f6b858@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 18/08/17 14:47, Ian Kent wrote:
> On 18/08/17 13:24, NeilBrown wrote:
>> On Thu, Aug 17 2017, Ian Kent wrote:
>>
>>> On 16/08/17 19:34, Jeff Layton wrote:
>>>> On Wed, 2017-08-16 at 12:43 +1000, NeilBrown wrote:
>>>>> On Mon, Aug 14 2017, Jeff Layton wrote:
>>>>>
>>>>>> On Mon, 2017-08-14 at 09:36 +1000, NeilBrown wrote:
>>>>>>> On Fri, Aug 11 2017, Jeff Layton wrote:
>>>>>>>
>>>>>>>> On Fri, 2017-08-11 at 05:55 +0000, Trond Myklebust wrote:
>>>>>>>>> On Fri, 2017-08-11 at 14:31 +1000, NeilBrown wrote:
>>>>>>>>>> Funny story.  4.5 years ago we discarded the FS_REVAL_DOT superblock
>>>>>>>>>> flag and introduced the d_weak_revalidate dentry operation instead.
>>>>>>>>>> We duly removed the flag from NFS superblocks and NFSv4 superblocks,
>>>>>>>>>> and added the new dentry operation to NFS dentries .... but not to
>>>>>>>>>> NFSv4
>>>>>>>>>> dentries.
>>>>>>>>>>
>>>>>>>>>> And nobody noticed.
>>>>>>>>>>
>>>>>>>>>> Until today.
>>>>>>>>>>
>>>>>>>>>> A customer reports a situation where mount(....,MS_REMOUNT,..) on an
>>>>>>>>>> NFS
>>>>>>>>>> filesystem hangs because the network has been deconfigured.  This
>>>>>>>>>> makes
>>>>>>>>>> perfect sense and I suggested a code change to fix the problem.
>>>>>>>>>> However when a colleague was trying to reproduce the problem to
>>>>>>>>>> validate
>>>>>>>>>> the fix, he couldn't.  Then nor could I.
>>>>>>>>>>
>>>>>>>>>> The problem is trivially reproducible with NFSv3, and not at all with
>>>>>>>>>> NFSv4.  The reason is the missing d_weak_revalidate.
>>>>>>>>>>
>>>>>>>>>> We could simply add d_weak_revalidate for NFSv4, but given that it
>>>>>>>>>> has been missing for 4.5 years, and the only time anyone noticed was
>>>>>>>>>> when the ommission resulted in a better user experience, I do wonder
>>>>>>>>>> if
>>>>>>>>>> we need to.  Can we just discard d_weak_revalidate?  What purpose
>>>>>>>>>> does
>>>>>>>>>> it serve?  I couldn't find one.
>>>>>>>>>>
>>>>>>>>>> Thanks,
>>>>>>>>>> NeilBrown
>>>>>>>>>>
>>>>>>>>>> For reference, see
>>>>>>>>>> Commit: ecf3d1f1aa74 ("vfs: kill FS_REVAL_DOT by adding a
>>>>>>>>>> d_weak_revalidate dentry op")
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>> To reproduce the problem at home, on a system that uses systemd:
>>>>>>>>>> 1/ place (or find) a filesystem image in a file on an NFS filesystem.
>>>>>>>>>> 2/ mount the nfs filesystem with "noac" - choose v3 or v4
>>>>>>>>>> 3/ loop-mount the filesystem image read-only somewhere
>>>>>>>>>> 4/ reboot
>>>>>>>>>>
>>>>>>>>>> If you choose v4, the reboot will succeed, possibly after a 90second
>>>>>>>>>> timeout.
>>>>>>>>>> If you choose v3, the reboot will hang indefinitely in systemd-
>>>>>>>>>> shutdown while
>>>>>>>>>> remounting the nfs filesystem read-only.
>>>>>>>>>>
>>>>>>>>>> If you don't use "noac" it can still hang, but only if something
>>>>>>>>>> slows
>>>>>>>>>> down the reboot enough that attributes have timed out by the time
>>>>>>>>>> that
>>>>>>>>>> systemd-shutdown runs.  This happens for our customer.
>>>>>>>>>>
>>>>>>>>>> If the loop-mounted filesystem is not read-only, you get other
>>>>>>>>>> problems.
>>>>>>>>>>
>>>>>>>>>> We really want systemd to figure out that the loop-mount needs to be
>>>>>>>>>> unmounted first.  I have ideas concerning that, but it is messy.  But
>>>>>>>>>> that isn't the only bug here.
>>>>>>>>>
>>>>>>>>> The main purpose of d_weak_revalidate() was to catch the issues that
>>>>>>>>> arise when someone changes the contents of the current working
>>>>>>>>> directory or its parent on the server. Since '.' and '..' are treated
>>>>>>>>> specially in the lookup code, they would not be revalidated without
>>>>>>>>> special treatment. That leads to issues when looking up files as
>>>>>>>>> ./<filename> or ../<filename>, since the client won't detect that its
>>>>>>>>> dcache is stale until it tries to use the cached dentry+inode.
>>>>>>>>>
>>>>>>>>> The one thing that has changed since its introduction is, I believe,
>>>>>>>>> the ESTALE handling in the VFS layer. That might fix a lot of the
>>>>>>>>> dcache lookup bugs that were previously handled by d_weak_revalidate().
>>>>>>>>> I haven't done an audit to figure out if it actually can handle all of
>>>>>>>>> them.
>>>>>>>>>
>>>>>>>>
>>>>>>>> It may also be related to 8033426e6bdb2690d302872ac1e1fadaec1a5581:
>>>>>>>>
>>>>>>>>     vfs: allow umount to handle mountpoints without revalidating them
>>>>>>>
>>>>>>> You say in the comment for that commit:
>>>>>>>
>>>>>>>      but there
>>>>>>>     are cases where we do want to revalidate the root of the fs.
>>>>>>>
>>>>>>> Do you happen to remember what those cases are?
>>>>>>>
>>>>>>
>>>>>> Not exactly, but I _think_ I might have been assuming that we needed to
>>>>>> ensure that the inode attrs on the root were up to date after the
>>>>>> pathwalk.
>>>>>>
>>>>>> I think that was probably wrong. d_revalidate is really intended to
>>>>>> ensure that the dentry in question still points to the same inode. In
>>>>>> the case of the root of the mount though, we don't really care about the
>>>>>> dentry on the server at all. We're attaching the root of the mount to an
>>>>>> inode and don't care of the dentry name changes. If we do need to ensure
>>>>>> the inode attrs are updated, we'll just revalidate them at that point.
>>>>>>
>>>>>>>>
>>>>>>>> Possibly the fact that we no longer try to revalidate during unmount
>>>>>>>> means that this is no longer necessary?
>>>>>>>>
>>>>>>>> The original patch that added d_weak_revalidate had a reproducer in the
>>>>>>>> patch description. Have you verified that that problem is still not
>>>>>>>> reproducible when you remove d_weak_revalidate?
>>>>>>>
>>>>>>> I did try the reproducer and it works as expected both with and without
>>>>>>> d_weak_revalidate.
>>>>>>> On reflection, the problem it displayed was caused by d_revalidate()
>>>>>>> being called when the dentry name was irrelevant.  We remove that
>>>>>>> (fixing the problem) and introduce d_weak_revalidate because we thought
>>>>>>> that minimum functionality was still useful.  I'm currently not
>>>>>>> convinced that even that is needed.
>>>>>>>
>>>>>>> If we discarded d_weak_revalidate(), we could get rid of the special
>>>>>>> handling of umount....
>>>>>>
>>>>>> I like idea. I say go for it and we can see what (if anything) breaks?
>>>>>
>>>>> Getting rid of d_weak_revalidate is easy enough - hardly any users.
>>>>>
>>>>> Getting rid of filename_mountpoint() isn't so easy unfortunately.
>>>>> autofs4 uses kern_path_mountpoint() - presumably to avoid getting stuck
>>>>> in autofs4_d_manage()?  It would be a shame to keep this infrastructure
>>>>> around just so that one part of autofs4 can talk to another part of
>>>>> autofs4.
>>>
>>> When this was first implemented autofs didn't use kern_path_mountpoint()
>>> (it didn't exist) it used a path lookup on the parent and a separate
>>> lookup for the last component.
>>
>> This was before commit 4e44b6852e03 ("Get rid of path_lookup in
>> autofs4").  This used kern_path().
> 
> I have to plead not guilty of this one.
> 
> IIRC it broke the requirement of "lookup parent then lookup last component"
> rather it walked the whole path then followed up to find the mount point
> struct path.
> 
> Like it says in the description of ac8387199656 the caller might not yet
> "own" the autofs mount which causes a mount to be triggered during the
> walk that can't be satisfied because of the deadlock that occurs.

Also, 4e44b6852e03 fixed another mistake I had made with:

-               if (nd.path.mnt->mnt_mountpoint != nd.path.mnt->mnt_root) {
-                       if (follow_down(&nd.path.mnt, &nd.path.dentry)) {
-                               struct inode *inode = nd.path.dentry->d_inode;
-                               magic = inode->i_sb->s_magic;
-                       }
+               if (path.mnt->mnt_mountpoint != path.mnt->mnt_root) {
+                       if (follow_down(&path.mnt, &path.dentry))
+                               magic = path.mnt->mnt_sb->s_magic;
                }

> 
>>
>> I'm more interested in commit ac8387199656 ("autofs4 - fix device ioctl
>> mount lookup")  which replaced the use of kern_path() with
>> kern_path_mountpoint().
> 
> Probably should have had a Fixes: 4e44b6852e03 ...
> 
>>
>>>
>>> It's used for two operations, first to open a file handle to a (possibly)
>>> covered autofs mount, and second to get mounted information about a path
>>> without following past a (possibly covered) autofs mount.
>>>
>>> It's less about not triggering an automount or getting stuck in ->d_manage()
>>> and more about resolving paths that are not accessible via normal vfs walks.
>>>
>>> I never thought about re-validation for either of these cases and altering
>>> it to the way it was before filename_mountpoint() shouldn't be a
>>> problem.
>>
>> If it shouldn't be a problem, what justified ac8387199656??
>>
>> Thanks,
>> NeilBrown
>>
> 

