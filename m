From: michael <michael@newdream.net>
Subject: Re: statd segfaults
Date: Tue, 08 Apr 2003 13:01:59 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E932AB7.2010002@newdream.net>
References: <3E51D8C8.8000905@newdream.net>	<shsof5a542k.fsf@charged.uio.no> <15954.51958.993033.937277@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060901060706000808050600"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.hq.newdream.net ([66.33.200.10])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 192zJr-0001dV-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Apr 2003 13:03:47 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15954.51958.993033.937277@notabene.cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------060901060706000808050600
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

I have included an ltrace of statd which shows the segfault. any 
guidance as far as what is going on right before the segfault would be 
greatly appreciated.  The segfaults are happening many times a day on a 
large number of servers. the enviornment is debian 3.0. LEt me know if i 
have left out and needed info.

thanks!
michael

Neil Brown wrote:
> On  February 18, trond.myklebust@fys.uio.no wrote:
> 
>>>>>>>" " == michael  <michael@newdream.net> writes:
>>
>>     > ) = 74 sendmsg(4, {msg_name(16)={sin_family=AF_INET,
>>     > sin_port=htons(2670), sin_addr=inet_addr("127.0.0.1")}},
>>     > msg_iov(1)=[{"\336^\313\2\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
>>     > 32}], msg_controllen=24, msg_control=0x8051c20, , msg_flags=0},
>>     > 0) = 32
>>
>>That looks a bit strange. Why would msg_controllen/msg_control be set
>>on an RPC call? Are you sure that your statd is linked to the standard
>>RPC library routines in glibc?
> 
> 
> Because statd (and the rpc server libraries in general) wants to
> tell the kernel about the packet is is repling to, make sure it gets
> the source address right.  IP_PKTINFO.  I am in the middle of a thread
> about it on linux-kernel because I don't think the kernel handles it
> quite right.
> 
> However that doesn't explain the SEGFAULT.  Have you tried 'ltrace' on
> statd.  What does it show?
> 
> NeilBrown


--------------060901060706000808050600
Content-Type: text/plain;
 name="statd.ltrace"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="statd.ltrace"

