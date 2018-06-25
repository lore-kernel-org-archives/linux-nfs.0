Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51444 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752237AbeFYWEB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Jun 2018 18:04:01 -0400
Date: Mon, 25 Jun 2018 18:04:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Manjunath Patil <manjunath.b.patil@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: return ENOSPC if unable to allocate a session
 slot
Message-ID: <20180625220400.GE8293@fieldses.org>
References: <1529598933-16506-1-git-send-email-manjunath.b.patil@oracle.com>
 <1529598933-16506-2-git-send-email-manjunath.b.patil@oracle.com>
 <20180622175416.GA7119@fieldses.org>
 <20180624202615.GA31496@fieldses.org>
 <bde64edc-5684-82d7-4488-e2ebdd7018fc@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <bde64edc-5684-82d7-4488-e2ebdd7018fc@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 25, 2018 at 10:17:21AM -0700, Manjunath Patil wrote:
> Hi Bruce,
> 
> I could reproduce this issue by lowering the amount of RAM. On my
> virtual box VM with 176M MB of RAM I can reproduce this with 3
> clients.

I know how to reproduce it, I was just wondering what motivated it--were
customers hitting it (how), was it just artificial testing?

Oh well, it probably needs to be fixed regardless.

--b.

> My kernel didn't have the following fixes -
> 
>    de766e5 nfsd: give out fewer session slots as limit approaches
>    44d8660 nfsd: increase DRC cache limit
> 
> Once I apply these patches, the issue recurs with 10+ clients.
> Once the mount starts to hang due to this issue, a NFSv4.0 still succeeds.
> 
> I took the latest mainline kernel [4.18.0-rc1] and made the server
> return NFS4ERR_DELAY[nfserr_jukebox] if its unable to allocate 50
> slots[just to accelerate the issue]
> 
>    -       if (!ca->maxreqs)
>    +       if (ca->maxreqs < 50) {
>               ...
>                    return nfserr_jukebox;
> 
> Then used the same client[4.18.0-rc1] and observed that mount calls
> still hangs[indefinitely].
> Typically the client hangs here - [stack are from oracle kernel] -
> 
>    [root@OL7U5-work ~]# ps -ef | grep mount
>    root      2032  1732  0 09:49 pts/0    00:00:00 strace -tttvf -o
>    /tmp/a.out mount 10.211.47.123:/exports /NFSMNT -vvv -o retry=1
>    root      2034  2032  0 09:49 pts/0    00:00:00 mount
>    10.211.47.123:/exports /NFSMNT -vvv -o retry=1
>    root      2035  2034  0 09:49 pts/0    00:00:00 /sbin/mount.nfs
>    10.211.47.123:/exports /NFSMNT -v -o rw,retry=1
>    root      2039  1905  0 09:49 pts/1    00:00:00 grep --color=auto mount
>    [root@OL7U5-work ~]# cat /proc/2035/stack
>    [<ffffffffa05204d2>] nfs_wait_client_init_complete+0x52/0xc0 [nfs]
>    [<ffffffffa05872ed>] nfs41_discover_server_trunking+0x6d/0xb0 [nfsv4]
>    [<ffffffffa0587802>] nfs4_discover_server_trunking+0x82/0x2e0 [nfsv4]
>    [<ffffffffa058f8d6>] nfs4_init_client+0x136/0x300 [nfsv4]
>    [<ffffffffa05210bf>] nfs_get_client+0x24f/0x2f0 [nfs]
>    [<ffffffffa058eeef>] nfs4_set_client+0x9f/0xf0 [nfsv4]
>    [<ffffffffa059039e>] nfs4_create_server+0x13e/0x3b0 [nfsv4]
>    [<ffffffffa05881b2>] nfs4_remote_mount+0x32/0x60 [nfsv4]
>    [<ffffffff8121df3e>] mount_fs+0x3e/0x180
>    [<ffffffff8123a6db>] vfs_kern_mount+0x6b/0x110
>    [<ffffffffa05880d6>] nfs_do_root_mount+0x86/0xc0 [nfsv4]
>    [<ffffffffa05884c4>] nfs4_try_mount+0x44/0xc0 [nfsv4]
>    [<ffffffffa052ed6b>] nfs_fs_mount+0x4cb/0xda0 [nfs]
>    [<ffffffff8121df3e>] mount_fs+0x3e/0x180
>    [<ffffffff8123a6db>] vfs_kern_mount+0x6b/0x110
>    [<ffffffff8123d5c1>] do_mount+0x251/0xcf0
>    [<ffffffff8123e3a2>] SyS_mount+0xa2/0x110
>    [<ffffffff81751f4b>] tracesys_phase2+0x6d/0x72
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>    [root@OL7U5-work ~]# cat /proc/2034/stack
>    [<ffffffff8108c147>] do_wait+0x217/0x2a0
>    [<ffffffff8108d360>] do_wait4+0x80/0x110
>    [<ffffffff8108d40d>] SyS_wait4+0x1d/0x20
>    [<ffffffff81751f4b>] tracesys_phase2+0x6d/0x72
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>    [root@OL7U5-work ~]# cat /proc/2032/stack
>    [<ffffffff8108c147>] do_wait+0x217/0x2a0
>    [<ffffffff8108d360>] do_wait4+0x80/0x110
>    [<ffffffff8108d40d>] SyS_wait4+0x1d/0x20
>    [<ffffffff81751ddc>] system_call_fastpath+0x18/0xd6
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
> -Thanks,
> Manjunath
> On 6/24/2018 1:26 PM, J. Bruce Fields wrote:
> >By the way, could you share some more details with us about the
> >situation when you (or your customers) are actually hitting this case?
> >
> >How many clients, what kind of clients, etc.  And what version of the
> >server were you seeing the problem on?  (I'm mainly curious whether
> >de766e570413 and 44d8660d3bb0 were already applied.)
> >
> >I'm glad we're thinking about how to handle this case, but my feeling is
> >that the server is probably just being *much* too conservative about
> >these allocations, and the most important thing may be to fix that and
> >make it a lot rarer that we hit this case in the first place.
> >
> >--b.
> >--
> >To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
