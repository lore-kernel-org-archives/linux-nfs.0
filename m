Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:23450 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964885Ab3BNPja convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2013 10:39:30 -0500
Content-Type: text/plain; charset=iso-8859-1
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: Kernels 3.7 and newer break rpc.gssd -n
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1117889154.119108.1360851840169.JavaMail.root@opinsys.fi>
Date: Thu, 14 Feb 2013 10:39:23 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <CED6E6AF-B551-4099-89CE-861E5F46D31A@oracle.com>
References: <127351146.98508.1360769367943.JavaMail.root@opinsys.fi> <1117889154.119108.1360851840169.JavaMail.root@opinsys.fi>
To: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 14, 2013, at 9:24 AM, Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:

> 
>> I've been using kerberized nfs4 mounts without machine credentials for
>> quite some time by running rpc.gssd with the -n option. This has
>> resulted rpc.gssd in using ccache in /tmp/krb5cc_0 when doing the mount
>> instead of machine credentials. This functionality seems to break when
>> using kernel 3.7 or newer. 3.6.11 and earlier work like expected.
>> 
>> The use case for this is diskless workstations that do not have machine
>> credentials stored on them as they have no secure storage medium. When a
>> user logs in, the home directory is mounted using the user's credentials
>> only.
>> 
>> Steps to reproduce the problem:
>> 
>> # kinit user (this creates /tmp/krb5cc_0)
>> # rpc.gssd -f -n -vvvv
>> # mount -t nfs4 -o sec=krb5 server.example.org:/home /mnt
>> 
>> The mount works when using kernel 3.6.11 or earlier and fails on 3.7-rc1
>> or later. Testing was done on Ubuntu 12.04 and 12.10 using Ubuntu kernels
>> and kernel.org kernels (up to 3.8-rc7) with similar results.
>> 
>> nfs-utils versions 1.2.5 and the latest version from git master head
>> (git://linux-nfs.org/nfs-utils) behave the same way.
> 
> ...
> 
>> It seems like the kernel now asks rpc.gssd to fetch credentials for
>> service '*' instead of NULL like with 3.6 and earlier.
> 
> I got some bisecting help from Tuomas Räsänen who managed to find the 
> commit that introduces the change. Here's what he found. I haven't 
> yet figured out what in the commit causes the change in behaviour. 
> Before that patch the kernel asks rpc.gssd for service <null>, but 
> with the patch applied, it requests for service '*' when doing the 
> initial mount with sec=krb5.

Have you tried a kernel at commit 05f4c350 but with the compilation fix applied, then one with 05f4c350 removed, to confirm that this indeed is the commit that introduces the problem?

When the mount operation fails, is it the first time this client attempts to mount a share on server.example.org, or does the client already have mounts of server.example.org, possibly using other security flavors?

I will attempt to reproduce this.

> Veli-Matti
> 
> --------------------------------------------------------------
> 
> I bisected between v3.6 (good) and v3.7-rc1 (bad) and it seems
> that the first commit which introduces the change Veli-Matti
> described in his mail is:
> 
>  commit 05f4c350ee02e9461c6ae3a880ea326a06835e37
>  Author: Chuck Lever <chuck.lever@oracle.com>
>  Date:   Fri Sep 14 17:24:32 2012 -0400
> 
>      NFS: Discover NFSv4 server trunking when mounting
> 
> That very same commit introduces also a compilation error, which is
> fixed in the merge commit a bit later in the tree
> (9f62387d6e26532bcbfb15606956074192ee526a). Therefore the bisect log
> below results in multiple skips. I picked the patch from
> 9f62387d6e26532bcbfb15606956074192ee526a and applied it to
> 05f4c350ee02e9461c6ae3a880ea326a06835e37, and then bisected the rest.
> 
> git bisect start
> # bad: [ddffeb8c4d0331609ef2581d84de4d763607bd37] Linux 3.7-rc1
> git bisect bad ddffeb8c4d0331609ef2581d84de4d763607bd37
> # good: [a0d271cbfed1dd50278c6b06bead3d00ba0a88f9] Linux 3.6
> git bisect good a0d271cbfed1dd50278c6b06bead3d00ba0a88f9
> # good: [24d7b40a60cf19008334bcbcbd98da374d4d9c64] ARM: OMAP2+: PM: MPU DVFS: use generic CPU device for MPU-SS
> git bisect good 24d7b40a60cf19008334bcbcbd98da374d4d9c64
> # good: [21c8715f0a1f4df8bfa2bd6f3915e5e33c1c2e6e] ARM: integrator: use __iomem pointers for MMIO, part 2
> git bisect good 21c8715f0a1f4df8bfa2bd6f3915e5e33c1c2e6e
> # good: [23d5385f382a7c7d8b6bf19b0c2cfb3acbb12d31] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc
> git bisect good 23d5385f382a7c7d8b6bf19b0c2cfb3acbb12d31
> # bad: [35e9a274fdc9c8feb763e4970a32d7089f51393c] Merge branch 'kconfig' of git://git.kernel.org/pub/scm/linux/kernel/git/mmarek/kbuild
> git bisect bad 35e9a274fdc9c8feb763e4970a32d7089f51393c
> # bad: [ba0a5a36f60e4c1152af3a2ae2813251974405bf] Merge tag 'firewire-fix' of git://git.kernel.org/pub/scm/linux/kernel/git/ieee1394/linux1394
> git bisect bad ba0a5a36f60e4c1152af3a2ae2813251974405bf
> # good: [a188e7e93a36627fb3f0013f41857ab54f076d04] Merge branch 'for-next' of git://git.kernel.org/pub/scm/linux/kernel/git/nab/target-pending
> git bisect good a188e7e93a36627fb3f0013f41857ab54f076d04
> # bad: [ca57ccc48f6a9a3ec655f87acebab82bf01088e7] nfs: include NFSv4 header in netns.h
> git bisect bad ca57ccc48f6a9a3ec655f87acebab82bf01088e7
> # skip: [fcb6d9c6b719b633e9b98d26d8a7937209e8bf21] NFS: Always use the open stateid when checking for expired opens
> git bisect skip fcb6d9c6b719b633e9b98d26d8a7937209e8bf21
> # skip: [78e4e05c643768af170e5a4b21712d9a7a26cce5] NFSv4.1: Replace get_device_info() with filelayout_get_device_info()
> git bisect skip 78e4e05c643768af170e5a4b21712d9a7a26cce5
> # skip: [c8ceb4124b53a439edfe3fe89a646be1e067ef17] NFS: pass net to nfs_callback_down()
> git bisect skip c8ceb4124b53a439edfe3fe89a646be1e067ef17
> # skip: [e984a55a7418f777407c7edbb2bdf5eb9559b5e2] NFS: Use the same nfs_client_id4 for every server
> git bisect skip e984a55a7418f777407c7edbb2bdf5eb9559b5e2
> # skip: [65857d5768f7716da539933c2075d384b117812d] NFSv4.1: _pnfs_return_layout() shouldn't invalidate the layout on failure
> git bisect skip 65857d5768f7716da539933c2075d384b117812d
> # good: [896526174ce2b6a773e187ebe5a047b68230e2c4] NFS: Introduce "migration" mount option
> git bisect good 896526174ce2b6a773e187ebe5a047b68230e2c4
> # skip: [4e266229dbb0782d91b75633322edd632794b86d] pnfsblock: use list_move_tail instead of list_del/list_add_tail
> git bisect skip 4e266229dbb0782d91b75633322edd632794b86d
> # skip: [758201e2c94b7d26ea0ac64e55cab1d53742780a] NFSv4: Fix the minor version callback channel startup
> git bisect skip 758201e2c94b7d26ea0ac64e55cab1d53742780a
> # skip: [7297cb682acb506ada2e01fbc9b447b04d69936c] nfs: replace strict_strto* with kstrto*
> git bisect skip 7297cb682acb506ada2e01fbc9b447b04d69936c
> # skip: [6f2ea7f2a3ff3cd342bface43f8b4bf5e431cf36] NFS: Add nfs4_unique_id boot parameter
> git bisect skip 6f2ea7f2a3ff3cd342bface43f8b4bf5e431cf36
> # skip: [96c9eae638765c2bf2ca4f5a6325484f9bb69aa7] pnfsblock: fix non-aligned DIO write
> git bisect skip 96c9eae638765c2bf2ca4f5a6325484f9bb69aa7
> # good: [0cac120233305b614cfe3ad419f3655876066017] NFSv4: Ensure that idmap_pipe_downcall sanity-checks the downcall data
> git bisect good 0cac120233305b614cfe3ad419f3655876066017
> # skip: [f742dc4a32587bff50b13dde9d8894b96851951a] pnfsblock: fix non-aligned DIO read
> git bisect skip f742dc4a32587bff50b13dde9d8894b96851951a
> # skip: [7acdb026818455638543b04b68d4a580c367fba8] NFSv41: fix DIO write_io calculation
> git bisect skip 7acdb026818455638543b04b68d4a580c367fba8
> # skip: [ee34e13620d0678d420ce50101aaef94ab81fc74] NFS: Remove unnecessary semicolons (fs/nfs/client.c)
> git bisect skip ee34e13620d0678d420ce50101aaef94ab81fc74
> # skip: [dc182549d439f60c332bf74d7f220a1bccf37da6] NFS41: fix error of setting blocklayoutdriver
> git bisect skip dc182549d439f60c332bf74d7f220a1bccf37da6
> # skip: [fe6e1e8d9fad86873eb74a26e80a8f91f9e870b5] pnfsblock: fix partial page buffer wirte
> git bisect skip fe6e1e8d9fad86873eb74a26e80a8f91f9e870b5
> # skip: [05f4c350ee02e9461c6ae3a880ea326a06835e37] NFS: Discover NFSv4 server trunking when mounting
> git bisect skip 05f4c350ee02e9461c6ae3a880ea326a06835e37
> # skip: [5d0e3a004f02bffab51f542fa1d5b2e2854d8545] Revert "pnfsblock: bail out partial page IO"
> git bisect skip 5d0e3a004f02bffab51f542fa1d5b2e2854d8545
> # bad: [9f62387d6e26532bcbfb15606956074192ee526a] NFSv4: Fix up a merge conflict between migration and container changes
> git bisect bad 9f62387d6e26532bcbfb15606956074192ee526a
> # skip: [2afdfa5a846246de50e1881f71ba5c0aac0b415f] Merge branch 'bugfixes' into nfs-for-next
> git bisect skip 2afdfa5a846246de50e1881f71ba5c0aac0b415f
> 
> -- 
> Tuomas
> 
> --------------------------------------------------------------
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




