Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:38386 "EHLO fiona.linuxhacker.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752263AbcITBpD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Sep 2016 21:45:03 -0400
Subject: Revalidate failure leads to unmount (was: Mountpoints disappearing from namespace unexpectedly.)
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <37A073FB-726E-4AF8-BC61-0DFBA6C51BD7@linuxhacker.ru>
Date: Mon, 19 Sep 2016 21:44:48 -0400
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Message-Id: <CA893F6B-6EC3-477C-B20B-0E74CAFEA53C@linuxhacker.ru>
References: <37A073FB-726E-4AF8-BC61-0DFBA6C51BD7@linuxhacker.ru>
To: Al Viro <viro@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello!

   I think I have found an interesting condition for filesystems that have a
   revalidate op and I am not quite sure this is really what we want?

   Basically it all started with mountpoints randomly getting unmounted during
   testing that I could not quite explain (see my quoted message at the end).

   Now I finally caught the culprit and it's lookup_dcache calling d_invalidate
   that in turn detaches all mountpoints on the entire subtree like this:

Breakpoint 1, umount_tree (mnt=<optimized out>, how=<optimized out>)
    at /home/green/bk/linux-test/fs/namespace.c:1441
1441                                    umount_mnt(p);
(gdb) bt
#0  umount_tree (mnt=<optimized out>, how=<optimized out>)
    at /home/green/bk/linux-test/fs/namespace.c:1441
#1  0xffffffff8129ec82 in __detach_mounts (dentry=<optimized out>)
    at /home/green/bk/linux-test/fs/namespace.c:1572
#2  0xffffffff8129359e in detach_mounts (dentry=<optimized out>)
    at /home/green/bk/linux-test/fs/mount.h:100
#3  d_invalidate (dentry=0xffff8800ab38feb0)
    at /home/green/bk/linux-test/fs/dcache.c:1534
#4  0xffffffff8128122c in lookup_dcache (name=<optimized out>,
    dir=<optimized out>, flags=1536)
    at /home/green/bk/linux-test/fs/namei.c:1485
#5  0xffffffff81281d92 in __lookup_hash (name=0xffff88005c1a3eb8, 
    base=0xffff8800a8609eb0, flags=1536)
    at /home/green/bk/linux-test/fs/namei.c:1522
#6  0xffffffff81288196 in filename_create (dfd=<optimized out>, 
    name=0xffff88006d3e7000, path=0xffff88005c1a3f08, 
    lookup_flags=<optimized out>) at /home/green/bk/linux-test/fs/namei.c:3604
#7  0xffffffff812891f1 in user_path_create (lookup_flags=<optimized out>, 
    path=<optimized out>, pathname=<optimized out>, dfd=<optimized out>)
    at /home/green/bk/linux-test/fs/namei.c:3661
#8  SYSC_mkdirat (mode=511, pathname=<optimized out>, dfd=<optimized out>)
    at /home/green/bk/linux-test/fs/namei.c:3793
#9  SyS_mkdirat (mode=<optimized out>, pathname=<optimized out>,
    dfd=<optimized out>) at /home/green/bk/linux-test/fs/namei.c:3785
#10 SYSC_mkdir (mode=<optimized out>, pathname=<optimized out>)
    at /home/green/bk/linux-test/fs/namei.c:3812
#11 SyS_mkdir (pathname=-2115143072, mode=<optimized out>)
    at /home/green/bk/linux-test/fs/namei.c:3810
#12 0xffffffff8189f03c in entry_SYSCALL_64_fastpath ()
    at /home/green/bk/linux-test/arch/x86/entry/entry_64.S:207

   While I imagine the original idea was "cannot revalidate? Nuke the whole
   tree from orbit", cases for "Why cannot we revalidate" were not considered.
   In my case it appears that killing a bunch of scripts just at the right time
   as they are in the middle of revalidating of some path component that has
   mountpoints below it, the whole thing gets nuked (somewhat) unexpectedly because
   nfs/sunrpc code notices the signal and returns ERESTARTSYS in the middle of lookup.
   (This could be even exploitable in some setups I imagine, since it allows an
   unprivileged user to unmount anything mounted on top of nfs).

   It's even worse for Lustre, for example, because Lustre never tries to actually
   re-lookup anything anymore (because that brought a bunch of complexities around
   so we were glad we could get rid of it) and just returns whenever the name is
   valid or not hoping for a retry the next time around.

   So this brings up the question:
   Is revalidate really required to go to great lengths to avoid returning 0
   unless the underlying name has really-really changed? My reading
   of documentation does not seem to match this as the whole LOOKUP_REVAL logic
   is then redundant more or less?

   Or is totally nuking the whole underlying tree a little bit over the top and
   could be replaced with something less drastic, after all following re-lookup
   could restore the dentries, but unmounts are not really reversible.

   Thanks.

Bye,
    Oleg
On Sep 5, 2016, at 12:45 PM, Oleg Drokin wrote:

