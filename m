Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-da0-f46.google.com ([209.85.210.46]:57840 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756709Ab2KZRp7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Nov 2012 12:45:59 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so3816725dak.19
        for <linux-nfs@vger.kernel.org>; Mon, 26 Nov 2012 09:45:59 -0800 (PST)
Message-ID: <50B3AAAA.9070601@gmail.com>
Date: Mon, 26 Nov 2012 23:15:14 +0530
From: "dE ." <de.techno@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: Slow NFS loop performance.
References: <50AF57A3.3090000@gmail.com> <20121123172333.GB8776@fieldses.org> <50B3918E.4020303@gmail.com> <20121126160853.GB11860@fieldses.org>
In-Reply-To: <20121126160853.GB11860@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/26/12 21:38, J. Bruce Fields wrote:
> On Mon, Nov 26, 2012 at 09:28:06PM +0530, dE . wrote:
>> On 11/23/12 22:53, J. Bruce Fields wrote:
>>> On Fri, Nov 23, 2012 at 04:31:55PM +0530, dE . wrote:
>>>> Humm... The last thing I expected was no response even in the mailing list.
>>>>
>>>> So I'm filing a bug on this.
>>>>
>>>> On Oct 23, 2012 2:19 PM, "dE ."<de.techno@gmail.com>   wrote:
>>>>> Hi!
>>>>>
>>>>> Great job with NFS server, it surely is fast, but not on loop devices.
>>>>>
>>>>> If I loop mount a file and share the mount point over NFS3 or NFS4, the
>>>>> write performance of the client on the loop mounted share is pretty bad.
>>>>>
>>>>> On a 100 Mbps (or 12.5MBps) full duplex Ethernet link, I get ~8MBps
>>>>> speeds, whereas on the loop mounted device, I get at best 6MBps.
>>> What exactly is your test?
>>>
>>> --b.
>> Sorry for the late response. I'd 200+ unread mails.
>>
>> I'm writing a large file to the mounted loop device.
> How large, and do you have the exact command you're using for that?
>
> Also, what are the client and server versions?
>
> I don't have any good idea off the top of my head.  I doubt anyone's
> worked on optimizing exports of loop devices.  I guess the first step
> would be to collect some statistics in the two cases (loop device and
> non-loop device), compare them, and see if you can see any patterns.
> /proc/self/mountstats on the client, and /proc/fs/nfsd/pool_stats, on
> the server, would be starting points.  Maybe perf on the server could
> also show up something.  Just running "top" on the server might be
> interesting.  (E.g.  is the CPU obviously busier in the slow case?)
>
> --b.

It's clear --

On the loop device --

dd if=/dev/zero of=/mnt/shares/mount_point/xfs_large_files/test.zero 
bs=1M count=1024
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB) copied, 1788.51 s, 600 kB/s

And otherwise --

dd if=/dev/zero of=/mnt/shares/test.zero bs=1M count=1024
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB) copied, 157.447 s, 6.8 MB/s

dd if=/dev/zero of=/mnt/shares/test.zero bs=1M count=1024
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB) copied, 128.628 s, 8.3 MB/s

I ran out of patience to do any tests on the loop device.

cat /proc/self/mountstats --

device rootfs mounted on / with fstype rootfs
device /dev/root mounted on / with fstype reiserfs
..
..
device 192.168.1.3:/ mounted on /mnt/shares with fstype nfs4 statvers=1.1
         opts:   
rw,vers=4.0,rsize=262144,wsize=262144,namlen=255,acregmin=900,acregmax=900,acdirmin=900,acdirmax=900,hard,proto=tcp,timeo=60,retrans=2,sec=sys,clientaddr=192.168.1.2,lookupcache=pos,local_lock=none
         age:    4026
         caps:   caps=0xffff,wtmult=512,dtsize=32768,bsize=0,namlen=255
         nfsv4:  bm0=0xfdffbfff,bm1=0xf9be3e,acl=0x3,pnfs=not configured
         sec:    flavor=1,pseudoflavor=1
         events: 14 54 0 8523 6 5 47 611072 0 0 611072 3040 12 6 12 12 0 
