Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32156 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752533Ab0KEOTu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Nov 2010 10:19:50 -0400
Subject: Re: NFSv4 client in 20Mbit/sec fight with NFS server
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: David Flynn <davidf@rd.bbc.co.uk>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20101104233705.GM12804@rd.bbc.co.uk>
References: <20101104233705.GM12804@rd.bbc.co.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 05 Nov 2010 10:18:49 -0400
Message-ID: <1288966729.13204.6.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-11-04 at 23:37 +0000, David Flynn wrote:
> Dear All;
> 
> I am currently seeing a sustained ~20Mbit/sec of traffic from an NFS(v4)
> client, seemingly never completing the operation it desires.
> 
> vcfe0 mounts an nfs4 file system project:/project.  This is served by a
> ZFS backed solaris 10 system.  /project/vcluster is a referral to a similarly
> named export from the same nfs server, this has been automatically mounted
> by the client.  There is a long-lived process that writes log files to
> /project/vcluster/log.
> 
> An issue has arisen whereby trying to stat a particular file in
> /project/vcluster/log causes the stat to hang:
> 
> vcfe0:~$ /bin/ls /project/vcluster/log
> auth.log  daemon.log  debug  kern.log  messages  syslog  user.log
> vcfe0:~$ /bin/ls -l /project/vcluster/log
> ^C
> ^Z
> <kill terminal>
> 
> vcfe0:~$ strace ls -l /project/vcluster/log
> ...
> open("/project/vcluster/log", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = 3
> fcntl(3, F_GETFD)                       = 0x1 (flags FD_CLOEXEC)
> getdents(3, /* 9 entries */, 32768)     = 272
> lstat("/project/vcluster/log/kern.log", {st_mode=S_IFREG|0640, st_size=4789972, ...}) = 0
> lgetxattr("/project/vcluster/log/kern.log", "security.selinux", 0x1dd6300, 255) = -1 EOPNOTSUPP (Operation not supported)
> getxattr("/project/vcluster/log/kern.log", "system.posix_acl_access", 0x0, 0) = -1 EOPNOTSUPP (Operation not supported)
> ...
> lstat("/project/vcluster/log/messages", ^C <unfinished ...>
> vcfe0:~$
> 
> Wireshark reveals:
> No. Time        Source                Destination           Protocol Info
> 1   0.000000    172.29.148.82         172.29.120.141        NFS
>       V4 COMPOUND Call (Reply In 2) <EMPTY> RENEW
> 2   0.000341    172.29.120.141        172.29.148.82         NFS
>       V4 COMPOUND Reply (Call In 1) <EMPTY> RENEW
> 3   0.000378    172.29.148.82         172.29.120.141        NFS
>       V4 COMPOUND Call (Reply In 6) <EMPTY> PUTFH;WRITE[Unreassembled Packet] 
> 4   0.000384    172.29.148.82         172.29.120.141        TCP
>       [TCP segment of a reassembled PDU]
> 5   0.000664    172.29.120.141        172.29.148.82         TCP
>       nfs > 799 [ACK] ...
> 6   0.000763    172.29.120.141        172.29.148.82         NFS
>       V4 COMPOUND Reply (Call In 3) <EMPTY> PUTFH;WRITE
> 
> This sequence repeats continually. A full dump of a few iterations is
> available:
>   ftp://ftp.kw.bbc.co.uk/davidf/priv/vcfe-strange-20101029-filtered.pcap
> 
> For reference:
> 
> vcfe0:~$ cat /proc/fs/nfsfs/servers 
> NV SERVER   PORT USE HOSTNAME
> v3 ac1dbe14  801   1 vc-fs0-10g
> v4 ac1d789a  801   1 172.29.120.154
> v3 ac1d9210  801   2 vc-fs0
> v3 ac1d7898  801   1 hd
> v3 ac1d7890  801   1 pics
> v3 ac1d7899  801   1 cd
> v4 ac1d788d  801   3 project
> v4 ac1d788c  801   1 home
> v3 ac1d789a  801   1 172.29.120.154
> 
> vcfe0:~$ cat /proc/fs/nfsfs/volumes 
> NV SERVER   PORT DEV     FSID              FSC
> v3 ac1d789a  801 0:17    10000010006:0     no 
> v4 ac1d788c  801 0:24    55:1e             no 
> v4 ac1d788d  801 0:25    88465b3ae0adcb08  no 
> v3 ac1d7899  801 0:23    5500000028:0      no 
> v3 ac1d7890  801 0:26    5500000032:0      no 
> v3 ac1d7898  801 0:27    5500000064:0      no 
> v3 ac1d9210  801 0:28    4116d75a78b2a5d6  no 
> v3 ac1d9210  801 0:29    cf1c7ed0974b14ca  no 
> v4 ac1d788d  801 0:30    8247924701d6608:  no 
> v4 ac1d789a  801 0:32    fd850e709fa15308  no 
> v3 ac1dbe14  801 0:31    4116d75a78b2a5d6  no 
> 
> vcfe0:~$ cat /proc/mounts  | grep project
> project:/project/ /project nfs4 rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=172.29.148.82,minorversion=0,addr=172.29.120.141 0 0
> project:/project/vcluster /project/vcluster nfs4 rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=172.29.148.82,minorversion=0,addr=172.29.120.141 0 0
> 
> NFS client is running 2.6.35.
> 
> The logfiles in /project/vcluster/log end at about the same time as the following
> in vcfe0's dmesg occurs:
> 
> [4220081.989223] nfs: server 172.29.120.154 not responding, still trying
> [4220085.983648] nfs: server 172.29.120.154 OK
> [4220294.480217] INFO: task syslog-ng:9377 blocked for more than 120 seconds.
> [4220294.480252] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [4220294.480300] syslog-ng     D 000000013f0a3aeb     0  9377      1 0x00000000
> [4220294.480339]  ffff88013c5a6630 0000000000000086 0000000000000018 ffffffff00000000
> [4220294.480397]  ffffffff81632020 0000000000015480 0000000000015480 0000000000015480
> [4220294.480454]  ffff88013ebdbfd8 0000000000015480 ffff88013c5a6630 ffff88013ebdbfd8
> [4220294.480511] Call Trace:
> [4220294.480541]  [<ffffffff8100e7ee>] ? read_tsc+0x5/0x16
> [4220294.480590]  [<ffffffffa028cb9a>] ? nfs_wait_bit_uninterruptible+0x0/0xd [nfs]
> [4220294.480640]  [<ffffffff812ff4f0>] ? io_schedule+0x6b/0xaa
> [4220294.480682]  [<ffffffffa028cba3>] ? nfs_wait_bit_uninterruptible+0x9/0xd [nfs]
> [4220294.480731]  [<ffffffff812ffa39>] ? __wait_on_bit+0x3e/0x6f
> [4220294.480762]  [<ffffffff812ffad8>] ? out_of_line_wait_on_bit+0x6e/0x77
> [4220294.480806]  [<ffffffffa028cb9a>] ? nfs_wait_bit_uninterruptible+0x0/0xd [nfs]
> [4220294.480856]  [<ffffffff8105b81f>] ? wake_bit_function+0x0/0x2e
> [4220294.480901]  [<ffffffffa029102d>] ? nfs_updatepage+0x170/0x454 [nfs]
> [4220294.480942]  [<ffffffffa0283e9d>] ? nfs_write_end+0xfd/0x128 [nfs]
> [4220294.480977]  [<ffffffff810ae22e>] ? iov_iter_copy_from_user_atomic+0x77/0xe4
> [4220294.481027]  [<ffffffff810ae511>] ? generic_file_buffered_write+0x16a/0x24c
> [4220294.481064]  [<ffffffff810af68d>] ? __generic_file_aio_write+0x24c/0x280
> [4220294.481107]  [<ffffffffa0285b63>] ? nfs_refresh_inode_locked+0x72c/0x96a [nfs]
> [4220294.481157]  [<ffffffff810af716>] ? generic_file_aio_write+0x55/0x9f
> [4220294.481198]  [<ffffffffa02848e7>] ? nfs_file_write+0xd5/0x17e [nfs]
> [4220294.481232]  [<ffffffff810e8dcc>] ? do_sync_write+0xb1/0xea
> [4220294.481263]  [<ffffffff810e92ff>] ? vfs_write+0xa4/0x101
> [4220294.481294]  [<ffffffff810e940f>] ? sys_write+0x45/0x6b
> [4220294.481325]  [<ffffffff810089c2>] ? system_call_fastpath+0x16/0x1b
> 
> The blocked task report is repeated a further five times at 120 second intervals.
> 
> Any thoughts on this would be much appreciated,

The following patch has been committed to 2.6.37-rc1 in order to fix a
similar situation. Can you please try it and see if it fixes yours too?

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=b0ed9dbc24f1fd912b2dd08b995153cafc1d5b1c

Cheers
  Trond
