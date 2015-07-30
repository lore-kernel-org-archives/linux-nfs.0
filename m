Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41706 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbbG3V4n convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 17:56:43 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: NFS with RDMA mounts, but can't actually be used
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CA+X5Wn5OMj--ObKAMv0XVNj5wtQc_5hnhjc0Gb_v9=DFVANNuw@mail.gmail.com>
Date: Thu, 30 Jul 2015 17:56:39 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <73C1935C-77E2-41B4-A952-6F5C161A87E0@oracle.com>
References: <CA+X5Wn5OMj--ObKAMv0XVNj5wtQc_5hnhjc0Gb_v9=DFVANNuw@mail.gmail.com>
To: james harvey <jamespharvey20@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cc: nfs-rdma-devel removed. I think that's a dead list.


On Jul 30, 2015, at 5:54 PM, james harvey <jamespharvey20@gmail.com> wrote:

> Running 2 up to date Arch systems, on kernel 4.1.3 (-1 Arch).
> nfs-utils 1.3.2 (-6 Arch).  2 Mellanox ConnectX MT25418 cards, using
> latest firmware.
> 
> Have a working InfiniBand subnet.  Able to connect via IPoIB and
> InfiniBand protocols.  Able to use iSCSI via IPoIB and iSER.  Able to
> use nfs over IPoIB just fine.
> 
> If I use nfs using rdma, I can mount a nfs volume, but any process
> that tries to use it hangs.  Even "cd" or "ls".
> 
> I've tried using a directory being shared from the server that is a
> single disk partition with btrfs, so there's no raid involved.
> 
> 
> I believe I have everything setup correctly.  Kernel modules are
> loaded (including mlx4, ib_ipoib, svcrdma on server, xprtrdma on
> client.)  "rdma 20049" echoed to /proc/fs/nfsd/portlist.  Server is
> running nfs-server.service.
> 
> Server exports the directory using:
> /bench 192.168.2.0/24(rw,async,insecure,no_subtree_check)
> 
> Client mounts the directory using:
> mount -t nfs4 -o rdma,port=20049 192.168.2.1:/bench /ben
> 
> It returns from the mount command almost immediately, and with "--verbose" says:
> ==========
> mount.nfs4: timeout set for Thu Jul 30 17:22:26 2015
> mount.nfs4: trying text-based options
> 'rdma,port=20049,vers=4.2,addr=192.168.2.1,clientaddr=192.168.2.2'

Try specifying vers=4.0 explicitly.