6 0 5 611072 0 0 0 0 0 0
         bytes:  0 2502950912 0 0 0 2502950912 0 611072
         RPC iostats version: 1.0  p/v: 100003/4 (nfs)
         xprt:   tcp 763 0 348 341795 14 30200 26072 7 42669773 0 174 
6344270 677055
         per-op statistics
                 NULL: 0 0 0 0 0 0 0 0
                 READ: 0 0 0 0 0 0 0 0
                WRITE: 10035 10035 0 2505279032 1324620 53001291 3776691 
56778324
               COMMIT: 48 48 0 10176 5952 151346 14030 165378
                 OPEN: 6 6 0 1784 2352 0 43 43
         OPEN_CONFIRM: 2 2 0 408 136 0 0 0
          OPEN_NOATTR: 0 0 0 0 0 0 0 0
         OPEN_DOWNGRADE: 0 0 0 0 0 0 0 0
                CLOSE: 6 6 0 1320 792 0 1 1
              SETATTR: 6 6 0 1432 1440 0 3478 3479
               FSINFO: 2 2 0 336 216 0 0 0
                RENEW: 0 0 0 0 0 0 0 0
          SETCLIENTID: 0 0 0 0 0 0 0 0
         SETCLIENTID_CONFIRM: 0 0 0 0 0 0 0 0
                 LOCK: 0 0 0 0 0 0 0 0
                LOCKT: 0 0 0 0 0 0 0 0
                LOCKU: 0 0 0 0 0 0 0 0
               ACCESS: 13 13 0 2568 1488 15581 8484 28896
              GETATTR: 15 15 0 2860 3300 0 7 8
               LOOKUP: 6 7 0 1472 516 19755 11318 31074
          LOOKUP_ROOT: 1 1 0 160 240 0 26 27
               REMOVE: 0 0 0 0 0 0 0 0
               RENAME: 0 0 0 0 0 0 0 0
                 LINK: 0 0 0 0 0 0 0 0
              SYMLINK: 0 0 0 0 0 0 0 0
               CREATE: 0 0 0 0 0 0 0 0
             PATHCONF: 1 1 0 164 72 0 0 0
               STATFS: 6 6 0 1128 696 0 1 1
             READLINK: 0 0 0 0 0 0 0 0
              READDIR: 3 3 0 652 3380 0 42 42
          SERVER_CAPS: 3 3 0 492 276 0 0 0
          DELEGRETURN: 0 0 0 0 0 0 0 0
               GETACL: 0 0 0 0 0 0 0 0
               SETACL: 0 0 0 0 0 0 0 0
         FS_LOCATIONS: 0 0 0 0 0 0 0 0
         RELEASE_LOCKOWNER: 0 0 0 0 0 0 0 0
              SECINFO: 0 0 0 0 0 0 0 0
          EXCHANGE_ID: 0 0 0 0 0 0 0 0
         CREATE_SESSION: 0 0 0 0 0 0 0 0
         DESTROY_SESSION: 0 0 0 0 0 0 0 0
             SEQUENCE: 0 0 0 0 0 0 0 0
         GET_LEASE_TIME: 0 0 0 0 0 0 0 0
         RECLAIM_COMPLETE: 0 0 0 0 0 0 0 0
            LAYOUTGET: 0 0 0 0 0 0 0 0
         GETDEVICEINFO: 0 0 0 0 0 0 0 0
         LAYOUTCOMMIT: 0 0 0 0 0 0 0 0
         LAYOUTRETURN: 0 0 0 0 0 0 0 0
         SECINFO_NO_NAME: 0 0 0 0 0 0 0 0
         TEST_STATEID: 0 0 0 0 0 0 0 0
         FREE_STATEID: 0 0 0 0 0 0 0 0
         GETDEVICELIST: 0 0 0 0 0 0 0 0