17:30:32 SYS_uname(0xbffff91c)                    = 0
17:30:32 SYS_brk(NULL)                            = 0x0804ff74
17:30:32 SYS_open("/etc/ld.so.preload", 0, 00)    = -2
17:30:32 SYS_open("/etc/ld.so.cache", 0, 00)      = 3
17:30:32 SYS_fstat64(3, 0xbffff0a4, 0x400133e0, 0x40013620, 3) = 0
17:30:32 SYS_mmap(0xbffff05c, 0xbffff0a4, 0x400130ec, 3, 0x400132b8) = 0x40014000
17:30:32 SYS_close(3)                             = 0
17:30:32 SYS_open("/lib/libwrap.so.0", 0, 027777770564) = 3
17:30:32 SYS_read(3, "\177ELF\001\001\001", 1024) = 1024
17:30:32 SYS_fstat64(3, 0xbffff0f4, 0x400133e0, 0x40013620, 3) = 0
17:30:32 SYS_mmap(0xbffff01c, 29092, 0x400130ec, 0xbffff048, 24) = 0x4001b000
17:30:32 SYS_mprotect(0x40021000, 4516, 0, 0xbffff048, 4516) = 0
17:30:32 SYS_mmap(0xbffff01c, 0xbffff054, 0x400130ec, 3, 0) = 0x40021000
17:30:32 SYS_mmap(0xbffff01c, 0, 0x400130ec, 0xbffff054, 0x40022000) = 0x40022000
17:30:32 SYS_close(3)                             = 0
17:30:32 SYS_open("/lib/libnsl.so.1", 0, 04001)   = 3
17:30:32 SYS_read(3, "\177ELF\001\001\001", 1024) = 1024
17:30:32 SYS_fstat64(3, 0xbffff0e4, 0x400133e0, 0x40013620, 3) = 0
17:30:32 SYS_mmap(0xbfffefcc, 80988, 0x400130ec, 0xbfffeff8, 24) = 0x40023000
17:30:32 SYS_mprotect(0x40034000, 11356, 0, 0xbfffeff8, 11356) = 0
17:30:32 SYS_mmap(0xbfffefcc, 0xbffff004, 0x400130ec, 3, 11356) = 0x40034000
17:30:32 SYS_mmap(0xbfffefcc, 0, 0x400130ec, 0xbffff004, 0x40035000) = 0x40035000
17:30:32 SYS_close(3)                             = 0
17:30:32 SYS_open("/lib/libc.so.6", 0, 04001)     = 3
17:30:32 SYS_read(3, "\177ELF\001\001\001", 1024) = 1024
17:30:32 SYS_fstat64(3, 0xbffff0d4, 0x400133e0, 0x40013620, 3) = 0
17:30:32 SYS_mmap(0xbfffef9c, -11, 0x400130ec, 4096, 446) = 0x40037000
17:30:32 SYS_mmap(0xbfffefbc, 0x0011cce0, 0x400130ec, 0xbfffefe8, 24) = 0x40038000
17:30:32 SYS_mprotect(0x4014b000, 40160, 0, 0xbfffefe8, 40160) = 0
17:30:32 SYS_mmap(0xbfffefbc, 0xbfffeff4, 0x400130ec, 3, 40160) = 0x4014b000
17:30:32 SYS_mmap(0xbfffefbc, 0, 0x400130ec, 0xbfffeff4, 0x40151000) = 0x40151000
17:30:32 SYS_close(3)                             = 0
17:30:32 SYS_munmap(0x40014000, 27981)            = 0
17:30:32 __libc_start_main(0x0804aec0, 2, 0xbffffd64, 0x0804934c, 0x0804d660 <unfinished ...>
17:30:32 __register_frame_info(0x0804fb80, 0x0804fe08, 0xbffffd08, 0x40063f18, 0x4014fe48) = 0x080493e4
17:30:32 strrchr("/sbin/rpc.statd", '/')          = "/rpc.statd"
17:30:32 strrchr("nfs-utils 1.0", ' ')            = " 1.0"
17:30:32 getopt_long(2, 0xbffffd64, "h?vVFdn:p:o:", 0x0804fa3c, NULL) = 70
17:30:32 getopt_long(2, 0xbffffd64, "h?vVFdn:p:o:", 0x0804fa3c, NULL) = 100
17:30:32 getopt_long(2, 0xbffffd64, "h?vVFdn:p:o:", 0x0804fa3c, NULL) = -1
17:30:32 getpid( <unfinished ...>
17:30:32 SYS_getpid()                             = 16103
17:30:32 <... getpid resumed> )                   = 16103
17:30:32 vsnprintf("Version 1.0 Starting", 1024, "Version %s Starting", 0xbffffcbc) = 20
17:30:32 time(0xbffff8a8 <unfinished ...>
17:30:32 SYS_time(0xbffff8a8, 9, 0xbffff8a8, 5, 0xbffff8ac) = 0x3e921828
17:30:32 <... time resumed> )                     = 1049761832
17:30:32 localtime(0xbffff8a8 <unfinished ...>
17:30:32 SYS_brk(NULL)                            = 0x0804ff74
17:30:32 SYS_brk(0x0804ff9c)                      = 0x0804ff9c
17:30:32 SYS_brk(0x08050000)                      = 0x08050000
17:30:32 SYS_brk(0x08051000)                      = 0x08051000
17:30:32 SYS_open("/etc/localtime", 0, 0666)      = 3
17:30:32 SYS_fstat64(3, 0xbffff5cc, 0x40150aa0, 0x401544ec, 3) = 0
17:30:32 SYS_mmap(0xbffff594, 0xbffff5cc, 0x4014fe48, 0x0804ff98, 4096) = 0x40014000
17:30:32 SYS_read(3, "TZif", 4096)                = 1017
17:30:32 SYS_close(3)                             = 0
17:30:32 SYS_munmap(0x40014000, 4096)             = 0
17:30:32 <... localtime resumed> )                = 0x401544a0
17:30:32 fprintf(0x4014d380, "%02d/%02d/%04d %02d:%02d:%02d %s"..., 4, 7, 2003, 17, 30, 32, "rpc.statd" <unfinished ...>
17:30:32 SYS_write(2, "04/07/2003 17:30:32 rpc.statd[16"..., 5904/07/2003 17:30:32 rpc.statd[16103]: Version 1.0 Starting
) = 59
17:30:32 <... fprintf resumed> )                  = 59
17:30:32 sprintf("Flags: ", "Flags: ")            = 7
17:30:32 strcat("Flags: ", "No-Daemon ")          = "Flags: No-Daemon "
17:30:32 strcat("Flags: No-Daemon ", "Log-STDERR ") = "Flags: No-Daemon Log-STDERR "
17:30:32 vsnprintf("Flags: No-Daemon Log-STDERR ", 1024, "Flags: No-Daemon Log-STDERR ", 0xbffffc2c) = 28
17:30:32 time(0xbffff818 <unfinished ...>
17:30:32 SYS_time(0xbffff818, 0xbffff70c, 0xbffff818, 5, 0xbffff81c) = 0x3e921828
17:30:32 <... time resumed> )                     = 1049761832
17:30:32 localtime(0xbffff818)                    = 0x401544a0
17:30:32 fprintf(0x4014d380, "%02d/%02d/%04d %02d:%02d:%02d %s"..., 4, 7, 2003, 17, 30, 32, "rpc.statd" <unfinished ...>
17:30:32 SYS_write(2, "04/07/2003 17:30:32 rpc.statd[16"..., 6704/07/2003 17:30:32 rpc.statd[16103]: Flags: No-Daemon Log-STDERR 
) = 67
17:30:32 <... fprintf resumed> )                  = 67
17:30:32 signal(1, 0x0804ad5c <unfinished ...>
17:30:32 SYS_rt_sigaction(1, 0xbffffad0, 0xbffffa44, 8, 1) = 0
17:30:32 <... signal resumed> )                   = NULL
17:30:32 signal(2, 0x0804ad5c <unfinished ...>
17:30:32 SYS_rt_sigaction(2, 0xbffffac0, 0xbffffa34, 8, 2) = 0
17:30:32 <... signal resumed> )                   = NULL
17:30:32 signal(15, 0x0804ad5c <unfinished ...>
17:30:32 SYS_rt_sigaction(15, 0xbffffad0, 0xbffffa44, 8, 15) = 0
17:30:32 <... signal resumed> )                   = NULL
17:30:32 signal(17, 0x00000001 <unfinished ...>
17:30:32 SYS_rt_sigaction(17, 0xbffffac0, 0xbffffa34, 8, 17) = 0
17:30:32 <... signal resumed> )                   = NULL
17:30:32 socket(2, 2, 17 <unfinished ...>
17:30:32 SYS_socketcall(1, 0xbffffc94, -1, 0xbffffd64, 0) = 3
17:30:32 <... socket resumed> )                   = 3
17:30:32 __rpc_thread_svc_fdset(-1, 0, 0, 0, 0x10000000) = 0x40154c00
17:30:32 bindresvport(3, 0xbffffcbc, 0xbffffccc, 0x0804b97c, -1 <unfinished ...>
17:30:32 SYS_getpid()                             = 16103
17:30:32 SYS_socketcall(2, 0xbffffc54, 0x4014fe48, 0xbffffcbc, -1) = 0
17:30:32 <... bindresvport resumed> )             = 0
17:30:32 pmap_unset(100024, 1, 0x08049a09, 0x0804fc6c, 0x4014fe48 <unfinished ...>
17:30:32 SYS_socketcall(1, 0xbfffdc14, 0x4014fe48, 0xbffffcbc, 0) = 4
17:30:32 SYS_ioctl(4, 35090, 0xbfffdc54, 0xbfffdc54, 0) = 0
17:30:32 SYS_ioctl(4, 35091, 0xbfffdc5c, 0xbfffdc9c, 0xbfffdc7c) = 0
17:30:32 SYS_close(4)                             = 0
17:30:32 SYS_gettimeofday(0xbffffc04, 0, 0x4014fe48, 0xbffffc04, 0x401538a4) = 0
17:30:32 SYS_socketcall(1, 0xbffffc04, 0x4014fe48, 0x080504e0, 0x08050518) = 4
17:30:32 SYS_socketcall(2, 0xbffffbc4, 0x4014fe48, 0xbffffbec, -1) = 0
17:30:32 SYS_ioctl(4, 21537, 0xbffffc38, 0x080504e0, 0x08050518) = 0
17:30:32 SYS_socketcall(14, 0xbffffbf4, 0x4014fe48, 0x080504e0, 0x08050518) = 0
17:30:32 xdr_pmap(0x08050518, 0xbffffcac, 0xbffffbbc, 0x40120189, 0x4014fe48) = 1
17:30:32 SYS_socketcall(11, 0xbffffb74, 0x4014fe48, 625, 0) = 56
17:30:32 SYS_poll(0xbffffbe0, 1, 5000, 5000, 0xbffffbe0) = 1
17:30:32 SYS_socketcall(12, 0xbffffb74, 0x4014fe48, 0xbffffc5c, 0xbffffbd4) = 28
17:30:32 SYS_close(4)                             = 0
17:30:32 <... pmap_unset resumed> )               = 0
17:30:32 open("/var/lib/nfs/state", 66, 0600 <unfinished ...>
17:30:32 SYS_open("/var/lib/nfs/state", 66, 0600) = 4
17:30:32 <... open resumed> )                     = 4
17:30:32 read(4,  <unfinished ...>
17:30:32 SYS_read(4, "\313\002", 4)               = 4
17:30:32 <... read resumed> "\313\002", 4)        = 4
17:30:32 vsnprintf("New state: 717", 1024, "New state: %u", 0xbffff8ac) = 14
17:30:32 time(0xbffff498 <unfinished ...>
17:30:32 SYS_time(0xbffff498, 0, 0xbffff498, 7, 0xbffff49c) = 0x3e921828
17:30:32 <... time resumed> )                     = 1049761832
17:30:32 localtime(0xbffff498)                    = 0x401544a0
17:30:32 fprintf(0x4014d380, "%02d/%02d/%04d %02d:%02d:%02d %s"..., 4, 7, 2003, 17, 30, 32, "rpc.statd" <unfinished ...>
17:30:32 SYS_write(2, "04/07/2003 17:30:32 rpc.statd[16"..., 5304/07/2003 17:30:32 rpc.statd[16103]: New state: 717
) = 53
17:30:32 <... fprintf resumed> )                  = 53
17:30:32 lseek(4, 0, 0, 0x0804b3b2, 7 <unfinished ...>
17:30:32 SYS_lseek(4, 0, 0, 4, 0)                 = 0
17:30:32 <... lseek resumed> )                    = 0
17:30:32 write(4, "\315\002", 4 <unfinished ...>
17:30:32 SYS_write(4, "\315\002", 4)              = 4
17:30:32 <... write resumed> )                    = 4
17:30:32 fsync(4, 0x0804ff70, 4, 0x206e6f69, -1 <unfinished ...>
17:30:32 SYS_fsync(4, 0x0804ff70, 4, 4, 0)        = 0
17:30:32 <... fsync resumed> )                    = 0
17:30:32 close(4 <unfinished ...>
17:30:32 SYS_close(4)                             = 0
17:30:32 <... close resumed> )                    = 0
17:30:32 gethostname( <unfinished ...>
17:30:32 SYS_uname(0xbffff714)                    = 0
17:30:32 <... gethostname resumed> "dali", 1024)  = 0
17:30:32 gethostbyname("dali" <unfinished ...>
17:30:32 SYS_gettimeofday(0xbfffd744, 0, 0x4014fe48, 0xbfffd744, 0) = 0
17:30:32 SYS_getpid()                             = 16103
17:30:32 SYS_open("/etc/resolv.conf", 0, 0666)    = 4
17:30:32 SYS_fstat64(4, 0xbfffd54c, 0x40150aa0, 0x401544ec, 4) = 0
17:30:32 SYS_mmap(0xbfffd514, 0xbfffd54c, 0x4014fe48, 0x080508e8, 4096) = 0x40014000
17:30:32 SYS_read(4, "search dreamhost.com\nnameserver\t"..., 4096) = 92
17:30:32 SYS_read(4, "", 4096)                    = 0
17:30:32 SYS_close(4)                             = 0
17:30:32 SYS_munmap(0x40014000, 4096)             = 0
17:30:32 SYS_socketcall(1, 0xbffff694, 0x4014fe48, 5, 0x40150aa0) = 4
17:30:32 SYS_socketcall(3, 0xbffff694, 0x4014fe48, 4, 0x40150aa0) = -2
17:30:32 SYS_close(4)                             = 0
17:30:32 SYS_open("/etc/nsswitch.conf", 0, 0666)  = 4
17:30:32 SYS_fstat64(4, 0xbffff5fc, 0x40150aa0, 0x401544ec, 4) = 0
17:30:32 SYS_mmap(0xbffff5c4, 0xbffff5fc, 0x4014fe48, 0x080508e8, 4096) = 0x40014000
17:30:32 SYS_read(4, "# /etc/nsswitch.conf\n#\n# Example"..., 4096) = 465
17:30:32 SYS_read(4, "", 4096)                    = 0
17:30:32 SYS_close(4)                             = 0
17:30:32 SYS_munmap(0x40014000, 4096)             = 0
17:30:32 SYS_open("/etc/ld.so.cache", 0, 00)      = 4
17:30:32 SYS_fstat64(4, 0xbfffef0c, 0x40150aa0, 0x401544ec, 4) = 0
17:30:32 SYS_mmap(0xbfffeec4, 0xbfffef0c, 0x400130ec, 4, 0x400132b8) = 0x40014000
17:30:32 SYS_close(4)                             = 0
17:30:32 SYS_open("/lib/libnss_files.so.2", 0, 027777767734) = 4
17:30:32 SYS_read(4, "\177ELF\001\001\001", 1024) = 1024
17:30:32 SYS_fstat64(4, 0xbfffef5c, 0x40150aa0, 0x401544ec, 4) = 0
17:30:32 SYS_mmap(0xbfffee44, 36112, 0x400130ec, 0xbfffee70, 24) = 0x40155000
17:30:32 SYS_mprotect(0x4015d000, 3344, 0, 0xbfffee70, 3344) = 0
17:30:32 SYS_mmap(0xbfffee44, 0xbfffee7c, 0x400130ec, 4, 3344) = 0x4015d000
17:30:32 SYS_close(4)                             = 0
17:30:32 SYS_munmap(0x40014000, 27981)            = 0
17:30:32 SYS_brk(0x08052000)                      = 0x08052000
17:30:32 SYS_open("/etc/host.conf", 0, 0666)      = 4
17:30:32 SYS_fstat64(4, 0xbffff4dc, 0x40150aa0, 0x401544ec, 4) = 0
17:30:32 SYS_mmap(0xbffff4a4, 0xbffff4dc, 0x4014fe48, 0x08050f58, 4096) = 0x40014000
17:30:32 SYS_read(4, "order hosts,bind\nmulti on\n", 4096) = 26
17:30:32 SYS_read(4, "", 4096)                    = 0
17:30:32 SYS_close(4)                             = 0
17:30:32 SYS_munmap(0x40014000, 4096)             = 0
17:30:32 SYS_open("/etc/hosts", 0, 0666)          = 4
17:30:32 SYS_fcntl64(4, 1, 0, 1, 4)               = 0
17:30:32 SYS_fcntl64(4, 2, 1, 1, 4)               = 0
17:30:32 SYS_fstat64(4, 0xbffff50c, 0x40150aa0, 0x401544ec, 4) = 0
17:30:32 SYS_mmap(0xbffff4d4, 0xbffff50c, 0x4014fe48, 0x08050f58, 4096) = 0x40014000
17:30:32 SYS_read(4, "10.3.34.66\tpeon0088\n127.0.0.1   "..., 4096) = 335
17:30:32 SYS_read(4, "", 4096)                    = 0
17:30:32 SYS_close(4)                             = 0
17:30:32 SYS_munmap(0x40014000, 4096)             = 0
17:30:32 <... gethostbyname resumed> )            = 0x40152d04
17:30:32 strncpy(0xbffff8c8, "dali.dreamhost.com", 1024) = 0xbffff8c8
17:30:32 __strdup(0xbffff8c8, 88, 0x08048d70, 0x4003f928, 0xbffff8c8) = 0x08050990
17:30:32 __xstat(3, "/var/lib/nfs/sm", 0xbffffc74 <unfinished ...>
17:30:32 SYS_stat64(0x0804e16e, 0xbffffb9c, 0x08050990, 0xbffffd64, 0x0804e16e) = 0
17:30:32 <... __xstat resumed> )                  = 0
17:30:32 __xstat(3, "/var/lib/nfs/sm.bak", 0xbffffc74 <unfinished ...>
17:30:32 SYS_stat64(0x0804e19b, 0xbffffb9c, 0xbffffc74, 0xbffffd64, 0x0804e19b) = 0
17:30:32 <... __xstat resumed> )                  = 0
17:30:32 opendir("/var/lib/nfs/sm" <unfinished ...>
17:30:32 SYS_open("/dev/null", 67584, 027777775674) = -20
17:30:32 SYS_open("/var/lib/nfs/sm", 100352, 00)  = 4
17:30:32 SYS_fstat64(4, 0xbffffbdc, 0x40150aa0, 0x401544ec, 4) = 0
17:30:32 SYS_fcntl64(4, 2, 1, 0x0804e16e, 4)      = 0
17:30:32 <... opendir resumed> )                  = 0x08050f58
17:30:32 readdir(0x08050f58 <unfinished ...>
17:30:32 SYS_getdents64(4, 0x08050f88, 4096, 2, 4) = 48
17:30:32 <... readdir resumed> )                  = 0x08050f88
17:30:32 readdir(0x08050f58)                      = 0x08050f98
17:30:32 readdir(0x08050f58 <unfinished ...>
17:30:32 SYS_getdents64(4, 0x08050f88, 4096, 2, 4) = 0
17:30:32 <... readdir resumed> )                  = NULL
17:30:32 closedir(0x08050f58 <unfinished ...>
17:30:32 SYS_close(4)                             = 0
17:30:32 <... closedir resumed> )                 = 0
17:30:32 opendir("/var/lib/nfs/sm.bak" <unfinished ...>
17:30:32 SYS_open("/var/lib/nfs/sm.bak", 100352, 00) = 4
17:30:32 SYS_fstat64(4, 0xbffffc3c, 0x40150aa0, 0x401544ec, 4) = 0
17:30:32 SYS_fcntl64(4, 2, 1, 0x0804db40, 4)      = 0
17:30:32 <... opendir resumed> )                  = 0x08050f58
17:30:32 readdir(0x08050f58 <unfinished ...>
17:30:32 SYS_getdents64(4, 0x08050f88, 4096, 2, 4) = 48
17:30:32 <... readdir resumed> )                  = 0x08050f88
17:30:32 readdir(0x08050f58)                      = 0x08050f98
17:30:32 readdir(0x08050f58 <unfinished ...>
17:30:32 SYS_getdents64(4, 0x08050f88, 4096, 2, 4) = 0
17:30:32 <... readdir resumed> )                  = NULL
17:30:32 closedir(0x08050f58 <unfinished ...>
17:30:32 SYS_close(4)                             = 0
17:30:32 <... closedir resumed> )                 = 0
17:30:32 getsockname(0, 0xbffffc9c, 0xbffffc98, 0x400d51db, -1 <unfinished ...>
17:30:32 SYS_socketcall(6, 0xbffffc64, -1, 0, 0)  = -88
17:30:32 <... getsockname resumed> )              = -1
17:30:32 pmap_unset(100024, 1, 0xbffffc98, 0x400d51db, -1 <unfinished ...>
17:30:32 SYS_socketcall(1, 0xbfffdba4, 0x4014fe48, 0xbffffc4c, 0) = 4
17:30:32 SYS_ioctl(4, 35090, 0xbfffdbe4, 0xbfffdbe4, 0) = 0
17:30:32 SYS_ioctl(4, 35091, 0xbfffdbec, 0xbfffdc2c, 0xbfffdc0c) = 0
17:30:32 SYS_close(4)                             = 0
17:30:32 SYS_socketcall(1, 0xbffffb94, 0x4014fe48, 0x08050f58, 0x08050f90) = 4
17:30:32 SYS_socketcall(2, 0xbffffb54, 0x4014fe48, 0xbffffb7c, -1) = 0
17:30:32 SYS_ioctl(4, 21537, 0xbffffbc8, 0x08050f58, 0x08050f90) = 0
17:30:32 SYS_socketcall(14, 0xbffffb84, 0x4014fe48, 0x08050f58, 0x08050f90) = 0
17:30:32 xdr_pmap(0x08050f90, 0xbffffc3c, 0xbffffb4c, 0x40120189, 0x4014fe48) = 1
17:30:32 SYS_socketcall(11, 0xbffffb04, 0x4014fe48, 625, 0) = 56
17:30:32 SYS_poll(0xbffffb70, 1, 5000, 5000, 0xbffffb70) = 1
17:30:32 SYS_socketcall(12, 0xbffffb04, 0x4014fe48, 0xbffffbec, 0xbffffb64) = 28
17:30:32 SYS_close(4)                             = 0
17:30:32 <... pmap_unset resumed> )               = 0
17:30:32 socket(2, 2, 17 <unfinished ...>
17:30:32 SYS_socketcall(1, 0xbffffc24, -1, -1, 0) = 4
17:30:32 <... socket resumed> )                   = 4
17:30:32 setsockopt(4, 1, 2, 0xbffffc48, 4 <unfinished ...>
17:30:32 SYS_socketcall(14, 0xbffffc14, 4, -1, 0) = 0
17:30:32 <... setsockopt resumed> )               = 0
17:30:32 bind(4, 0xbffffc4c, 16, 4096, -1 <unfinished ...>
17:30:32 SYS_socketcall(2, 0xbffffc24, 4, -1, 0)  = 0
17:30:32 <... bind resumed> )                     = 0
17:30:32 svcudp_create(4, 17, 0xbffffc98, 0x400d51db, -1 <unfinished ...>
17:30:32 SYS_socketcall(2, 0xbffffba4, 0x4014fe48, 0xbffffc1c, -1) = -22
17:30:32 SYS_socketcall(2, 0xbffffbe4, 0x4014fe48, 0xbffffc1c, 0) = -22
17:30:32 SYS_socketcall(6, 0xbffffbe4, 0x4014fe48, 0xbffffc1c, 0) = 0
17:30:32 SYS_brk(0x08055000)                      = 0x08055000
17:30:32 SYS_socketcall(14, 0xbffffbd4, 0x4014fe48, 0x08050f58, 0x080510b0) = 0
17:30:32 SYS_ugetrlimit(7, 0xbffffb78, -1, 0x40153740, 7) = 0
17:30:32 SYS_mmap(0xbffffaf4, 0x003fffe0, 0x4014fe48, 0x00400000, 0x80000000) = 0x4015e000
17:30:32 <... svcudp_create resumed> )            = 0x08050f58
17:30:32 svc_register(0x08050f58, 100024, 1, 0x0804ad10, 17 <unfinished ...>
17:30:32 SYS_socketcall(1, 0xbfffdb54, 0x4014fe48, 0xbffffc0c, 48835) = 5
17:30:32 SYS_ioctl(5, 35090, 0xbfffdb94, 0xbfffdb94, 48835) = 0
17:30:32 SYS_ioctl(5, 35091, 0xbfffdb9c, 0xbfffdbdc, 0xbfffdbbc) = 0
17:30:32 SYS_close(5)                             = 0
17:30:32 SYS_socketcall(1, 0xbffffb44, 0x4014fe48, 0x080534b0, 0x080534e8) = 5
17:30:32 SYS_socketcall(2, 0xbffffb04, 0x4014fe48, 0xbffffb2c, -1) = 0
17:30:32 SYS_ioctl(5, 21537, 0xbffffb78, 0x080534b0, 0x080534e8) = 0
17:30:32 SYS_socketcall(14, 0xbffffb34, 0x4014fe48, 0x080534b0, 0x080534e8) = 0
17:30:32 xdr_pmap(0x080534e8, 0xbffffbfc, 0xbffffafc, 0x40120189, 0x4014fe48) = 1
17:30:32 SYS_socketcall(11, 0xbffffab4, 0x4014fe48, 625, 0) = 56
17:30:32 SYS_poll(0xbffffb20, 1, 5000, 5000, 0xbffffb20) = 1
17:30:32 SYS_socketcall(12, 0xbffffab4, 0x4014fe48, 0xbffffb9c, 0xbffffb14) = 28
17:30:32 SYS_close(5)                             = 0
17:30:32 <... svc_register resumed> )             = 1
17:30:32 socket(2, 1, 6 <unfinished ...>
17:30:32 SYS_socketcall(1, 0xbffffc24, 0x08050f58, 4, 0) = 5
17:30:32 <... socket resumed> )                   = 5
17:30:32 setsockopt(5, 1, 2, 0xbffffc48, 4 <unfinished ...>
17:30:32 SYS_socketcall(14, 0xbffffc14, 5, 4, 0)  = 0
17:30:32 <... setsockopt resumed> )               = 0
17:30:32 bind(5, 0xbffffc4c, 16, 48835, 0x08050f58 <unfinished ...>
17:30:32 SYS_socketcall(2, 0xbffffc24, 5, 4, 0)   = 0
17:30:32 <... bind resumed> )                     = 0
17:30:32 svctcp_create(5, 0, 0, 0x400d51db, -1 <unfinished ...>
17:30:32 SYS_socketcall(2, 0xbffffbd4, 0x4014fe48, 0xbffffc4c, -1) = -22
17:30:32 SYS_socketcall(2, 0xbffffc14, 0x4014fe48, 0xbffffc4c, 5) = -22
17:30:32 SYS_socketcall(6, 0xbffffc14, 0x4014fe48, 0xbffffc4c, 5) = 0
17:30:32 SYS_socketcall(4, 0xbffffc14, 0x4014fe48, 0xbffffc4c, 5) = 0
17:30:32 <... svctcp_create resumed> )            = 0x080534b0
17:30:32 svc_register(0x080534b0, 100024, 1, 0x0804ad10, 6 <unfinished ...>
17:30:32 SYS_socketcall(1, 0xbfffdb54, 0x4014fe48, 0xbffffc0c, 37174) = 6
17:30:32 SYS_ioctl(6, 35090, 0xbfffdb94, 0xbfffdb94, 37174) = 0
17:30:32 SYS_ioctl(6, 35091, 0xbfffdb9c, 0xbfffdbdc, 0xbfffdbbc) = 0
17:30:32 SYS_close(6)                             = 0
17:30:32 SYS_socketcall(1, 0xbffffb44, 0x4014fe48, 0x080535e8, 0x08053620) = 6
17:30:32 SYS_socketcall(2, 0xbffffb04, 0x4014fe48, 0xbffffb2c, -1) = 0
17:30:32 SYS_ioctl(6, 21537, 0xbffffb78, 0x080535e8, 0x08053620) = 0
17:30:32 SYS_socketcall(14, 0xbffffb34, 0x4014fe48, 0x080535e8, 0x08053620) = 0
17:30:32 xdr_pmap(0x08053620, 0xbffffbfc, 0xbffffafc, 0x40120189, 0x4014fe48) = 1
17:30:33 SYS_socketcall(11, 0xbffffab4, 0x4014fe48, 625, 0) = 56
17:30:33 SYS_poll(0xbffffb20, 1, 5000, 5000, 0xbffffb20) = 1
17:30:33 SYS_socketcall(12, 0xbffffab4, 0x4014fe48, 0xbffffb9c, 0xbffffb14) = 28
17:30:33 SYS_close(6)                             = 0
17:30:33 <... svc_register resumed> )             = 1
17:30:33 __rpc_thread_svc_fdset(-1, 0xbffffd64, 0, 0x080509d0, 0) = 0x40154c00
17:30:33 vsnprintf("Waiting for client connections.", 1024, "Waiting for client connections.", 0xbffffc2c) = 31
17:30:33 time(0xbffff818 <unfinished ...>
17:30:33 SYS_time(0xbffff818, 0xbffff70c, 0xbffff818, 7, 0xbffff81c) = 0x3e921829
17:30:33 <... time resumed> )                     = 1049761833
17:30:33 localtime(0xbffff818)                    = 0x401544a0
17:30:33 fprintf(0x4014d380, "%02d/%02d/%04d %02d:%02d:%02d %s"..., 4, 7, 2003, 17, 30, 33, "rpc.statd" <unfinished ...>
17:30:33 SYS_write(2, "04/07/2003 17:30:33 rpc.statd[16"..., 7004/07/2003 17:30:33 rpc.statd[16103]: Waiting for client connections.
) = 70
17:30:33 <... fprintf resumed> )                  = 70
17:30:33 select(1024, 0xbffffc5c, 0, 0, 0 <unfinished ...>
17:30:33 SYS__newselect(1024, 0xbffffc5c, 0, 0, 0) = -514
17:38:58 --- SIGWINCH (Window changed) ---
17:38:58 SYS__newselect(1024, 0xbffffc5c, 0, 0, 0) = -514
17:38:58 --- SIGWINCH (Window changed) ---
17:38:58 SYS__newselect(1024, 0xbffffc5c, 0, 0, 0) = -514
17:38:59 --- SIGWINCH (Window changed) ---
17:38:59 SYS__newselect(1024, 0xbffffc5c, 0, 0, 0) = -514
17:38:59 --- SIGWINCH (Window changed) ---
17:38:59 SYS__newselect(1024, 0xbffffc5c, 0, 0, 0) = 1
09:32:42 <... select resumed> )                   = 1
09:32:42 svc_getreqset(0xbffffc5c, 0x0804e220, 0xbffffcdc, 0x0804b823, -1 <unfinished ...>
09:32:42 SYS_socketcall(17, 0xbffff654, 0x4014fe48, 0x08050f68, 16) = 76
09:32:42 socket(2, 2, 0 <unfinished ...>
09:32:42 SYS_socketcall(1, 0xbfffd5c4, 0x08050f68, 100024, 3) = 6
09:32:42 <... socket resumed> )                   = 6
09:32:42 ioctl(6, 35090, 0xbfffd5f4 <unfinished ...>
09:32:42 SYS_ioctl(6, 35090, 0xbfffd5f4, 0xbfffd5f4, 3) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 malloc(4)                                = 0x080509a8
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 malloc(8)                                = 0x080509f8
09:32:42 memcpy(0x080509f8, "\177", 4)            = 0x080509f8
09:32:42 free(0x080509a8)                         = <void>
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 malloc(16)                               = 0x08050a08
09:32:42 memcpy(0x08050a08, "\177", 8)            = 0x08050a08
09:32:42 free(0x080509f8)                         = <void>
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 malloc(32)                               = 0x08050a20
09:32:42 memcpy(0x08050a20, "\177", 16)           = 0x08050a20
09:32:42 free(0x08050a08)                         = <void>
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 malloc(64)                               = 0x080535e8
09:32:42 memcpy(0x080535e8, "\177", 32)           = 0x080535e8
09:32:42 free(0x08050a20)                         = <void>
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 malloc(128)                              = 0x08053630
09:32:42 memcpy(0x08053630, "\177", 64)           = 0x08053630
09:32:42 free(0x080535e8)                         = <void>
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 malloc(256)                              = 0x080536b8
09:32:42 memcpy(0x080536b8, "\177", 128)          = 0x080536b8
09:32:42 free(0x08053630)                         = <void>
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:42 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:42 <... ioctl resumed> )                    = 0
09:32:42 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:43 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:43 <... ioctl resumed> )                    = 0
09:32:43 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:43 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:43 <... ioctl resumed> )                    = 0
09:32:43 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:43 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:43 <... ioctl resumed> )                    = 0
09:32:43 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:43 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:43 <... ioctl resumed> )                    = 0
09:32:43 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:43 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:43 <... ioctl resumed> )                    = 0
09:32:43 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:43 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:43 <... ioctl resumed> )                    = 0
09:32:43 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:43 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:43 <... ioctl resumed> )                    = 0
09:32:43 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:43 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:43 <... ioctl resumed> )                    = 0
09:32:43 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:43 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:43 <... ioctl resumed> )                    = 0
09:32:43 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:43 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:43 <... ioctl resumed> )                    = 0
09:32:43 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:43 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:43 <... ioctl resumed> )                    = 0
09:32:43 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:43 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:43 <... ioctl resumed> )                    = 0
09:32:43 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
09:32:43 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:43 <... ioctl resumed> )                    = 0
09:32:43 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
09:32:43 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
09:32:43 <... ioctl resumed> )                    = 0
09:32:43 close(6 <unfinished ...>
09:32:43 SYS_close(6)                             = 0
09:32:43 <... close resumed> )                    = 0
09:32:43 xdr_string(0x08051098, 0xbffff648, 1024, 0x4015664d, 0x4014fe48) = 1
09:32:43 xdr_string(0x08051098, 0xbffff64c, 1024, 0x40125506, 0xbffff648) = 1
09:32:43 xdr_int(0x08051098, 0xbffff650, 1024, 0x40125506, 0xbffff648) = 1
09:32:43 xdr_int(0x08051098, 0xbffff654, 1024, 0x40125506, 0xbffff648) = 1
09:32:43 xdr_int(0x08051098, 0xbffff658, 1024, 0x40125506, 0xbffff648) = 1
09:32:43 vsnprintf("Received SM_UNMON request from d"..., 1024, "Received SM_UNMON request from %"..., 0xbffff5ec) = 82
09:32:43 time(0xbffff1d8 <unfinished ...>
09:32:43 SYS_time(0xbffff1d8, 32, 0xbffff1d8, 5, 0xbffff1dc) = 0x3e92f9ab
09:32:43 <... time resumed> )                     = 1049819563
09:32:43 localtime(0xbffff1d8)                    = 0x401544a0
09:32:43 fprintf(0x4014d380, "%02d/%02d/%04d %02d:%02d:%02d %s"..., 4, 8, 2003, 9, 32, 43, "rpc.statd" <unfinished ...>
09:32:43 SYS_write(2, "04/08/2003 09:32:43 rpc.statd[16"..., 12104/08/2003 09:32:43 rpc.statd[16103]: Received SM_UNMON request from dali for 10.3.34.97 while not monitoring any hosts.
) = 121
09:32:43 <... fprintf resumed> )                  = 121
09:32:43 svc_sendreply(0x08050f58, 0x08049f84, 0x0804fe48, 0x0804d5d3, 0x08050f58 <unfinished ...>
09:32:43 xdr_int(0x08051098, 0x0804fe48, 0x08051098, 0x0eb86024, 0x0eb86024) = 1
09:32:43 SYS_socketcall(16, 0xbffff574, 0x4014fe48, 28, 0x08051098) = 28
09:32:43 <... svc_sendreply resumed> )            = 1
09:32:43 xdr_string(0x08051098, 0xbffff648, 1024, 0x40122b45, 0x4014fe48) = 1
09:32:43 xdr_string(0x08051098, 0xbffff64c, 1024, 0x40125506, 0xbffff648) = 1
09:32:43 xdr_int(0x08051098, 0xbffff650, 1024, 0x40125506, 0xbffff648) = 1
09:32:43 xdr_int(0x08051098, 0xbffff654, 1024, 0x40125506, 0xbffff648) = 1
09:32:43 xdr_int(0x08051098, 0xbffff658, 1024, 0x40125506, 0xbffff648) = 1
09:32:43 --- SIGSEGV (Segmentation fault) ---
09:32:43 +++ killed by SIGSEGV +++

--------------060901060706000808050600--




-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