> ==========
> 
> After, checking mount shows:
> ==========
> 192.168.2.1:/bench on /bench type nfs4
> (rw,relatime,vers=4.2,rsize=262144,wsize=262144,namlen=255,hard,proto=rdma,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.2.2,local_lock=none,addr=192.168.2.1)
> ==========
> 
> BUT, the client with sunrpc.nfs_debug=1023, then within 0.1 seconds,
> dmesg has overflown and has 8510 lines.  Don't think it's supposed to
> be that verbose.  It seems to be repeating (with seqid changing):
> ==========
> [ 1271.325354] systemd-journald[232]: /dev/kmsg buffer overrun, some
> messages lost.
> [ 1271.325365] <-- nfs4_proc_bind_conn_to_session status= 0
> [ 1271.325370] --> nfs41_setup_sequence
> [ 1271.325371] <-- nfs41_setup_sequence slotid=0 seqid=1191326
> [ 1271.325375] encode_sequence: sessionid=1438289348:4:5:0
> seqid=1191326 slotid=0 max_slotid=0 cache_this=0
> [ 1271.325424] nfs41_sequence_done: Error 0 free the slot
> [ 1271.325425] nfs41_sequence_call_done rpc_cred ffff880877238240
> [ 1271.325425] <-- nfs41_sequence_call_done
> [ 1271.325435] --> nfs_put_client({3})
> [ 1271.325436] <-- nfs4_proc_sequence status=0
> [ 1271.325438] --> nfs4_proc_bind_conn_to_session
> [ 1271.325463] systemd-journald[232]: /dev/kmsg buffer overrun, some
> messages lost.
> ==========
> 
> The server even with debug=1023 gets no  new dmesg during or after the mount.
> 
> At this point, "cd /bench" and "ls /bench" hang.  Can't strace cd, but
> if I strace the ls, I get:
> ==========
> execve("/usr/bin/ls", ["ls", "/bench"], [/* 58 vars */]) = 0
> brk(0)                                  = 0x175e000
> access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
> open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
> fstat(3, {st_mode=S_IFREG|0644, st_size=157039, ...}) = 0
> mmap(NULL, 157039, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7fa524f93000
> close(3)                                = 0
> open("/usr/lib/libcap.so.2", O_RDONLY|O_CLOEXEC) = 3
> read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240\25\0\0\0\0\0\0"...,
> 832) = 832
> fstat(3, {st_mode=S_IFREG|0644, st_size=17320, ...}) = 0
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
> 0) = 0x7fa524f92000
> mmap(NULL, 2112568, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3,
> 0) = 0x7fa524b95000
> mprotect(0x7fa524b99000, 2093056, PROT_NONE) = 0
> mmap(0x7fa524d98000, 4096, PROT_READ|PROT_WRITE,
> MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3000) = 0x7fa524d98000
> close(3)                                = 0
> open("/usr/lib/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
> read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260\10\2\0\0\0\0\0"...,
> 832) = 832
> fstat(3, {st_mode=S_IFREG|0755, st_size=1979984, ...}) = 0
> mmap(NULL, 3807760, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3,
> 0) = 0x7fa5247f3000
> mprotect(0x7fa52498c000, 2093056, PROT_NONE) = 0
> mmap(0x7fa524b8b000, 24576, PROT_READ|PROT_WRITE,
> MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x198000) = 0x7fa524b8b000
> mmap(0x7fa524b91000, 14864, PROT_READ|PROT_WRITE,
> MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fa524b91000
> close(3)                                = 0
> open("/usr/lib/libattr.so.1", O_RDONLY|O_CLOEXEC) = 3
> read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`\24\0\0\0\0\0\0"...,
> 832) = 832
> fstat(3, {st_mode=S_IFREG|0755, st_size=18736, ...}) = 0
> mmap(NULL, 2113912, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3,
> 0) = 0x7fa5245ee000
> mprotect(0x7fa5245f2000, 2093056, PROT_NONE) = 0
> mmap(0x7fa5247f1000, 8192, PROT_READ|PROT_WRITE,
> MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3000) = 0x7fa5247f1000
> close(3)                                = 0
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
> 0) = 0x7fa524f91000
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
> 0) = 0x7fa524f90000
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
> 0) = 0x7fa524f8f000
> arch_prctl(ARCH_SET_FS, 0x7fa524f90700) = 0
> mprotect(0x7fa524b8b000, 16384, PROT_READ) = 0
> mprotect(0x7fa5247f1000, 4096, PROT_READ) = 0
> mprotect(0x61c000, 4096, PROT_READ)     = 0
> mprotect(0x7fa524fba000, 4096, PROT_READ) = 0
> munmap(0x7fa524f93000, 157039)          = 0
> brk(0)                                  = 0x175e000
> brk(0x177f000)                          = 0x177f000
> open("/usr/lib/locale/locale-archive", O_RDONLY|O_CLOEXEC) = 3
> fstat(3, {st_mode=S_IFREG|0644, st_size=1852560, ...}) = 0
> mmap(NULL, 1852560, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7fa524dca000
> close(3)                                = 0
> ioctl(1, TCGETS, {B38400 opost isig icanon echo ...}) = 0
> ioctl(1, TIOCGWINSZ, {ws_row=33, ws_col=211, ws_xpixel=0, ws_ypixel=0}) = 0
> stat("/bench",
> ==========
> 
> The server even with debug=1023 gets no  new dmesg during the ls.
> 
> And it never gets past this stat.  Strace has to be kill -9'ed.  Just
> kill doesn't do anything.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