device 192.168.1.3:/mount_point/xfs_large_files/ mounted on 
/mnt/shares/mount_point/xfs_large_files with fstype nfs4 statvers=1.1
         opts:   
rw,vers=4.0,rsize=262144,wsize=262144,namlen=255,acregmin=900,acregmax=900,acdirmin=900,acdirmax=900,hard,proto=tcp,port=0,timeo=60,retrans=2,sec=sys,clientaddr=192.168.1.2,lookupcache=pos,local_lock=none
         age:    2344
         caps:   caps=0xffff,wtmult=512,dtsize=32768,bsize=0,namlen=255
         nfsv4:  bm0=0xfdffbfff,bm1=0xf9be3e,acl=0x3,pnfs=not configured
         sec:    flavor=1,pseudoflavor=1
         events: 0 0 0 6464 0 0 2 262144 0 0 262144 10131 0 1 2 2 0 1 0 
0 262144 0 0 0 0 0 0
         bytes:  0 1073741824 0 0 0 1073741824 0 262144
         RPC iostats version: 1.0  p/v: 100003/4 (nfs)
         xprt:   tcp 763 0 348 341795 14 30200 26072 7 42669773 0 174 
6344270 677055
         per-op statistics
                 NULL: 0 0 0 0 0 0 0 0
                 READ: 0 0 0 0 0 0 0 0
                WRITE: 7821 12504 5 1360145244 1032372 461231706 
30244294 493689738
               COMMIT: 23 28 0 5600 2852 981824 61062 1049646
                 OPEN: 1 1 0 336 404 0 122 122
         OPEN_CONFIRM: 1 1 0 216 68 0 0 0
          OPEN_NOATTR: 0 0 0 0 0 0 0 0
         OPEN_DOWNGRADE: 0 0 0 0 0 0 0 0
                CLOSE: 1 1 0 232 132 0 0 0
              SETATTR: 1 1 0 244 240 0 0 0
               FSINFO: 1 1 0 200 108 0 0 0
                RENEW: 0 0 0 0 0 0 0 0
          SETCLIENTID: 0 0 0 0 0 0 0 0
         SETCLIENTID_CONFIRM: 0 0 0 0 0 0 0 0
                 LOCK: 0 0 0 0 0 0 0 0
                LOCKT: 0 0 0 0 0 0 0 0
                LOCKU: 0 0 0 0 0 0 0 0
               ACCESS: 1 1 0 208 124 0 0 0
              GETATTR: 1 1 0 200 220 0 0 0
               LOOKUP: 0 0 0 0 0 0 0 0
          LOOKUP_ROOT: 0 0 0 0 0 0 0 0
               REMOVE: 0 0 0 0 0 0 0 0
               RENAME: 0 0 0 0 0 0 0 0
                 LINK: 0 0 0 0 0 0 0 0
              SYMLINK: 0 0 0 0 0 0 0 0
               CREATE: 0 0 0 0 0 0 0 0
             PATHCONF: 1 1 0 196 72 0 0 0
               STATFS: 0 0 0 0 0 0 0 0
             READLINK: 0 0 0 0 0 0 0 0
              READDIR: 0 0 0 0 0 0 0 0
          SERVER_CAPS: 2 2 0 392 184 0 0 0
          DELEGRETURN: 0 0 0 0 0 0 0 0
               GETACL: 0 0 0 0 0 0 0 0
               SETACL: 0 0 0 0 0 0 0 0
         FS_LOCATIONS: 0 0 0 0 0 0 0 0
         RELEASE_LOCKOWNER: 0 0 0 0 0 0 0 0
              SECINFO: 0 0 0 0 0 0 0 0
          EXCHANGE_ID: 0 0 0 0 0 0 0 0
         CREATE_SESSION: 0 0 0 0 0 0 0 0
         DESTROY_SESSION: 0 0 0 0 0 0 0 0
             SEQUENCE: 0 0 0 0 0 0 0 0
         GET_LEASE_TIME: 0 0 0 0 0 0 0 0
         RECLAIM_COMPLETE: 0 0 0 0 0 0 0 0
            LAYOUTGET: 0 0 0 0 0 0 0 0
         GETDEVICEINFO: 0 0 0 0 0 0 0 0
         LAYOUTCOMMIT: 0 0 0 0 0 0 0 0
         LAYOUTRETURN: 0 0 0 0 0 0 0 0
         SECINFO_NO_NAME: 0 0 0 0 0 0 0 0
         TEST_STATEID: 0 0 0 0 0 0 0 0
         FREE_STATEID: 0 0 0 0 0 0 0 0
         GETDEVICELIST: 0 0 0 0 0 0 0 0