> Hello!
> 
>   I am seeing a strange phenomenon here that I have not been able to completely figure
>   out and perhaps it might ring some bells for somebody else.
> 
>   I first noticed this in 4.6-rc testing in early June, but just hit it in a similar
>   way in 4.8-rc5
> 
>   Basically I have a test script that does a bunch of stuff in a limited namespace
>   in three related namespaced (backend is the same, mountpoints are separate).
> 
>   When a process (a process group or something) is killed, sometimes ones of the
>   mountpoints disappears from the namespace completely, even though the scripts
>   themselves do not unmount anything.
> 
>   No traces of the mountpoint anywhere in /proc (including /proc/*/mounts), so it's not
>   in any private namespaces of any of the processes either it seems.
> 
>   The filesystems are a locally mounted ext4 (loopback-backed) + 2 nfs
>   (of the ext4 reexported).
>   In the past it was always ext4 that was dropping, but today I got one of the nfs
>   ones.
> 
>   Sequence looks like this:
> + mount /tmp/loop /mnt/lustre -o loop
> + mkdir /mnt/lustre/racer
> mkdir: cannot create directory '/mnt/lustre/racer': File exists
> + service nfs-server start
> Redirecting to /bin/systemctl start  nfs-server.service
> + mount localhost:/mnt/lustre /mnt/nfs -t nfs -o nolock
> + mount localhost:/ /mnt/nfs2 -t nfs4
> + DURATION=3600
> + sh racer.sh /mnt/nfs/racer
> + DURATION=3600
> + sh racer.sh /mnt/nfs2/racer
> + wait %1 %2 %3
> + DURATION=3600
> + sh racer.sh /mnt/lustre/racer
> Running racer.sh for 3600 seconds. CTRL-C to exit
> Running racer.sh for 3600 seconds. CTRL-C to exit
> Running racer.sh for 3600 seconds. CTRL-C to exit
> ./file_exec.sh: line 12: 216042 Bus error               $DIR/$file 0.$((RANDOM % 5 + 1)) 2> /dev/null
> ./file_exec.sh: line 12: 229086 Segmentation fault      (core dumped) $DIR/$file 0.$((RANDOM % 5 + 1)) 2> /dev/null
> ./file_exec.sh: line 12: 230134 Segmentation fault      $DIR/$file 0.$((RANDOM % 5 + 1)) 2> /dev/null
> ./file_exec.sh: line 12: 235154 Segmentation fault      (core dumped) $DIR/$file 0.$((RANDOM % 5 + 1)) 2> /dev/null
> ./file_exec.sh: line 12: 270951 Segmentation fault      (core dumped) $DIR/$file 0.$((RANDOM % 5 + 1)) 2> /dev/null
> racer cleanup
> racer cleanup
> racer cleanup
> sleeping 5 sec ...
> sleeping 5 sec ...
> sleeping 5 sec ...
> file_create.sh: no process found
> file_create.sh: no process found
> dir_create.sh: no process found
> file_create.sh: no process found
> dir_create.sh: no process found
> file_rm.sh: no process found
> dir_create.sh: no process found
> file_rm.sh: no process found
> file_rename.sh: no process found
> file_rm.sh: no process found
> file_rename.sh: no process found
> file_link.sh: no process found
> file_rename.sh: no process found
> file_link.sh: no process found
> file_symlink.sh: no process found
> file_link.sh: no process found
> file_symlink.sh: no process found
> file_list.sh: no process found
> file_list.sh: no process found
> file_symlink.sh: no process found
> file_concat.sh: no process found
> file_concat.sh: no process found
> file_list.sh: no process found
> file_exec.sh: no process found
> file_concat.sh: no process found
> file_exec.sh: no process found
> file_chown.sh: no process found
> file_exec.sh: no process found
> file_chown.sh: no process found
> file_chmod.sh: no process found
> file_chown.sh: no process found
> file_chmod.sh: no process found
> file_mknod.sh: no process found
> file_chmod.sh: no process found
> file_mknod.sh: no process found
> file_truncate.sh: no process found
> file_mknod.sh: no process found
> file_delxattr.sh: no process found
> file_truncate.sh: no process found
> file_truncate.sh: no process found
> file_getxattr.sh: no process found
> file_delxattr.sh: no process found
> file_delxattr.sh: no process found
> file_setxattr.sh: no process found
> there should be NO racer processes:
> file_getxattr.sh: no process found
> file_getxattr.sh: no process found
> file_setxattr.sh: no process found
> there should be NO racer processes:
> file_setxattr.sh: no process found
> there should be NO racer processes:
> USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
> USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
> USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
> df: /mnt/nfs/racer: No such file or directory
> Filesystem     1K-blocks  Used Available Use% Mounted on
> /dev/loop0        999320 46376    884132   5% /mnt/lustre
> We survived racer.sh for 3600 seconds.
> Filesystem     1K-blocks  Used Available Use% Mounted on
> localhost:/       999424 46080    884224   5% /mnt/nfs2
> We survived racer.sh for 3600 seconds.
> + umount /mnt/nfs
> umount: /mnt/nfs: not mounted
> + exit 5
> 
>  Now you see in the middle of that /mnt/nfs suddenly disappeared.
> 
>  The racer scripts are at
>  http://git.whamcloud.com/fs/lustre-release.git/tree/refs/heads/master:/lustre/tests/racer
>  There's absolutely no unmounts in there.
> 
>  In the past I was just able to do the three racers in parallel, wait ~10 minutes and
>  then kill all three of them and with significant probability the ext4 mountpoint would
>  disappear.
> 
>  Any idea on how to better pinpoint this?
> 
>  Thanks.
> 
> Bye,
>    Oleg

