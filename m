Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pl0-f67.google.com ([209.85.160.67]:45738 "EHLO
        mail-pl0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751046AbeDAVsc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Apr 2018 17:48:32 -0400
Date: Sun, 1 Apr 2018 14:48:54 -0700
From: Eric Biggers <ebiggers3@gmail.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: syzbot <syzbot+f3bd89a5ab3266b10540@syzkaller.appspotmail.com>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        syzkaller-bugs@googlegroups.com, linux-nfs@vger.kernel.org
Subject: Re: BUG: corrupted list in __dentry_kill
Message-ID: <20180401214854.GB743@sol.localdomain>
References: <001a11447acaa9eec40568bd5438@google.com>
 <20180401033519.GZ30522@ZenIV.linux.org.uk>
 <20180401200531.GA30522@ZenIV.linux.org.uk>
 <20180401210508.GA743@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180401210508.GA743@sol.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[+Cc linux-nfs]

On Sun, Apr 01, 2018 at 02:05:08PM -0700, Eric Biggers wrote:
> On Sun, Apr 01, 2018 at 09:05:31PM +0100, Al Viro wrote:
> > On Sun, Apr 01, 2018 at 04:35:19AM +0100, Al Viro wrote:
> > > On Sat, Mar 31, 2018 at 04:01:02PM -0700, syzbot wrote:
> > > > Hello,
> > > > 
> > > > syzbot hit the following crash on bpf-next commit
> > > > 7828f20e3779e4e85e55371e0e43f5006a15fb41 (Sat Mar 31 00:17:57 2018 +0000)
> > > > Merge branch 'bpf-cgroup-bind-connect'
> > > > syzbot dashboard link:
> > > > https://syzkaller.appspot.com/bug?extid=f3bd89a5ab3266b10540
> > > > 
> > > > So far this crash happened 22 times on bpf-next, upstream.
> > > > C reproducer: https://syzkaller.appspot.com/x/repro.c?id=6290970458980352
> > > > syzkaller reproducer:
> > > > https://syzkaller.appspot.com/x/repro.syz?id=6577156880596992
> > > > Raw console output:
> > > > https://syzkaller.appspot.com/x/log.txt?id=5107570603720704
> > > > Kernel config:
> > > > https://syzkaller.appspot.com/x/.config?id=5909223872832634926
> > > > compiler: gcc (GCC) 7.1.1 20170620
> > > > 
> > > > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > > > Reported-by: syzbot+f3bd89a5ab3266b10540@syzkaller.appspotmail.com
> > > > It will help syzbot understand when the bug is fixed. See footer for
> > > > details.
> > > > If you forward the report, please keep this part and the footer.
> > > > 
> > > > RBP: 00007ffd1bbb3ae0 R08: 0000000020000200 R09: 0000000300000000
> > > > R10: 0000000000000000 R11: 0000000000000246 R12: ffffffffffffffff
> > > > R13: 0000000000000003 R14: 0000000000001380 R15: 00007ffd1bbb3378
> > > > list_del corruption. prev->next should be 00000000a8104008, but was
> > > > 00000000081c6144
> > > 
> > > Lovely...  I'll look into that tomorrow morning.
> > 
> > Can't reproduce - it reproducer had been running for several hours, with
> > that kernel and that config (gcc 6.3, not 7.1, though), no oopsen...
> > 
> > If somebody can reproduce that thing, I'd appreciate having it bisected
> > a bit...
> > 
> 
> Apparently the reproducer wants to inject a fault into a specific memory
> allocation, and something is causing the memory allocations to be different.  It
> works for me in ~10 seconds after applying the below patch to the C reproducer.
> (I also did 'echo 0 | tee /sys/kernel/debug/fail*/verbose' beforehand to quiet
> all the fault injection messages.)  I'm guessing the bug is in the error
> handling in "rpc_pipefs", but not sure exactly what yet.  The last messages in
> the kernel log before the BUG() were:
> 
> [   42.965515] net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry blocklayout
> [   42.967234] net/sunrpc/rpc_pipe.c: rpc_mkpipe_dentry() failed to create pipe nfs/blocklayout (errno = -12)
> 

It's definitely an "rpc_pipefs" bug.  I've simplified the reproducer to the
following:

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mount.h>
#include <sys/stat.h>
#include <unistd.h>

int main()
{
        int fd, i;
        char buf[16];

        mkdir("mnt", 0700);
        system("echo N > /sys/kernel/debug/failslab/ignore-gfp-wait");
        system("echo 0 | tee /sys/kernel/debug/fail*/verbose");
        fd = open("/proc/thread-self/fail-nth", O_WRONLY);
        for (i = 0; ; i++) {
                write(fd, buf, sprintf(buf, "%d", i));
                mount("foo", "mnt", "rpc_pipefs", 0, NULL);
                umount("mnt");
        }
}

On Linus' tree (10b84daddbec72), the symbolized log output is:

IPVS: ftp: loaded support on port[0] = 21
IPVS: ftp: loaded support on port[0] = 21
audit: type=1325 audit(1522616460.334:4): table=filter family=3 entries=0
audit: type=1300 audit(1522616460.334:4): arch=c000003e syscall=55 success=yes exit=0 a0=3 a1=0 a2=60 a3=55f3b7fba528 items=0 ppid=3115 pid=3120 auid=0 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=ttyS0 ses=1 comm="syz_dentry_kill" exe="/root/syz_dentry_kill" subj=kernel key=(null)
audit: type=1327 audit(1522616460.334:4): proctitle="./syz_dentry_kill"
audit: type=1325 audit(1522616460.335:5): table=filter family=2 entries=0
audit: type=1300 audit(1522616460.335:5): arch=c000003e syscall=55 success=yes exit=0 a0=3 a1=0 a2=40 a3=55f3b7fbcd88 items=0 ppid=3115 pid=3120 auid=0 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=ttyS0 ses=1 comm="syz_dentry_kill" exe="/root/syz_dentry_kill" subj=kernel key=(null)
audit: type=1327 audit(1522616460.335:5): proctitle="./syz_dentry_kill"
audit: type=1325 audit(1522616460.335:6): table=nat family=2 entries=0
IPVS: ftp: loaded support on port[0] = 21
audit: type=1300 audit(1522616460.335:6): arch=c000003e syscall=55 success=yes exit=0 a0=3 a1=0 a2=40 a3=55f3b7fbd448 items=0 ppid=3115 pid=3120 auid=0 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=ttyS0 ses=1 comm="syz_dentry_kill" exe="/root/syz_dentry_kill" subj=kernel key=(null)
audit: type=1327 audit(1522616460.335:6): proctitle="./syz_dentry_kill"
audit: type=1325 audit(1522616460.336:7): table=mangle family=2 entries=0
IPVS: ftp: loaded support on port[0] = 21
IPVS: ftp: loaded support on port[0] = 21
IPVS: ftp: loaded support on port[0] = 21
IPVS: ftp: loaded support on port[0] = 21
IPVS: ftp: loaded support on port[0] = 21
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry cache
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry cache
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfsd4_cb
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry cache
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry cache
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry cache
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry cache
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfsd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfsd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfsd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfsd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfsd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry mount
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry lockd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfsd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfsd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfsd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry mount
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry mount
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfsd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry mount
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
random: crng init done
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry mount
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry mount
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfs
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfs
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfs
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfs
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfs
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry info
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory clntXX
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry gssd
net/sunrpc/rpc_pipe.c: rpc_mkpipe_dentry() failed to create pipe clntXX/gssd (errno = -12)
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry gssd
net/sunrpc/rpc_pipe.c: rpc_mkpipe_dentry() failed to create pipe clntXX/gssd (errno = -12)
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry gssd
net/sunrpc/rpc_pipe.c: rpc_mkpipe_dentry() failed to create pipe clntXX/gssd (errno = -12)
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry info
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory clntXX
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry info
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory clntXX
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry gssd
net/sunrpc/rpc_pipe.c: rpc_mkpipe_dentry() failed to create pipe clntXX/gssd (errno = -12)
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry gssd
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: rpc_mkpipe_dentry() failed to create pipe clntXX/gssd (errno = -12)
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory clntXX
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory clntXX
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry lockd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry lockd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfsd4_cb
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfsd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry lockd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfsd4_cb
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfsd4_cb
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfsd4_cb
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfsd4_cb
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry lockd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry lockd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfsd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry mount
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfsd4_cb
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry mount
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry mount
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry mount
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfs
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry mount
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfs
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry mount
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry mount
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry mount
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfs
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfs
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry mount
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry nfs
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry mount
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry mount
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry mount
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry mount
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry info
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory clntXX
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry info
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry info
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory clntXX
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry cache
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry cache
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry cache
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry info
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory clntXX
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry cache
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry cache
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory /
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory clntXX
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry clntXX
net/sunrpc/rpc_pipe.c: rpc_populate failed to populate directory gssd
net/sunrpc/rpc_pipe.c: __rpc_create_common failed to allocate inode for dentry blocklayout
net/sunrpc/rpc_pipe.c: rpc_mkpipe_dentry() failed to create pipe nfs/blocklayout (errno = -12)
list_del corruption. prev->next should be 000000002c929de0, but was 0000000065421b2c
------------[ cut here ]------------
kernel BUG at lib/list_debug.c:53!
invalid opcode: 0000 [#1] SMP KASAN
Modules linked in:
CPU: 2 PID: 5082 Comm: syz_dentry_kill Not tainted 4.16.0-rc6+ #79
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.0-20171110_100015-anatol 04/01/2014
RIP: 0010:__list_del_entry_valid+0xef/0x150 lib/rational.c:61
RSP: 0018:ffff88002851f7a0 EFLAGS: 00010282
RAX: 0000000000000054 RBX: ffff880025d11c80 RCX: 0000000000000000
RDX: 0000000000000054 RSI: 1ffff100050a3ea9 RDI: ffffed00050a3ee8
RBP: ffff88002851f7b8 R08: 1ffff100050a3e40 R09: 0000000000000000
R10: ffff88002851f778 R11: 0000000000000000 R12: ffff8800271c2de0
R13: 1ffff100050a3efd R14: ffff880025c1fc70 R15: dffffc0000000000
FS:  00007f87e8a72740(0000) GS:ffff880035900000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007ffef7017aa0 CR3: 000000002e7b8000 CR4: 00000000003406e0
Call Trace:
 __dentry_kill+0x265/0x700 fs/dcache.c:1027
 dput.part.20+0x5a0/0x830
 dput+0x1f/0x30 fs/dcache.c:852
 rcu_read_lock include/linux/rcupdate.h:631 [inline]
 net_generic include/net/netns/generic.h:44 [inline]
 rpc_fill_super+0x628/0xae0 net/sunrpc/rpc_pipe.c:942
 dget include/linux/dcache.h:327 [inline]
 mount_ns+0xc6/0x190 fs/super.c:1045
 rpc_mount+0x9e/0xd0 net/sunrpc/rpc_pipe.c:1494
 mount_fs+0x6b/0x2d0 fs/super.c:1242
 vfs_kern_mount.part.26+0xc6/0x4a0
 do_mount+0xea4/0x2bb0 fs/namespace.c:2973
 copy_mount_string fs/namespace.c:2746 [inline]
 SYSC_mount fs/namespace.c:3048 [inline]
 SyS_mount+0xab/0x120 fs/namespace.c:3035
 prepare_exit_to_usermode arch/x86/entry/common.c:191 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:265 [inline]
 do_syscall_32_irqs_on arch/x86/entry/common.c:336 [inline]
 do_syscall_64+0x283/0x940 arch/x86/entry/common.c:344
 entry_SYSCALL_64_after_hwframe+0x42/0xb7
RIP: 0033:0x7f87e8173879
RSP: 002b:00007ffef7016c38 EFLAGS: 00000246 ORIG_RAX: 00000000000000a5
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f87e8173879
RDX: 00000000200002c0 RSI: 0000000020000140 RDI: 0000000020000300
RBP: 00007ffef7017aa0 R08: 0000000020000200 R09: 000055f3b7fba520
R10: 0000000000000000 R11: 0000000000000246 R12: ffffffffffffffff
R13: 0000000000000003 R14: 00007ffef7016c8c R15: 00007ffef7016c84
Code: 4c 89 e2 48 c7 c7 80 c0 75 87 e8 d5 7e 46 fe 0f 0b 48 c7 c7 e0 c0 75 87 e8 c7 7e 46 fe 0f 0b 48 c7 c7 40 c1 75 87 e8 b9 7e 46 fe <0f> 0b 48 c7 c7 a0 c1 75 87 e8 ab 7e 46 fe 0f 0b 48 89 df 48 89 
RIP: __list_del_entry_valid+0xef/0x150 lib/rational.c:61 RSP: ffff88002851f7a0
---[ end trace f9e62e977a549c37 ]---