And /proc/fs/nfsd/pool_stats

cat /proc/fs/nfsd/pool_stats
# pool packets-arrived sockets-enqueued threads-woken overloads-avoided 
threads-timedout
0 4637559 21028 1689208 269 0

Server --
uname -r
2.6.32-5-amd64

modinfo nfs
filename:       /lib/modules/2.6.32-5-amd64/kernel/fs/nfs/nfs.ko
license:        GPL
author:         Olaf Kirch <okir@monad.swb.de>
depends:        sunrpc,fscache,lockd,auth_rpcgss,nfs_acl
vermagic:       2.6.32-5-amd64 SMP mod_unload modversions
parm:           callback_tcpport:portnr
parm:           cache_getent:Path to the client cache upcall program 
(string)
parm:           cache_getent_timeout:Timeout (in seconds) after which 
the cache upcall is assumed to have failed (ulong)
parm:           enable_ino64:bool

modinfo nfsd
filename:       /lib/modules/2.6.32-5-amd64/kernel/fs/nfsd/nfsd.ko
license:        GPL
author:         Olaf Kirch <okir@monad.swb.de>
depends:        auth_rpcgss,sunrpc,lockd,exportfs,nfs_acl
vermagic:       2.6.32-5-amd64 SMP mod_unload modversions

Client --

uname -r
3.4.2-gentoo-r1

modinfo nfs
filename:       /lib/modules/3.4.2-gentoo-r1/kernel/fs/nfs/nfs.ko
license:        GPL
author:         Olaf Kirch <okir@monad.swb.de>
depends:        sunrpc,lockd,auth_rpcgss,nfs_acl
intree:         Y
vermagic:       3.4.2-gentoo-r1 SMP preempt mod_unload modversions
parm:           callback_tcpport:portnr
parm:           nfs_idmap_cache_timeout:int
parm:           send_implementation_id:Send implementation ID with 
NFSv4.1 exchange_id (ushort)
parm:           max_session_slots:Maximum number of outstanding NFSv4.1 
requests the client will negotiate (ushort)
parm:           cache_getent:Path to the client cache upcall program 
(string)
parm:           cache_getent_timeout:Timeout (in seconds) after which 
the cache upcall is assumed to have failed (ulong)
parm:           enable_ino64:bool
parm:           nfs4_disable_idmapping:Turn off NFSv4 idmapping when 
using 'sec=sys' (bool)

modinfo nfsd
filename:       /lib/modules/3.4.2-gentoo-r1/kernel/fs/nfsd/nfsd.ko
license:        GPL
author:         Olaf Kirch <okir@monad.swb.de>
depends:        auth_rpcgss,sunrpc,lockd,nfs_acl
intree:         Y
vermagic:       3.4.2-gentoo-r1 SMP preempt mod_unload modversions
parm:           nfs4_disable_idmapping:Turn off server's NFSv4 idmapping 
when using 'sec=sys' (bool)

net-fs/nfs-utils version 1.2.3-r1

This problem was reproducible from day 1, even during the 2.6 days. This 
also happen(ed/s) when I loop mount some file (on the server) in the client.

I also had an old Debian testing system which (Wheezy) which had 3.0 
kernel and shared the same problem.
