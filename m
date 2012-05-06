Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail1.trendhosting.net ([195.8.117.5]:46410 "EHLO
	mail1.trendhosting.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754679Ab2EFVXt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 May 2012 17:23:49 -0400
Message-ID: <4FA6EBD4.7040308@pocock.com.au>
Date: Sun, 06 May 2012 21:23:32 +0000
From: Daniel Pocock <daniel@pocock.com.au>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: extremely slow nfs when sync enabled
References: <4FA5E950.5080304@pocock.com.au> <1336328594.2593.14.camel@lade.trondhjem.org>
In-Reply-To: <1336328594.2593.14.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/05/12 18:23, Myklebust, Trond wrote:
> On Sun, 2012-05-06 at 03:00 +0000, Daniel Pocock wrote:
>>
>> I've been observing some very slow nfs write performance when the server
>> has `sync' in /etc/exports
>>
>> I want to avoid using async, but I have tested it and on my gigabit
>> network, it gives almost the same speed as if I was on the server
>> itself. (e.g. 30MB/sec to one disk, or less than 1MB/sec to the same
>> disk over NFS with `sync')
>>
>> I'm using Debian 6 with 2.6.38 kernels on client and server, NFSv3
>>
>> I've also tried a client running Debian 7/Linux 3.2.0 with both NFSv3
>> and NFSv4, speed is still slow
>>
>> Looking at iostat on the server, I notice that avgrq-sz = 8 sectors
>> (4096 bytes) throughout the write operations
>>
>> I've tried various tests, e.g. dd a large file, or unpack a tarball with
>> many small files, the iostat output is always the same
> 
> Were you using 'conv=sync'?

No, it was not using conv=sync, just the vanilla dd:

dd if=/dev/zero of=some-fat-file bs=65536 count=65536

>> Looking at /proc/mounts on the clients, everything looks good, large
>> wsize, tcp:
>>
>> rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.x.x.x,mountvers=3,mountport=58727,mountproto=udp,local_lock=none,addr=192.x.x.x
>> 0 0
>>
>> and
>>  rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.x.x.x.,minorversion=0,local_lock=none,addr=192.x.x.x 0 0
>>
>> and in /proc/fs/nfs/exports on the server, I have sync and wdelay:
>>
>> /nfs4/daniel
>> 192.168.1.0/24,192.x.x.x(rw,insecure,root_squash,sync,wdelay,no_subtree_check,uuid=aa2a6f37:9cc94eeb:bcbf983c:d6e041d9,sec=1)
>> /home/daniel
>> 192.168.1.0/24,192.x.x.x(rw,root_squash,sync,wdelay,no_subtree_check,uuid=aa2a6f37:9cc94eeb:bcbf983c:d6e041d9)
>>
>> Can anyone suggest anything else?  Or is this really the performance hit
>> of `sync'?
> 
> It really depends on your disk setup. Particularly when your filesystem
> is using barriers (enabled by default on ext4 and xfs), a lot of raid

On the server, I've tried both ext3 and ext4, explicitly changing things
like data=writeback,barrier=0, but the problem remains

The only thing that made it faster was using hdparm -W1 /dev/sd[ab] to
enable the write-back cache on the disk

> setups really _suck_ at dealing with fsync(). The latter is used every

I'm using md RAID1, my setup is like this:

2x 1TB SATA disks ST31000528AS (7200rpm with 32MB cache and NCQ)

SATA controller: ATI Technologies Inc SB700/SB800 SATA Controller [AHCI
mode] (rev 40)
- not using any of the BIOS softraid stuff

Both devices have identical partitioning:
1. 128MB boot
2. md volume (1TB - 128MB)

The entire md volume (/dev/md2) is then used as a PV for LVM

I do my write tests on a fresh LV with no fragmentation

> time the NFS client sends a COMMIT or trunc() instruction, and for
> pretty much all file and directory creation operations (you can use
> 'nfsstat' to monitor how many such operations the NFS client is sending
> as part of your test).

I know that my two tests are very different in that way:

- dd is just writing one big file, no fsync

- unpacking a tarball (or compiling a large C++ project) does a lot of
small writes with many fsyncs

In both cases, it is slow

> Local disk can get away with doing a lot less fsync(), because the cache
> consistency guarantees are different:
>       * in NFS, the server is allowed to crash or reboot without
>         affecting the client's view of the filesystem.
>       * in the local file system, the expectation is that on reboot any
>         data lost is won't need to be recovered (the application will
>         have used fsync() for any data that does need to be persistent).
>         Only the disk filesystem structures need to be recovered, and
>         that is done using the journal (or fsck).


Is this an intractable problem though?

Or do people just work around this, for example, enable async and
write-back cache, and then try to manage the risk by adding a UPS and/or
battery backed cache to their RAID setup (to reduce the probability of
unclean shutdown)?
