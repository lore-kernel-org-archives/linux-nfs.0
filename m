From: Marshall McMullen <mjmcmullen@cox.net>
Subject: Re: rpc.mountd segfault
Date: Fri, 29 Apr 2005 10:41:25 -0700
Message-ID: <427271C5.5010505@cox.net>
References: <4271C9A7.50601@cox.net> <4271CB2E.9060501@cox.net> <427270B1.8040004@cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DRZV3-0006Xc-G0
	for nfs@lists.sourceforge.net; Fri, 29 Apr 2005 10:42:01 -0700
Received: from fed1rmmtao12.cox.net ([68.230.241.27])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DRZV2-000143-TL
	for nfs@lists.sourceforge.net; Fri, 29 Apr 2005 10:42:01 -0700
Received: from ghostwheel.localdomain ([24.255.16.18])
          by fed1rmmtao12.cox.net
          (InterMail vM.6.01.04.00 201-2131-118-20041027) with ESMTP
          id <20050429174151.XJHO550.fed1rmmtao12.cox.net@ghostwheel.localdomain>
          for <nfs@lists.sourceforge.net>; Fri, 29 Apr 2005 13:41:51 -0400
Received: from [192.168.0.2] (teiwaz.localdomain [192.168.0.2])
	by ghostwheel.localdomain (Postfix) with ESMTP id 2FF43A05DD
	for <nfs@lists.sourceforge.net>; Fri, 29 Apr 2005 03:41:43 -0700 (MST)
To: nfs@lists.sourceforge.net
In-Reply-To: <427270B1.8040004@cox.net>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I'm now using the following nsswitch.conf file and ldap works, and nfs
no longer segfaults.

passwd:      files ldap
shadow:      files ldap
group:       files ldap

# passwd:    db files nis
# shadow:    db files nis
# group:     db files nis

hosts:       files ldap dns
networks:    files dns

services:    db files
protocols:   db files
rpc:         db files
ethers:      db files
netmasks:    files ldap
netgroup:    files ldap
bootparams:  files

automount:   files ldap
aliases:     files ldap


Marshall McMullen wrote:

>My hunch was right -- this definitely has something to do with ldap.  I
>copied my original nsswitch.conf that has no ldap settings and now it no
>longer segfaults.  Here is the offending nsswitch.conf file that causes
>the aforementioned segfault:
>
>#ident $Id: nsswitch.ldap,v 2.4 2003/10/02 02:36:25 lukeh Exp $
>#
># An example file that could be copied over to /etc/nsswitch.conf; it
># uses LDAP conjunction with files.
>#
># "hosts:" and "services:" in this file are used only if the
># /etc/netconfig file has a "-" for nametoaddr_libs of "inet" transports.
>
># the following two lines obviate the "+" entry in /etc/passwd and
>/etc/group.
>passwd:         files ldap
>shadow:         fiels ldap     
>group:          files ldap     
>                               
># consult files/dns first, we will need it to resolve the LDAP host. (If we
># can't resolve it, we're in infinite recursion, because libldap calls
># gethostbyname(). Careful!)   
>hosts:          files dns ldap 
>                               
># LDAP is nominally authoritative for the following maps.
>services:   ldap [NOTFOUND=return] files
>networks:   ldap [NOTFOUND=return] files
>protocols:  ldap [NOTFOUND=return] files
>rpc:        ldap [NOTFOUND=return] files
>ethers:     ldap [NOTFOUND=return] files
>                               
># no support for netmasks, bootparams, publickey yet.
>netmasks:   files              
>bootparams: files              
>publickey:  files              
>automount:  ldap               
>                               
># I'm pretty sure nsswitch.conf is consulted directly by sendmail,
># here, so we can't do much here. Instead, use bbense's LDAP
># rules ofr sendmail.          
>aliases:    files              
>sendmailvars:   files          
>                               
># Note: there is no support for netgroups on Solaris (yet)
>netgroup:   ldap [NOTFOUND=return] files
>
>
>Marshall McMullen wrote:
>
>  
>
>>As additional insight here, I've recompiled the source with debugging on
>>and ran it through gdb and get the following:
>>
>>Program received signal SIGSEGV, Segmentation fault.
>>svc_socket (number=100005, type=0, protocol=87264, reuse=1) at
>>svc_socket.c:93
>>93            addr.sin_port = servp->s_port;
>>
>>Here is a backtrace:
>>
>>(gdb) bt
>>#0  svc_socket (number=100005, type=0, protocol=87264, reuse=1) at
>>svc_socket.c:93
>>#1  0x08051fec in rpc_init (name=0x805477d "mountd", prog=100005,
>>vers=1, dispatch=0x804b4a0 <mount_dispatch>, defport=0) at rpcmisc.c:83
>>#2  0x0804b3e1 in main (argc=-1073743936, argv=0x2) at mountd.c:558
>>
>>Any ideas would be greatly appreciated.
>>
>>Marshall McMullen wrote:
>>
>> 
>>
>>    
>>
>>>Hello,
>>>
>>>I've recently upgraded glibc to 2.3.5 and suddenly when I try to start
>>>rpc.mountd it immediately segfaults (strace attached).  I suspect this
>>>has something to do with the fact that I am using OpenLDAP, but I am not
>>>entirely sure.  I have tried downgrading glibc and recompiling nfs-utils
>>>but it still segfaults.
>>>
>>>Any ideas?
>>>
>>>
>>>
>>>------------------------------------------------------------------------
>>>
>>>execve("/usr/sbin/rpc.mountd", ["/usr/sbin/rpc.mountd"], [/* 39 vars */]) = 0
>>>uname({sys="Linux", node="gebo", ...})  = 0
>>>brk(0)                                  = 0x805e000
>>>access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
>>>open("/etc/ld.so.cache", O_RDONLY)      = 3
>>>fstat64(3, {st_mode=S_IFREG|0644, st_size=60778, ...}) = 0
>>>mmap2(NULL, 60778, PROT_READ, MAP_PRIVATE, 3, 0) = 0xb7fdb000
>>>close(3)                                = 0
>>>open("/lib/libwrap.so.0", O_RDONLY)     = 3
>>>read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\240\36"..., 512) = 512
>>>fstat64(3, {st_mode=S_IFREG|0755, st_size=29464, ...}) = 0
>>>mmap2(NULL, 32164, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7fd3000
>>>mmap2(0xb7fda000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x6) = 0xb7fda000
>>>close(3)                                = 0
>>>open("/lib/libnsl.so.1", O_RDONLY)      = 3
>>>read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0@5\0\000"..., 512) = 512
>>>fstat64(3, {st_mode=S_IFREG|0755, st_size=80736, ...}) = 0
>>>mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7fd2000
>>>mmap2(NULL, 88064, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7fbc000
>>>mmap2(0xb7fce000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x11) = 0xb7fce000
>>>mmap2(0xb7fd0000, 6144, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb7fd0000
>>>close(3)                                = 0
>>>open("/lib/libc.so.6", O_RDONLY)        = 3
>>>read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\340T\1"..., 512) = 512
>>>fstat64(3, {st_mode=S_IFREG|0755, st_size=1309984, ...}) = 0
>>>mmap2(NULL, 1219892, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0xb7e92000
>>>mprotect(0xb7fb5000, 27956, PROT_NONE)  = 0
>>>mmap2(0xb7fb6000, 16384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x123) = 0xb7fb6000
>>>mmap2(0xb7fba000, 7476, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb7fba000
>>>close(3)                                = 0
>>>mprotect(0xb7fb6000, 4096, PROT_READ)   = 0
>>>munmap(0xb7fdb000, 60778)               = 0
>>>open("/dev/urandom", O_RDONLY)          = 3
>>>read(3, "\300lY\220", 4)                = 4
>>>close(3)                                = 0
>>>chdir("/var/lib/nfs")                   = 0
>>>getrlimit(RLIMIT_NOFILE, {rlim_cur=1024, rlim_max=1024}) = 0
>>>rt_sigaction(SIGHUP, {SIG_IGN}, NULL, 8) = 0
>>>rt_sigaction(SIGINT, {SIG_IGN}, NULL, 8) = 0
>>>rt_sigaction(SIGTERM, {SIG_IGN}, NULL, 8) = 0
>>>rt_sigaction(SIGPIPE, {SIG_IGN}, NULL, 8) = 0
>>>rt_sigaction(SIGCHLD, {SIG_IGN}, NULL, 8) = 0
>>>getrlimit(RLIMIT_NOFILE, {rlim_cur=1024, rlim_max=1024}) = 0
>>>close(1023)                             = -1 EBADF (Bad file descriptor)
>>>close(1022)                             = -1 EBADF (Bad file descriptor)
>>>close(1021)                             = -1 EBADF (Bad file descriptor)
>>>close(1020)                             = -1 EBADF (Bad file descriptor)
>>>close(1019)                             = -1 EBADF (Bad file descriptor)
>>>close(1018)                             = -1 EBADF (Bad file descriptor)
>>>close(1017)                             = -1 EBADF (Bad file descriptor)
>>>close(1016)                             = -1 EBADF (Bad file descriptor)
>>>close(1015)                             = -1 EBADF (Bad file descriptor)
>>>close(1014)                             = -1 EBADF (Bad file descriptor)
>>>close(1013)                             = -1 EBADF (Bad file descriptor)
>>>close(1012)                             = -1 EBADF (Bad file descriptor)
>>>close(1011)                             = -1 EBADF (Bad file descriptor)
>>>close(1010)                             = -1 EBADF (Bad file descriptor)
>>>close(1009)                             = -1 EBADF (Bad file descriptor)
>>>close(1008)                             = -1 EBADF (Bad file descriptor)
>>>close(1007)                             = -1 EBADF (Bad file descriptor)
>>>close(1006)                             = -1 EBADF (Bad file descriptor)
>>>close(1005)                             = -1 EBADF (Bad file descriptor)
>>>close(1004)                             = -1 EBADF (Bad file descriptor)
>>>close(1003)                             = -1 EBADF (Bad file descriptor)
>>>close(1002)                             = -1 EBADF (Bad file descriptor)
>>>close(1001)                             = -1 EBADF (Bad file descriptor)
>>>close(1000)                             = -1 EBADF (Bad file descriptor)
>>>close(999)                              = -1 EBADF (Bad file descriptor)
>>>close(998)                              = -1 EBADF (Bad file descriptor)
>>>close(997)                              = -1 EBADF (Bad file descriptor)
>>>close(996)                              = -1 EBADF (Bad file descriptor)
>>>close(995)                              = -1 EBADF (Bad file descriptor)
>>>close(994)                              = -1 EBADF (Bad file descriptor)
>>>close(993)                              = -1 EBADF (Bad file descriptor)
>>>close(992)                              = -1 EBADF (Bad file descriptor)
>>>close(991)                              = -1 EBADF (Bad file descriptor)
>>>close(990)                              = -1 EBADF (Bad file descriptor)
>>>close(989)                              = -1 EBADF (Bad file descriptor)
>>>close(988)                              = -1 EBADF (Bad file descriptor)
>>>close(987)                              = -1 EBADF (Bad file descriptor)
>>>close(986)                              = -1 EBADF (Bad file descriptor)
>>>close(985)                              = -1 EBADF (Bad file descriptor)
>>>close(984)                              = -1 EBADF (Bad file descriptor)
>>>close(983)                              = -1 EBADF (Bad file descriptor)
>>>close(982)                              = -1 EBADF (Bad file descriptor)
>>>close(981)                              = -1 EBADF (Bad file descriptor)
>>>close(980)                              = -1 EBADF (Bad file descriptor)
>>>close(979)                              = -1 EBADF (Bad file descriptor)
>>>close(978)                              = -1 EBADF (Bad file descriptor)
>>>close(977)                              = -1 EBADF (Bad file descriptor)
>>>close(976)                              = -1 EBADF (Bad file descriptor)
>>>close(975)                              = -1 EBADF (Bad file descriptor)
>>>close(974)                              = -1 EBADF (Bad file descriptor)
>>>close(973)                              = -1 EBADF (Bad file descriptor)
>>>close(972)                              = -1 EBADF (Bad file descriptor)
>>>close(971)                              = -1 EBADF (Bad file descriptor)
>>>close(970)                              = -1 EBADF (Bad file descriptor)
>>>close(969)                              = -1 EBADF (Bad file descriptor)
>>>close(968)                              = -1 EBADF (Bad file descriptor)
>>>close(967)                              = -1 EBADF (Bad file descriptor)
>>>close(966)                              = -1 EBADF (Bad file descriptor)
>>>close(965)                              = -1 EBADF (Bad file descriptor)
>>>close(964)                              = -1 EBADF (Bad file descriptor)
>>>close(963)                              = -1 EBADF (Bad file descriptor)
>>>close(962)                              = -1 EBADF (Bad file descriptor)
>>>close(961)                              = -1 EBADF (Bad file descriptor)
>>>close(960)                              = -1 EBADF (Bad file descriptor)
>>>close(959)                              = -1 EBADF (Bad file descriptor)
>>>close(958)                              = -1 EBADF (Bad file descriptor)
>>>close(957)                              = -1 EBADF (Bad file descriptor)
>>>close(956)                              = -1 EBADF (Bad file descriptor)
>>>close(955)                              = -1 EBADF (Bad file descriptor)
>>>close(954)                              = -1 EBADF (Bad file descriptor)
>>>close(953)                              = -1 EBADF (Bad file descriptor)
>>>close(952)                              = -1 EBADF (Bad file descriptor)
>>>close(951)                              = -1 EBADF (Bad file descriptor)
>>>close(950)                              = -1 EBADF (Bad file descriptor)
>>>close(949)                              = -1 EBADF (Bad file descriptor)
>>>close(948)                              = -1 EBADF (Bad file descriptor)
>>>close(947)                              = -1 EBADF (Bad file descriptor)
>>>close(946)                              = -1 EBADF (Bad file descriptor)
>>>close(945)                              = -1 EBADF (Bad file descriptor)
>>>close(944)                              = -1 EBADF (Bad file descriptor)
>>>close(943)                              = -1 EBADF (Bad file descriptor)
>>>close(942)                              = -1 EBADF (Bad file descriptor)
>>>close(941)                              = -1 EBADF (Bad file descriptor)
>>>close(940)                              = -1 EBADF (Bad file descriptor)
>>>close(939)                              = -1 EBADF (Bad file descriptor)
>>>close(938)                              = -1 EBADF (Bad file descriptor)
>>>close(937)                              = -1 EBADF (Bad file descriptor)
>>>close(936)                              = -1 EBADF (Bad file descriptor)
>>>close(935)                              = -1 EBADF (Bad file descriptor)
>>>close(934)                              = -1 EBADF (Bad file descriptor)
>>>close(933)                              = -1 EBADF (Bad file descriptor)
>>>close(932)                              = -1 EBADF (Bad file descriptor)
>>>close(931)                              = -1 EBADF (Bad file descriptor)
>>>close(930)                              = -1 EBADF (Bad file descriptor)
>>>close(929)                              = -1 EBADF (Bad file descriptor)
>>>close(928)                              = -1 EBADF (Bad file descriptor)
>>>close(927)                              = -1 EBADF (Bad file descriptor)
>>>close(926)                              = -1 EBADF (Bad file descriptor)
>>>close(925)                              = -1 EBADF (Bad file descriptor)
>>>close(924)                              = -1 EBADF (Bad file descriptor)
>>>close(923)                              = -1 EBADF (Bad file descriptor)
>>>close(922)                              = -1 EBADF (Bad file descriptor)
>>>close(921)                              = -1 EBADF (Bad file descriptor)
>>>close(920)                              = -1 EBADF (Bad file descriptor)
>>>close(919)                              = -1 EBADF (Bad file descriptor)
>>>close(918)                              = -1 EBADF (Bad file descriptor)
>>>close(917)                              = -1 EBADF (Bad file descriptor)
>>>close(916)                              = -1 EBADF (Bad file descriptor)
>>>close(915)                              = -1 EBADF (Bad file descriptor)
>>>close(914)                              = -1 EBADF (Bad file descriptor)
>>>close(913)                              = -1 EBADF (Bad file descriptor)
>>>close(912)                              = -1 EBADF (Bad file descriptor)
>>>close(911)                              = -1 EBADF (Bad file descriptor)
>>>close(910)                              = -1 EBADF (Bad file descriptor)
>>>close(909)                              = -1 EBADF (Bad file descriptor)
>>>close(908)                              = -1 EBADF (Bad file descriptor)
>>>close(907)                              = -1 EBADF (Bad file descriptor)
>>>close(906)                              = -1 EBADF (Bad file descriptor)
>>>close(905)                              = -1 EBADF (Bad file descriptor)
>>>close(904)                              = -1 EBADF (Bad file descriptor)
>>>close(903)                              = -1 EBADF (Bad file descriptor)
>>>close(902)                              = -1 EBADF (Bad file descriptor)
>>>close(901)                              = -1 EBADF (Bad file descriptor)
>>>close(900)                              = -1 EBADF (Bad file descriptor)
>>>close(899)                              = -1 EBADF (Bad file descriptor)
>>>close(898)                              = -1 EBADF (Bad file descriptor)
>>>close(897)                              = -1 EBADF (Bad file descriptor)
>>>close(896)                              = -1 EBADF (Bad file descriptor)
>>>close(895)                              = -1 EBADF (Bad file descriptor)
>>>close(894)                              = -1 EBADF (Bad file descriptor)
>>>close(893)                              = -1 EBADF (Bad file descriptor)
>>>close(892)                              = -1 EBADF (Bad file descriptor)
>>>close(891)                              = -1 EBADF (Bad file descriptor)
>>>close(890)                              = -1 EBADF (Bad file descriptor)
>>>close(889)                              = -1 EBADF (Bad file descriptor)
>>>close(888)                              = -1 EBADF (Bad file descriptor)
>>>close(887)                              = -1 EBADF (Bad file descriptor)
>>>close(886)                              = -1 EBADF (Bad file descriptor)
>>>close(885)                              = -1 EBADF (Bad file descriptor)
>>>close(884)                              = -1 EBADF (Bad file descriptor)
>>>close(883)                              = -1 EBADF (Bad file descriptor)
>>>close(882)                              = -1 EBADF (Bad file descriptor)
>>>close(881)                              = -1 EBADF (Bad file descriptor)
>>>close(880)                              = -1 EBADF (Bad file descriptor)
>>>close(879)                              = -1 EBADF (Bad file descriptor)
>>>close(878)                              = -1 EBADF (Bad file descriptor)
>>>close(877)                              = -1 EBADF (Bad file descriptor)
>>>close(876)                              = -1 EBADF (Bad file descriptor)
>>>close(875)                              = -1 EBADF (Bad file descriptor)
>>>close(874)                              = -1 EBADF (Bad file descriptor)
>>>close(873)                              = -1 EBADF (Bad file descriptor)
>>>close(872)                              = -1 EBADF (Bad file descriptor)
>>>close(871)                              = -1 EBADF (Bad file descriptor)
>>>close(870)                              = -1 EBADF (Bad file descriptor)
>>>close(869)                              = -1 EBADF (Bad file descriptor)
>>>close(868)                              = -1 EBADF (Bad file descriptor)
>>>close(867)                              = -1 EBADF (Bad file descriptor)
>>>close(866)                              = -1 EBADF (Bad file descriptor)
>>>close(865)                              = -1 EBADF (Bad file descriptor)
>>>close(864)                              = -1 EBADF (Bad file descriptor)
>>>close(863)                              = -1 EBADF (Bad file descriptor)
>>>close(862)                              = -1 EBADF (Bad file descriptor)
>>>close(861)                              = -1 EBADF (Bad file descriptor)
>>>close(860)                              = -1 EBADF (Bad file descriptor)
>>>close(859)                              = -1 EBADF (Bad file descriptor)
>>>close(858)                              = -1 EBADF (Bad file descriptor)
>>>close(857)                              = -1 EBADF (Bad file descriptor)
>>>close(856)                              = -1 EBADF (Bad file descriptor)
>>>close(855)                              = -1 EBADF (Bad file descriptor)
>>>close(854)                              = -1 EBADF (Bad file descriptor)
>>>close(853)                              = -1 EBADF (Bad file descriptor)
>>>close(852)                              = -1 EBADF (Bad file descriptor)
>>>close(851)                              = -1 EBADF (Bad file descriptor)
>>>close(850)                              = -1 EBADF (Bad file descriptor)
>>>close(849)                              = -1 EBADF (Bad file descriptor)
>>>close(848)                              = -1 EBADF (Bad file descriptor)
>>>close(847)                              = -1 EBADF (Bad file descriptor)
>>>close(846)                              = -1 EBADF (Bad file descriptor)
>>>close(845)                              = -1 EBADF (Bad file descriptor)
>>>close(844)                              = -1 EBADF (Bad file descriptor)
>>>close(843)                              = -1 EBADF (Bad file descriptor)
>>>close(842)                              = -1 EBADF (Bad file descriptor)
>>>close(841)                              = -1 EBADF (Bad file descriptor)
>>>close(840)                              = -1 EBADF (Bad file descriptor)
>>>close(839)                              = -1 EBADF (Bad file descriptor)
>>>close(838)                              = -1 EBADF (Bad file descriptor)
>>>close(837)                              = -1 EBADF (Bad file descriptor)
>>>close(836)                              = -1 EBADF (Bad file descriptor)
>>>close(835)                              = -1 EBADF (Bad file descriptor)
>>>close(834)                              = -1 EBADF (Bad file descriptor)
>>>close(833)                              = -1 EBADF (Bad file descriptor)
>>>close(832)                              = -1 EBADF (Bad file descriptor)
>>>close(831)                              = -1 EBADF (Bad file descriptor)
>>>close(830)                              = -1 EBADF (Bad file descriptor)
>>>close(829)                              = -1 EBADF (Bad file descriptor)
>>>close(828)                              = -1 EBADF (Bad file descriptor)
>>>close(827)                              = -1 EBADF (Bad file descriptor)
>>>close(826)                              = -1 EBADF (Bad file descriptor)
>>>close(825)                              = -1 EBADF (Bad file descriptor)
>>>close(824)                              = -1 EBADF (Bad file descriptor)
>>>close(823)                              = -1 EBADF (Bad file descriptor)
>>>close(822)                              = -1 EBADF (Bad file descriptor)
>>>close(821)                              = -1 EBADF (Bad file descriptor)
>>>close(820)                              = -1 EBADF (Bad file descriptor)
>>>close(819)                              = -1 EBADF (Bad file descriptor)
>>>close(818)                              = -1 EBADF (Bad file descriptor)
>>>close(817)                              = -1 EBADF (Bad file descriptor)
>>>close(816)                              = -1 EBADF (Bad file descriptor)
>>>close(815)                              = -1 EBADF (Bad file descriptor)
>>>close(814)                              = -1 EBADF (Bad file descriptor)
>>>close(813)                              = -1 EBADF (Bad file descriptor)
>>>close(812)                              = -1 EBADF (Bad file descriptor)
>>>close(811)                              = -1 EBADF (Bad file descriptor)
>>>close(810)                              = -1 EBADF (Bad file descriptor)
>>>close(809)                              = -1 EBADF (Bad file descriptor)
>>>close(808)                              = -1 EBADF (Bad file descriptor)
>>>close(807)                              = -1 EBADF (Bad file descriptor)
>>>close(806)                              = -1 EBADF (Bad file descriptor)
>>>close(805)                              = -1 EBADF (Bad file descriptor)
>>>close(804)                              = -1 EBADF (Bad file descriptor)
>>>close(803)                              = -1 EBADF (Bad file descriptor)
>>>close(802)                              = -1 EBADF (Bad file descriptor)
>>>close(801)                              = -1 EBADF (Bad file descriptor)
>>>close(800)                              = -1 EBADF (Bad file descriptor)
>>>close(799)                              = -1 EBADF (Bad file descriptor)
>>>close(798)                              = -1 EBADF (Bad file descriptor)
>>>close(797)                              = -1 EBADF (Bad file descriptor)
>>>close(796)                              = -1 EBADF (Bad file descriptor)
>>>close(795)                              = -1 EBADF (Bad file descriptor)
>>>close(794)                              = -1 EBADF (Bad file descriptor)
>>>close(793)                              = -1 EBADF (Bad file descriptor)
>>>close(792)                              = -1 EBADF (Bad file descriptor)
>>>close(791)                              = -1 EBADF (Bad file descriptor)
>>>close(790)                              = -1 EBADF (Bad file descriptor)
>>>close(789)                              = -1 EBADF (Bad file descriptor)
>>>close(788)                              = -1 EBADF (Bad file descriptor)
>>>close(787)                              = -1 EBADF (Bad file descriptor)
>>>close(786)                              = -1 EBADF (Bad file descriptor)
>>>close(785)                              = -1 EBADF (Bad file descriptor)
>>>close(784)                              = -1 EBADF (Bad file descriptor)
>>>close(783)                              = -1 EBADF (Bad file descriptor)
>>>close(782)                              = -1 EBADF (Bad file descriptor)
>>>close(781)                              = -1 EBADF (Bad file descriptor)
>>>close(780)                              = -1 EBADF (Bad file descriptor)
>>>close(779)                              = -1 EBADF (Bad file descriptor)
>>>close(778)                              = -1 EBADF (Bad file descriptor)
>>>close(777)                              = -1 EBADF (Bad file descriptor)
>>>close(776)                              = -1 EBADF (Bad file descriptor)
>>>close(775)                              = -1 EBADF (Bad file descriptor)
>>>close(774)                              = -1 EBADF (Bad file descriptor)
>>>close(773)                              = -1 EBADF (Bad file descriptor)
>>>close(772)                              = -1 EBADF (Bad file descriptor)
>>>close(771)                              = -1 EBADF (Bad file descriptor)
>>>close(770)                              = -1 EBADF (Bad file descriptor)
>>>close(769)                              = -1 EBADF (Bad file descriptor)
>>>close(768)                              = -1 EBADF (Bad file descriptor)
>>>close(767)                              = -1 EBADF (Bad file descriptor)
>>>close(766)                              = -1 EBADF (Bad file descriptor)
>>>close(765)                              = -1 EBADF (Bad file descriptor)
>>>close(764)                              = -1 EBADF (Bad file descriptor)
>>>close(763)                              = -1 EBADF (Bad file descriptor)
>>>close(762)                              = -1 EBADF (Bad file descriptor)
>>>close(761)                              = -1 EBADF (Bad file descriptor)
>>>close(760)                              = -1 EBADF (Bad file descriptor)
>>>close(759)                              = -1 EBADF (Bad file descriptor)
>>>close(758)                              = -1 EBADF (Bad file descriptor)
>>>close(757)                              = -1 EBADF (Bad file descriptor)
>>>close(756)                              = -1 EBADF (Bad file descriptor)
>>>close(755)                              = -1 EBADF (Bad file descriptor)
>>>close(754)                              = -1 EBADF (Bad file descriptor)
>>>close(753)                              = -1 EBADF (Bad file descriptor)
>>>close(752)                              = -1 EBADF (Bad file descriptor)
>>>close(751)                              = -1 EBADF (Bad file descriptor)
>>>close(750)                              = -1 EBADF (Bad file descriptor)
>>>close(749)                              = -1 EBADF (Bad file descriptor)
>>>close(748)                              = -1 EBADF (Bad file descriptor)
>>>close(747)                              = -1 EBADF (Bad file descriptor)
>>>close(746)                              = -1 EBADF (Bad file descriptor)
>>>close(745)                              = -1 EBADF (Bad file descriptor)
>>>close(744)                              = -1 EBADF (Bad file descriptor)
>>>close(743)                              = -1 EBADF (Bad file descriptor)
>>>close(742)                              = -1 EBADF (Bad file descriptor)
>>>close(741)                              = -1 EBADF (Bad file descriptor)
>>>close(740)                              = -1 EBADF (Bad file descriptor)
>>>close(739)                              = -1 EBADF (Bad file descriptor)
>>>close(738)                              = -1 EBADF (Bad file descriptor)
>>>close(737)                              = -1 EBADF (Bad file descriptor)
>>>close(736)                              = -1 EBADF (Bad file descriptor)
>>>close(735)                              = -1 EBADF (Bad file descriptor)
>>>close(734)                              = -1 EBADF (Bad file descriptor)
>>>close(733)                              = -1 EBADF (Bad file descriptor)
>>>close(732)                              = -1 EBADF (Bad file descriptor)
>>>close(731)                              = -1 EBADF (Bad file descriptor)
>>>close(730)                              = -1 EBADF (Bad file descriptor)
>>>close(729)                              = -1 EBADF (Bad file descriptor)
>>>close(728)                              = -1 EBADF (Bad file descriptor)
>>>close(727)                              = -1 EBADF (Bad file descriptor)
>>>close(726)                              = -1 EBADF (Bad file descriptor)
>>>close(725)                              = -1 EBADF (Bad file descriptor)
>>>close(724)                              = -1 EBADF (Bad file descriptor)
>>>close(723)                              = -1 EBADF (Bad file descriptor)
>>>close(722)                              = -1 EBADF (Bad file descriptor)
>>>close(721)                              = -1 EBADF (Bad file descriptor)
>>>close(720)                              = -1 EBADF (Bad file descriptor)
>>>close(719)                              = -1 EBADF (Bad file descriptor)
>>>close(718)                              = -1 EBADF (Bad file descriptor)
>>>close(717)                              = -1 EBADF (Bad file descriptor)
>>>close(716)                              = -1 EBADF (Bad file descriptor)
>>>close(715)                              = -1 EBADF (Bad file descriptor)
>>>close(714)                              = -1 EBADF (Bad file descriptor)
>>>close(713)                              = -1 EBADF (Bad file descriptor)
>>>close(712)                              = -1 EBADF (Bad file descriptor)
>>>close(711)                              = -1 EBADF (Bad file descriptor)
>>>close(710)                              = -1 EBADF (Bad file descriptor)
>>>close(709)                              = -1 EBADF (Bad file descriptor)
>>>close(708)                              = -1 EBADF (Bad file descriptor)
>>>close(707)                              = -1 EBADF (Bad file descriptor)
>>>close(706)                              = -1 EBADF (Bad file descriptor)
>>>close(705)                              = -1 EBADF (Bad file descriptor)
>>>close(704)                              = -1 EBADF (Bad file descriptor)
>>>close(703)                              = -1 EBADF (Bad file descriptor)
>>>close(702)                              = -1 EBADF (Bad file descriptor)
>>>close(701)                              = -1 EBADF (Bad file descriptor)
>>>close(700)                              = -1 EBADF (Bad file descriptor)
>>>close(699)                              = -1 EBADF (Bad file descriptor)
>>>close(698)                              = -1 EBADF (Bad file descriptor)
>>>close(697)                              = -1 EBADF (Bad file descriptor)
>>>close(696)                              = -1 EBADF (Bad file descriptor)
>>>close(695)                              = -1 EBADF (Bad file descriptor)
>>>close(694)                              = -1 EBADF (Bad file descriptor)
>>>close(693)                              = -1 EBADF (Bad file descriptor)
>>>close(692)                              = -1 EBADF (Bad file descriptor)
>>>close(691)                              = -1 EBADF (Bad file descriptor)
>>>close(690)                              = -1 EBADF (Bad file descriptor)
>>>close(689)                              = -1 EBADF (Bad file descriptor)
>>>close(688)                              = -1 EBADF (Bad file descriptor)
>>>close(687)                              = -1 EBADF (Bad file descriptor)
>>>close(686)                              = -1 EBADF (Bad file descriptor)
>>>close(685)                              = -1 EBADF (Bad file descriptor)
>>>close(684)                              = -1 EBADF (Bad file descriptor)
>>>close(683)                              = -1 EBADF (Bad file descriptor)
>>>close(682)                              = -1 EBADF (Bad file descriptor)
>>>close(681)                              = -1 EBADF (Bad file descriptor)
>>>close(680)                              = -1 EBADF (Bad file descriptor)
>>>close(679)                              = -1 EBADF (Bad file descriptor)
>>>close(678)                              = -1 EBADF (Bad file descriptor)
>>>close(677)                              = -1 EBADF (Bad file descriptor)
>>>close(676)                              = -1 EBADF (Bad file descriptor)
>>>close(675)                              = -1 EBADF (Bad file descriptor)
>>>close(674)                              = -1 EBADF (Bad file descriptor)
>>>close(673)                              = -1 EBADF (Bad file descriptor)
>>>close(672)                              = -1 EBADF (Bad file descriptor)
>>>close(671)                              = -1 EBADF (Bad file descriptor)
>>>close(670)                              = -1 EBADF (Bad file descriptor)
>>>close(669)                              = -1 EBADF (Bad file descriptor)
>>>close(668)                              = -1 EBADF (Bad file descriptor)
>>>close(667)                              = -1 EBADF (Bad file descriptor)
>>>close(666)                              = -1 EBADF (Bad file descriptor)
>>>close(665)                              = -1 EBADF (Bad file descriptor)
>>>close(664)                              = -1 EBADF (Bad file descriptor)
>>>close(663)                              = -1 EBADF (Bad file descriptor)
>>>close(662)                              = -1 EBADF (Bad file descriptor)
>>>close(661)                              = -1 EBADF (Bad file descriptor)
>>>close(660)                              = -1 EBADF (Bad file descriptor)
>>>close(659)                              = -1 EBADF (Bad file descriptor)
>>>close(658)                              = -1 EBADF (Bad file descriptor)
>>>close(657)                              = -1 EBADF (Bad file descriptor)
>>>close(656)                              = -1 EBADF (Bad file descriptor)
>>>close(655)                              = -1 EBADF (Bad file descriptor)
>>>close(654)                              = -1 EBADF (Bad file descriptor)
>>>close(653)                              = -1 EBADF (Bad file descriptor)
>>>close(652)                              = -1 EBADF (Bad file descriptor)
>>>close(651)                              = -1 EBADF (Bad file descriptor)
>>>close(650)                              = -1 EBADF (Bad file descriptor)
>>>close(649)                              = -1 EBADF (Bad file descriptor)
>>>close(648)                              = -1 EBADF (Bad file descriptor)
>>>close(647)                              = -1 EBADF (Bad file descriptor)
>>>close(646)                              = -1 EBADF (Bad file descriptor)
>>>close(645)                              = -1 EBADF (Bad file descriptor)
>>>close(644)                              = -1 EBADF (Bad file descriptor)
>>>close(643)                              = -1 EBADF (Bad file descriptor)
>>>close(642)                              = -1 EBADF (Bad file descriptor)
>>>close(641)                              = -1 EBADF (Bad file descriptor)
>>>close(640)                              = -1 EBADF (Bad file descriptor)
>>>close(639)                              = -1 EBADF (Bad file descriptor)
>>>close(638)                              = -1 EBADF (Bad file descriptor)
>>>close(637)                              = -1 EBADF (Bad file descriptor)
>>>close(636)                              = -1 EBADF (Bad file descriptor)
>>>close(635)                              = -1 EBADF (Bad file descriptor)
>>>close(634)                              = -1 EBADF (Bad file descriptor)
>>>close(633)                              = -1 EBADF (Bad file descriptor)
>>>close(632)                              = -1 EBADF (Bad file descriptor)
>>>close(631)                              = -1 EBADF (Bad file descriptor)
>>>close(630)                              = -1 EBADF (Bad file descriptor)
>>>close(629)                              = -1 EBADF (Bad file descriptor)
>>>close(628)                              = -1 EBADF (Bad file descriptor)
>>>close(627)                              = -1 EBADF (Bad file descriptor)
>>>close(626)                              = -1 EBADF (Bad file descriptor)
>>>close(625)                              = -1 EBADF (Bad file descriptor)
>>>close(624)                              = -1 EBADF (Bad file descriptor)
>>>close(623)                              = -1 EBADF (Bad file descriptor)
>>>close(622)                              = -1 EBADF (Bad file descriptor)
>>>close(621)                              = -1 EBADF (Bad file descriptor)
>>>close(620)                              = -1 EBADF (Bad file descriptor)
>>>close(619)                              = -1 EBADF (Bad file descriptor)
>>>close(618)                              = -1 EBADF (Bad file descriptor)
>>>close(617)                              = -1 EBADF (Bad file descriptor)
>>>close(616)                              = -1 EBADF (Bad file descriptor)
>>>close(615)                              = -1 EBADF (Bad file descriptor)
>>>close(614)                              = -1 EBADF (Bad file descriptor)
>>>close(613)                              = -1 EBADF (Bad file descriptor)
>>>close(612)                              = -1 EBADF (Bad file descriptor)
>>>close(611)                              = -1 EBADF (Bad file descriptor)
>>>close(610)                              = -1 EBADF (Bad file descriptor)
>>>close(609)                              = -1 EBADF (Bad file descriptor)
>>>close(608)                              = -1 EBADF (Bad file descriptor)
>>>close(607)                              = -1 EBADF (Bad file descriptor)
>>>close(606)                              = -1 EBADF (Bad file descriptor)
>>>close(605)                              = -1 EBADF (Bad file descriptor)
>>>close(604)                              = -1 EBADF (Bad file descriptor)
>>>close(603)                              = -1 EBADF (Bad file descriptor)
>>>close(602)                              = -1 EBADF (Bad file descriptor)
>>>close(601)                              = -1 EBADF (Bad file descriptor)
>>>close(600)                              = -1 EBADF (Bad file descriptor)
>>>close(599)                              = -1 EBADF (Bad file descriptor)
>>>close(598)                              = -1 EBADF (Bad file descriptor)
>>>close(597)                              = -1 EBADF (Bad file descriptor)
>>>close(596)                              = -1 EBADF (Bad file descriptor)
>>>close(595)                              = -1 EBADF (Bad file descriptor)
>>>close(594)                              = -1 EBADF (Bad file descriptor)
>>>close(593)                              = -1 EBADF (Bad file descriptor)
>>>close(592)                              = -1 EBADF (Bad file descriptor)
>>>close(591)                              = -1 EBADF (Bad file descriptor)
>>>close(590)                              = -1 EBADF (Bad file descriptor)
>>>close(589)                              = -1 EBADF (Bad file descriptor)
>>>close(588)                              = -1 EBADF (Bad file descriptor)
>>>close(587)                              = -1 EBADF (Bad file descriptor)
>>>close(586)                              = -1 EBADF (Bad file descriptor)
>>>close(585)                              = -1 EBADF (Bad file descriptor)
>>>close(584)                              = -1 EBADF (Bad file descriptor)
>>>close(583)                              = -1 EBADF (Bad file descriptor)
>>>close(582)                              = -1 EBADF (Bad file descriptor)
>>>close(581)                              = -1 EBADF (Bad file descriptor)
>>>close(580)                              = -1 EBADF (Bad file descriptor)
>>>close(579)                              = -1 EBADF (Bad file descriptor)
>>>close(578)                              = -1 EBADF (Bad file descriptor)
>>>close(577)                              = -1 EBADF (Bad file descriptor)
>>>close(576)                              = -1 EBADF (Bad file descriptor)
>>>close(575)                              = -1 EBADF (Bad file descriptor)
>>>close(574)                              = -1 EBADF (Bad file descriptor)
>>>close(573)                              = -1 EBADF (Bad file descriptor)
>>>close(572)                              = -1 EBADF (Bad file descriptor)
>>>close(571)                              = -1 EBADF (Bad file descriptor)
>>>close(570)                              = -1 EBADF (Bad file descriptor)
>>>close(569)                              = -1 EBADF (Bad file descriptor)
>>>close(568)                              = -1 EBADF (Bad file descriptor)
>>>close(567)                              = -1 EBADF (Bad file descriptor)
>>>close(566)                              = -1 EBADF (Bad file descriptor)
>>>close(565)                              = -1 EBADF (Bad file descriptor)
>>>close(564)                              = -1 EBADF (Bad file descriptor)
>>>close(563)                              = -1 EBADF (Bad file descriptor)
>>>close(562)                              = -1 EBADF (Bad file descriptor)
>>>close(561)                              = -1 EBADF (Bad file descriptor)
>>>close(560)                              = -1 EBADF (Bad file descriptor)
>>>close(559)                              = -1 EBADF (Bad file descriptor)
>>>close(558)                              = -1 EBADF (Bad file descriptor)
>>>close(557)                              = -1 EBADF (Bad file descriptor)
>>>close(556)                              = -1 EBADF (Bad file descriptor)
>>>close(555)                              = -1 EBADF (Bad file descriptor)
>>>close(554)                              = -1 EBADF (Bad file descriptor)
>>>close(553)                              = -1 EBADF (Bad file descriptor)
>>>close(552)                              = -1 EBADF (Bad file descriptor)
>>>close(551)                              = -1 EBADF (Bad file descriptor)
>>>close(550)                              = -1 EBADF (Bad file descriptor)
>>>close(549)                              = -1 EBADF (Bad file descriptor)
>>>close(548)                              = -1 EBADF (Bad file descriptor)
>>>close(547)                              = -1 EBADF (Bad file descriptor)
>>>close(546)                              = -1 EBADF (Bad file descriptor)
>>>close(545)                              = -1 EBADF (Bad file descriptor)
>>>close(544)                              = -1 EBADF (Bad file descriptor)
>>>close(543)                              = -1 EBADF (Bad file descriptor)
>>>close(542)                              = -1 EBADF (Bad file descriptor)
>>>close(541)                              = -1 EBADF (Bad file descriptor)
>>>close(540)                              = -1 EBADF (Bad file descriptor)
>>>close(539)                              = -1 EBADF (Bad file descriptor)
>>>close(538)                              = -1 EBADF (Bad file descriptor)
>>>close(537)                              = -1 EBADF (Bad file descriptor)
>>>close(536)                              = -1 EBADF (Bad file descriptor)
>>>close(535)                              = -1 EBADF (Bad file descriptor)
>>>close(534)                              = -1 EBADF (Bad file descriptor)
>>>close(533)                              = -1 EBADF (Bad file descriptor)
>>>close(532)                              = -1 EBADF (Bad file descriptor)
>>>close(531)                              = -1 EBADF (Bad file descriptor)
>>>close(530)                              = -1 EBADF (Bad file descriptor)
>>>close(529)                              = -1 EBADF (Bad file descriptor)
>>>close(528)                              = -1 EBADF (Bad file descriptor)
>>>close(527)                              = -1 EBADF (Bad file descriptor)
>>>close(526)                              = -1 EBADF (Bad file descriptor)
>>>close(525)                              = -1 EBADF (Bad file descriptor)
>>>close(524)                              = -1 EBADF (Bad file descriptor)
>>>close(523)                              = -1 EBADF (Bad file descriptor)
>>>close(522)                              = -1 EBADF (Bad file descriptor)
>>>close(521)                              = -1 EBADF (Bad file descriptor)
>>>close(520)                              = -1 EBADF (Bad file descriptor)
>>>close(519)                              = -1 EBADF (Bad file descriptor)
>>>close(518)                              = -1 EBADF (Bad file descriptor)
>>>close(517)                              = -1 EBADF (Bad file descriptor)
>>>close(516)                              = -1 EBADF (Bad file descriptor)
>>>close(515)                              = -1 EBADF (Bad file descriptor)
>>>close(514)                              = -1 EBADF (Bad file descriptor)
>>>close(513)                              = -1 EBADF (Bad file descriptor)
>>>close(512)                              = -1 EBADF (Bad file descriptor)
>>>close(511)                              = -1 EBADF (Bad file descriptor)
>>>close(510)                              = -1 EBADF (Bad file descriptor)
>>>close(509)                              = -1 EBADF (Bad file descriptor)
>>>close(508)                              = -1 EBADF (Bad file descriptor)
>>>close(507)                              = -1 EBADF (Bad file descriptor)
>>>close(506)                              = -1 EBADF (Bad file descriptor)
>>>close(505)                              = -1 EBADF (Bad file descriptor)
>>>close(504)                              = -1 EBADF (Bad file descriptor)
>>>close(503)                              = -1 EBADF (Bad file descriptor)
>>>close(502)                              = -1 EBADF (Bad file descriptor)
>>>close(501)                              = -1 EBADF (Bad file descriptor)
>>>close(500)                              = -1 EBADF (Bad file descriptor)
>>>close(499)                              = -1 EBADF (Bad file descriptor)
>>>close(498)                              = -1 EBADF (Bad file descriptor)
>>>close(497)                              = -1 EBADF (Bad file descriptor)
>>>close(496)                              = -1 EBADF (Bad file descriptor)
>>>close(495)                              = -1 EBADF (Bad file descriptor)
>>>close(494)                              = -1 EBADF (Bad file descriptor)
>>>close(493)                              = -1 EBADF (Bad file descriptor)
>>>close(492)                              = -1 EBADF (Bad file descriptor)
>>>close(491)                              = -1 EBADF (Bad file descriptor)
>>>close(490)                              = -1 EBADF (Bad file descriptor)
>>>close(489)                              = -1 EBADF (Bad file descriptor)
>>>close(488)                              = -1 EBADF (Bad file descriptor)
>>>close(487)                              = -1 EBADF (Bad file descriptor)
>>>close(486)                              = -1 EBADF (Bad file descriptor)
>>>close(485)                              = -1 EBADF (Bad file descriptor)
>>>close(484)                              = -1 EBADF (Bad file descriptor)
>>>close(483)                              = -1 EBADF (Bad file descriptor)
>>>close(482)                              = -1 EBADF (Bad file descriptor)
>>>close(481)                              = -1 EBADF (Bad file descriptor)
>>>close(480)                              = -1 EBADF (Bad file descriptor)
>>>close(479)                              = -1 EBADF (Bad file descriptor)
>>>close(478)                              = -1 EBADF (Bad file descriptor)
>>>close(477)                              = -1 EBADF (Bad file descriptor)
>>>close(476)                              = -1 EBADF (Bad file descriptor)
>>>close(475)                              = -1 EBADF (Bad file descriptor)
>>>close(474)                              = -1 EBADF (Bad file descriptor)
>>>close(473)                              = -1 EBADF (Bad file descriptor)
>>>close(472)                              = -1 EBADF (Bad file descriptor)
>>>close(471)                              = -1 EBADF (Bad file descriptor)
>>>close(470)                              = -1 EBADF (Bad file descriptor)
>>>close(469)                              = -1 EBADF (Bad file descriptor)
>>>close(468)                              = -1 EBADF (Bad file descriptor)
>>>close(467)                              = -1 EBADF (Bad file descriptor)
>>>close(466)                              = -1 EBADF (Bad file descriptor)
>>>close(465)                              = -1 EBADF (Bad file descriptor)
>>>close(464)                              = -1 EBADF (Bad file descriptor)
>>>close(463)                              = -1 EBADF (Bad file descriptor)
>>>close(462)                              = -1 EBADF (Bad file descriptor)
>>>close(461)                              = -1 EBADF (Bad file descriptor)
>>>close(460)                              = -1 EBADF (Bad file descriptor)
>>>close(459)                              = -1 EBADF (Bad file descriptor)
>>>close(458)                              = -1 EBADF (Bad file descriptor)
>>>close(457)                              = -1 EBADF (Bad file descriptor)
>>>close(456)                              = -1 EBADF (Bad file descriptor)
>>>close(455)                              = -1 EBADF (Bad file descriptor)
>>>close(454)                              = -1 EBADF (Bad file descriptor)
>>>close(453)                              = -1 EBADF (Bad file descriptor)
>>>close(452)                              = -1 EBADF (Bad file descriptor)
>>>close(451)                              = -1 EBADF (Bad file descriptor)
>>>close(450)                              = -1 EBADF (Bad file descriptor)
>>>close(449)                              = -1 EBADF (Bad file descriptor)
>>>close(448)                              = -1 EBADF (Bad file descriptor)
>>>close(447)                              = -1 EBADF (Bad file descriptor)
>>>close(446)                              = -1 EBADF (Bad file descriptor)
>>>close(445)                              = -1 EBADF (Bad file descriptor)
>>>close(444)                              = -1 EBADF (Bad file descriptor)
>>>close(443)                              = -1 EBADF (Bad file descriptor)
>>>close(442)                              = -1 EBADF (Bad file descriptor)
>>>close(441)                              = -1 EBADF (Bad file descriptor)
>>>close(440)                              = -1 EBADF (Bad file descriptor)
>>>close(439)                              = -1 EBADF (Bad file descriptor)
>>>close(438)                              = -1 EBADF (Bad file descriptor)
>>>close(437)                              = -1 EBADF (Bad file descriptor)
>>>close(436)                              = -1 EBADF (Bad file descriptor)
>>>close(435)                              = -1 EBADF (Bad file descriptor)
>>>close(434)                              = -1 EBADF (Bad file descriptor)
>>>close(433)                              = -1 EBADF (Bad file descriptor)
>>>close(432)                              = -1 EBADF (Bad file descriptor)
>>>close(431)                              = -1 EBADF (Bad file descriptor)
>>>close(430)                              = -1 EBADF (Bad file descriptor)
>>>close(429)                              = -1 EBADF (Bad file descriptor)
>>>close(428)                              = -1 EBADF (Bad file descriptor)
>>>close(427)                              = -1 EBADF (Bad file descriptor)
>>>close(426)                              = -1 EBADF (Bad file descriptor)
>>>close(425)                              = -1 EBADF (Bad file descriptor)
>>>close(424)                              = -1 EBADF (Bad file descriptor)
>>>close(423)                              = -1 EBADF (Bad file descriptor)
>>>close(422)                              = -1 EBADF (Bad file descriptor)
>>>close(421)                              = -1 EBADF (Bad file descriptor)
>>>close(420)                              = -1 EBADF (Bad file descriptor)
>>>close(419)                              = -1 EBADF (Bad file descriptor)
>>>close(418)                              = -1 EBADF (Bad file descriptor)
>>>close(417)                              = -1 EBADF (Bad file descriptor)
>>>close(416)                              = -1 EBADF (Bad file descriptor)
>>>close(415)                              = -1 EBADF (Bad file descriptor)
>>>close(414)                              = -1 EBADF (Bad file descriptor)
>>>close(413)                              = -1 EBADF (Bad file descriptor)
>>>close(412)                              = -1 EBADF (Bad file descriptor)
>>>close(411)                              = -1 EBADF (Bad file descriptor)
>>>close(410)                              = -1 EBADF (Bad file descriptor)
>>>close(409)                              = -1 EBADF (Bad file descriptor)
>>>close(408)                              = -1 EBADF (Bad file descriptor)
>>>close(407)                              = -1 EBADF (Bad file descriptor)
>>>close(406)                              = -1 EBADF (Bad file descriptor)
>>>close(405)                              = -1 EBADF (Bad file descriptor)
>>>close(404)                              = -1 EBADF (Bad file descriptor)
>>>close(403)                              = -1 EBADF (Bad file descriptor)
>>>close(402)                              = -1 EBADF (Bad file descriptor)
>>>close(401)                              = -1 EBADF (Bad file descriptor)
>>>close(400)                              = -1 EBADF (Bad file descriptor)
>>>close(399)                              = -1 EBADF (Bad file descriptor)
>>>close(398)                              = -1 EBADF (Bad file descriptor)
>>>close(397)                              = -1 EBADF (Bad file descriptor)
>>>close(396)                              = -1 EBADF (Bad file descriptor)
>>>close(395)                              = -1 EBADF (Bad file descriptor)
>>>close(394)                              = -1 EBADF (Bad file descriptor)
>>>close(393)                              = -1 EBADF (Bad file descriptor)
>>>close(392)                              = -1 EBADF (Bad file descriptor)
>>>close(391)                              = -1 EBADF (Bad file descriptor)
>>>close(390)                              = -1 EBADF (Bad file descriptor)
>>>close(389)                              = -1 EBADF (Bad file descriptor)
>>>close(388)                              = -1 EBADF (Bad file descriptor)
>>>close(387)                              = -1 EBADF (Bad file descriptor)
>>>close(386)                              = -1 EBADF (Bad file descriptor)
>>>close(385)                              = -1 EBADF (Bad file descriptor)
>>>close(384)                              = -1 EBADF (Bad file descriptor)
>>>close(383)                              = -1 EBADF (Bad file descriptor)
>>>close(382)                              = -1 EBADF (Bad file descriptor)
>>>close(381)                              = -1 EBADF (Bad file descriptor)
>>>close(380)                              = -1 EBADF (Bad file descriptor)
>>>close(379)                              = -1 EBADF (Bad file descriptor)
>>>close(378)                              = -1 EBADF (Bad file descriptor)
>>>close(377)                              = -1 EBADF (Bad file descriptor)
>>>close(376)                              = -1 EBADF (Bad file descriptor)
>>>close(375)                              = -1 EBADF (Bad file descriptor)
>>>close(374)                              = -1 EBADF (Bad file descriptor)
>>>close(373)                              = -1 EBADF (Bad file descriptor)
>>>close(372)                              = -1 EBADF (Bad file descriptor)
>>>close(371)                              = -1 EBADF (Bad file descriptor)
>>>close(370)                              = -1 EBADF (Bad file descriptor)
>>>close(369)                              = -1 EBADF (Bad file descriptor)
>>>close(368)                              = -1 EBADF (Bad file descriptor)
>>>close(367)                              = -1 EBADF (Bad file descriptor)
>>>close(366)                              = -1 EBADF (Bad file descriptor)
>>>close(365)                              = -1 EBADF (Bad file descriptor)
>>>close(364)                              = -1 EBADF (Bad file descriptor)
>>>close(363)                              = -1 EBADF (Bad file descriptor)
>>>close(362)                              = -1 EBADF (Bad file descriptor)
>>>close(361)                              = -1 EBADF (Bad file descriptor)
>>>close(360)                              = -1 EBADF (Bad file descriptor)
>>>close(359)                              = -1 EBADF (Bad file descriptor)
>>>close(358)                              = -1 EBADF (Bad file descriptor)
>>>close(357)                              = -1 EBADF (Bad file descriptor)
>>>close(356)                              = -1 EBADF (Bad file descriptor)
>>>close(355)                              = -1 EBADF (Bad file descriptor)
>>>close(354)                              = -1 EBADF (Bad file descriptor)
>>>close(353)                              = -1 EBADF (Bad file descriptor)
>>>close(352)                              = -1 EBADF (Bad file descriptor)
>>>close(351)                              = -1 EBADF (Bad file descriptor)
>>>close(350)                              = -1 EBADF (Bad file descriptor)
>>>close(349)                              = -1 EBADF (Bad file descriptor)
>>>close(348)                              = -1 EBADF (Bad file descriptor)
>>>close(347)                              = -1 EBADF (Bad file descriptor)
>>>close(346)                              = -1 EBADF (Bad file descriptor)
>>>close(345)                              = -1 EBADF (Bad file descriptor)
>>>close(344)                              = -1 EBADF (Bad file descriptor)
>>>close(343)                              = -1 EBADF (Bad file descriptor)
>>>close(342)                              = -1 EBADF (Bad file descriptor)
>>>close(341)                              = -1 EBADF (Bad file descriptor)
>>>close(340)                              = -1 EBADF (Bad file descriptor)
>>>close(339)                              = -1 EBADF (Bad file descriptor)
>>>close(338)                              = -1 EBADF (Bad file descriptor)
>>>close(337)                              = -1 EBADF (Bad file descriptor)
>>>close(336)                              = -1 EBADF (Bad file descriptor)
>>>close(335)                              = -1 EBADF (Bad file descriptor)
>>>close(334)                              = -1 EBADF (Bad file descriptor)
>>>close(333)                              = -1 EBADF (Bad file descriptor)
>>>close(332)                              = -1 EBADF (Bad file descriptor)
>>>close(331)                              = -1 EBADF (Bad file descriptor)
>>>close(330)                              = -1 EBADF (Bad file descriptor)
>>>close(329)                              = -1 EBADF (Bad file descriptor)
>>>close(328)                              = -1 EBADF (Bad file descriptor)
>>>close(327)                              = -1 EBADF (Bad file descriptor)
>>>close(326)                              = -1 EBADF (Bad file descriptor)
>>>close(325)                              = -1 EBADF (Bad file descriptor)
>>>close(324)                              = -1 EBADF (Bad file descriptor)
>>>close(323)                              = -1 EBADF (Bad file descriptor)
>>>close(322)                              = -1 EBADF (Bad file descriptor)
>>>close(321)                              = -1 EBADF (Bad file descriptor)
>>>close(320)                              = -1 EBADF (Bad file descriptor)
>>>close(319)                              = -1 EBADF (Bad file descriptor)
>>>close(318)                              = -1 EBADF (Bad file descriptor)
>>>close(317)                              = -1 EBADF (Bad file descriptor)
>>>close(316)                              = -1 EBADF (Bad file descriptor)
>>>close(315)                              = -1 EBADF (Bad file descriptor)
>>>close(314)                              = -1 EBADF (Bad file descriptor)
>>>close(313)                              = -1 EBADF (Bad file descriptor)
>>>close(312)                              = -1 EBADF (Bad file descriptor)
>>>close(311)                              = -1 EBADF (Bad file descriptor)
>>>close(310)                              = -1 EBADF (Bad file descriptor)
>>>close(309)                              = -1 EBADF (Bad file descriptor)
>>>close(308)                              = -1 EBADF (Bad file descriptor)
>>>close(307)                              = -1 EBADF (Bad file descriptor)
>>>close(306)                              = -1 EBADF (Bad file descriptor)
>>>close(305)                              = -1 EBADF (Bad file descriptor)
>>>close(304)                              = -1 EBADF (Bad file descriptor)
>>>close(303)                              = -1 EBADF (Bad file descriptor)
>>>close(302)                              = -1 EBADF (Bad file descriptor)
>>>close(301)                              = -1 EBADF (Bad file descriptor)
>>>close(300)                              = -1 EBADF (Bad file descriptor)
>>>close(299)                              = -1 EBADF (Bad file descriptor)
>>>close(298)                              = -1 EBADF (Bad file descriptor)
>>>close(297)                              = -1 EBADF (Bad file descriptor)
>>>close(296)                              = -1 EBADF (Bad file descriptor)
>>>close(295)                              = -1 EBADF (Bad file descriptor)
>>>close(294)                              = -1 EBADF (Bad file descriptor)
>>>close(293)                              = -1 EBADF (Bad file descriptor)
>>>close(292)                              = -1 EBADF (Bad file descriptor)
>>>close(291)                              = -1 EBADF (Bad file descriptor)
>>>close(290)                              = -1 EBADF (Bad file descriptor)
>>>close(289)                              = -1 EBADF (Bad file descriptor)
>>>close(288)                              = -1 EBADF (Bad file descriptor)
>>>close(287)                              = -1 EBADF (Bad file descriptor)
>>>close(286)                              = -1 EBADF (Bad file descriptor)
>>>close(285)                              = -1 EBADF (Bad file descriptor)
>>>close(284)                              = -1 EBADF (Bad file descriptor)
>>>close(283)                              = -1 EBADF (Bad file descriptor)
>>>close(282)                              = -1 EBADF (Bad file descriptor)
>>>close(281)                              = -1 EBADF (Bad file descriptor)
>>>close(280)                              = -1 EBADF (Bad file descriptor)
>>>close(279)                              = -1 EBADF (Bad file descriptor)
>>>close(278)                              = -1 EBADF (Bad file descriptor)
>>>close(277)                              = -1 EBADF (Bad file descriptor)
>>>close(276)                              = -1 EBADF (Bad file descriptor)
>>>close(275)                              = -1 EBADF (Bad file descriptor)
>>>close(274)                              = -1 EBADF (Bad file descriptor)
>>>close(273)                              = -1 EBADF (Bad file descriptor)
>>>close(272)                              = -1 EBADF (Bad file descriptor)
>>>close(271)                              = -1 EBADF (Bad file descriptor)
>>>close(270)                              = -1 EBADF (Bad file descriptor)
>>>close(269)                              = -1 EBADF (Bad file descriptor)
>>>close(268)                              = -1 EBADF (Bad file descriptor)
>>>close(267)                              = -1 EBADF (Bad file descriptor)
>>>close(266)                              = -1 EBADF (Bad file descriptor)
>>>close(265)                              = -1 EBADF (Bad file descriptor)
>>>close(264)                              = -1 EBADF (Bad file descriptor)
>>>close(263)                              = -1 EBADF (Bad file descriptor)
>>>close(262)                              = -1 EBADF (Bad file descriptor)
>>>close(261)                              = -1 EBADF (Bad file descriptor)
>>>close(260)                              = -1 EBADF (Bad file descriptor)
>>>close(259)                              = -1 EBADF (Bad file descriptor)
>>>close(258)                              = -1 EBADF (Bad file descriptor)
>>>close(257)                              = -1 EBADF (Bad file descriptor)
>>>close(256)                              = -1 EBADF (Bad file descriptor)
>>>close(255)                              = -1 EBADF (Bad file descriptor)
>>>close(254)                              = -1 EBADF (Bad file descriptor)
>>>close(253)                              = -1 EBADF (Bad file descriptor)
>>>close(252)                              = -1 EBADF (Bad file descriptor)
>>>close(251)                              = -1 EBADF (Bad file descriptor)
>>>close(250)                              = -1 EBADF (Bad file descriptor)
>>>close(249)                              = -1 EBADF (Bad file descriptor)
>>>close(248)                              = -1 EBADF (Bad file descriptor)
>>>close(247)                              = -1 EBADF (Bad file descriptor)
>>>close(246)                              = -1 EBADF (Bad file descriptor)
>>>close(245)                              = -1 EBADF (Bad file descriptor)
>>>close(244)                              = -1 EBADF (Bad file descriptor)
>>>close(243)                              = -1 EBADF (Bad file descriptor)
>>>close(242)                              = -1 EBADF (Bad file descriptor)
>>>close(241)                              = -1 EBADF (Bad file descriptor)
>>>close(240)                              = -1 EBADF (Bad file descriptor)
>>>close(239)                              = -1 EBADF (Bad file descriptor)
>>>close(238)                              = -1 EBADF (Bad file descriptor)
>>>close(237)                              = -1 EBADF (Bad file descriptor)
>>>close(236)                              = -1 EBADF (Bad file descriptor)
>>>close(235)                              = -1 EBADF (Bad file descriptor)
>>>close(234)                              = -1 EBADF (Bad file descriptor)
>>>close(233)                              = -1 EBADF (Bad file descriptor)
>>>close(232)                              = -1 EBADF (Bad file descriptor)
>>>close(231)                              = -1 EBADF (Bad file descriptor)
>>>close(230)                              = -1 EBADF (Bad file descriptor)
>>>close(229)                              = -1 EBADF (Bad file descriptor)
>>>close(228)                              = -1 EBADF (Bad file descriptor)
>>>close(227)                              = -1 EBADF (Bad file descriptor)
>>>close(226)                              = -1 EBADF (Bad file descriptor)
>>>close(225)                              = -1 EBADF (Bad file descriptor)
>>>close(224)                              = -1 EBADF (Bad file descriptor)
>>>close(223)                              = -1 EBADF (Bad file descriptor)
>>>close(222)                              = -1 EBADF (Bad file descriptor)
>>>close(221)                              = -1 EBADF (Bad file descriptor)
>>>close(220)                              = -1 EBADF (Bad file descriptor)
>>>close(219)                              = -1 EBADF (Bad file descriptor)
>>>close(218)                              = -1 EBADF (Bad file descriptor)
>>>close(217)                              = -1 EBADF (Bad file descriptor)
>>>close(216)                              = -1 EBADF (Bad file descriptor)
>>>close(215)                              = -1 EBADF (Bad file descriptor)
>>>close(214)                              = -1 EBADF (Bad file descriptor)
>>>close(213)                              = -1 EBADF (Bad file descriptor)
>>>close(212)                              = -1 EBADF (Bad file descriptor)
>>>close(211)                              = -1 EBADF (Bad file descriptor)
>>>close(210)                              = -1 EBADF (Bad file descriptor)
>>>close(209)                              = -1 EBADF (Bad file descriptor)
>>>close(208)                              = -1 EBADF (Bad file descriptor)
>>>close(207)                              = -1 EBADF (Bad file descriptor)
>>>close(206)                              = -1 EBADF (Bad file descriptor)
>>>close(205)                              = -1 EBADF (Bad file descriptor)
>>>close(204)                              = -1 EBADF (Bad file descriptor)
>>>close(203)                              = -1 EBADF (Bad file descriptor)
>>>close(202)                              = -1 EBADF (Bad file descriptor)
>>>close(201)                              = -1 EBADF (Bad file descriptor)
>>>close(200)                              = -1 EBADF (Bad file descriptor)
>>>close(199)                              = -1 EBADF (Bad file descriptor)
>>>close(198)                              = -1 EBADF (Bad file descriptor)
>>>close(197)                              = -1 EBADF (Bad file descriptor)
>>>close(196)                              = -1 EBADF (Bad file descriptor)
>>>close(195)                              = -1 EBADF (Bad file descriptor)
>>>close(194)                              = -1 EBADF (Bad file descriptor)
>>>close(193)                              = -1 EBADF (Bad file descriptor)
>>>close(192)                              = -1 EBADF (Bad file descriptor)
>>>close(191)                              = -1 EBADF (Bad file descriptor)
>>>close(190)                              = -1 EBADF (Bad file descriptor)
>>>close(189)                              = -1 EBADF (Bad file descriptor)
>>>close(188)                              = -1 EBADF (Bad file descriptor)
>>>close(187)                              = -1 EBADF (Bad file descriptor)
>>>close(186)                              = -1 EBADF (Bad file descriptor)
>>>close(185)                              = -1 EBADF (Bad file descriptor)
>>>close(184)                              = -1 EBADF (Bad file descriptor)
>>>close(183)                              = -1 EBADF (Bad file descriptor)
>>>close(182)                              = -1 EBADF (Bad file descriptor)
>>>close(181)                              = -1 EBADF (Bad file descriptor)
>>>close(180)                              = -1 EBADF (Bad file descriptor)
>>>close(179)                              = -1 EBADF (Bad file descriptor)
>>>close(178)                              = -1 EBADF (Bad file descriptor)
>>>close(177)                              = -1 EBADF (Bad file descriptor)
>>>close(176)                              = -1 EBADF (Bad file descriptor)
>>>close(175)                              = -1 EBADF (Bad file descriptor)
>>>close(174)                              = -1 EBADF (Bad file descriptor)
>>>close(173)                              = -1 EBADF (Bad file descriptor)
>>>close(172)                              = -1 EBADF (Bad file descriptor)
>>>close(171)                              = -1 EBADF (Bad file descriptor)
>>>close(170)                              = -1 EBADF (Bad file descriptor)
>>>close(169)                              = -1 EBADF (Bad file descriptor)
>>>close(168)                              = -1 EBADF (Bad file descriptor)
>>>close(167)                              = -1 EBADF (Bad file descriptor)
>>>close(166)                              = -1 EBADF (Bad file descriptor)
>>>close(165)                              = -1 EBADF (Bad file descriptor)
>>>close(164)                              = -1 EBADF (Bad file descriptor)
>>>close(163)                              = -1 EBADF (Bad file descriptor)
>>>close(162)                              = -1 EBADF (Bad file descriptor)
>>>close(161)                              = -1 EBADF (Bad file descriptor)
>>>close(160)                              = -1 EBADF (Bad file descriptor)
>>>close(159)                              = -1 EBADF (Bad file descriptor)
>>>close(158)                              = -1 EBADF (Bad file descriptor)
>>>close(157)                              = -1 EBADF (Bad file descriptor)
>>>close(156)                              = -1 EBADF (Bad file descriptor)
>>>close(155)                              = -1 EBADF (Bad file descriptor)
>>>close(154)                              = -1 EBADF (Bad file descriptor)
>>>close(153)                              = -1 EBADF (Bad file descriptor)
>>>close(152)                              = -1 EBADF (Bad file descriptor)
>>>close(151)                              = -1 EBADF (Bad file descriptor)
>>>close(150)                              = -1 EBADF (Bad file descriptor)
>>>close(149)                              = -1 EBADF (Bad file descriptor)
>>>close(148)                              = -1 EBADF (Bad file descriptor)
>>>close(147)                              = -1 EBADF (Bad file descriptor)
>>>close(146)                              = -1 EBADF (Bad file descriptor)
>>>close(145)                              = -1 EBADF (Bad file descriptor)
>>>close(144)                              = -1 EBADF (Bad file descriptor)
>>>close(143)                              = -1 EBADF (Bad file descriptor)
>>>close(142)                              = -1 EBADF (Bad file descriptor)
>>>close(141)                              = -1 EBADF (Bad file descriptor)
>>>close(140)                              = -1 EBADF (Bad file descriptor)
>>>close(139)                              = -1 EBADF (Bad file descriptor)
>>>close(138)                              = -1 EBADF (Bad file descriptor)
>>>close(137)                              = -1 EBADF (Bad file descriptor)
>>>close(136)                              = -1 EBADF (Bad file descriptor)
>>>close(135)                              = -1 EBADF (Bad file descriptor)
>>>close(134)                              = -1 EBADF (Bad file descriptor)
>>>close(133)                              = -1 EBADF (Bad file descriptor)
>>>close(132)                              = -1 EBADF (Bad file descriptor)
>>>close(131)                              = -1 EBADF (Bad file descriptor)
>>>close(130)                              = -1 EBADF (Bad file descriptor)
>>>close(129)                              = -1 EBADF (Bad file descriptor)
>>>close(128)                              = -1 EBADF (Bad file descriptor)
>>>close(127)                              = -1 EBADF (Bad file descriptor)
>>>close(126)                              = -1 EBADF (Bad file descriptor)
>>>close(125)                              = -1 EBADF (Bad file descriptor)
>>>close(124)                              = -1 EBADF (Bad file descriptor)
>>>close(123)                              = -1 EBADF (Bad file descriptor)
>>>close(122)                              = -1 EBADF (Bad file descriptor)
>>>close(121)                              = -1 EBADF (Bad file descriptor)
>>>close(120)                              = -1 EBADF (Bad file descriptor)
>>>close(119)                              = -1 EBADF (Bad file descriptor)
>>>close(118)                              = -1 EBADF (Bad file descriptor)
>>>close(117)                              = -1 EBADF (Bad file descriptor)
>>>close(116)                              = -1 EBADF (Bad file descriptor)
>>>close(115)                              = -1 EBADF (Bad file descriptor)
>>>close(114)                              = -1 EBADF (Bad file descriptor)
>>>close(113)                              = -1 EBADF (Bad file descriptor)
>>>close(112)                              = -1 EBADF (Bad file descriptor)
>>>close(111)                              = -1 EBADF (Bad file descriptor)
>>>close(110)                              = -1 EBADF (Bad file descriptor)
>>>close(109)                              = -1 EBADF (Bad file descriptor)
>>>close(108)                              = -1 EBADF (Bad file descriptor)
>>>close(107)                              = -1 EBADF (Bad file descriptor)
>>>close(106)                              = -1 EBADF (Bad file descriptor)
>>>close(105)                              = -1 EBADF (Bad file descriptor)
>>>close(104)                              = -1 EBADF (Bad file descriptor)
>>>close(103)                              = -1 EBADF (Bad file descriptor)
>>>close(102)                              = -1 EBADF (Bad file descriptor)
>>>close(101)                              = -1 EBADF (Bad file descriptor)
>>>close(100)                              = -1 EBADF (Bad file descriptor)
>>>close(99)                               = -1 EBADF (Bad file descriptor)
>>>close(98)                               = -1 EBADF (Bad file descriptor)
>>>close(97)                               = -1 EBADF (Bad file descriptor)
>>>close(96)                               = -1 EBADF (Bad file descriptor)
>>>close(95)                               = -1 EBADF (Bad file descriptor)
>>>close(94)                               = -1 EBADF (Bad file descriptor)
>>>close(93)                               = -1 EBADF (Bad file descriptor)
>>>close(92)                               = -1 EBADF (Bad file descriptor)
>>>close(91)                               = -1 EBADF (Bad file descriptor)
>>>close(90)                               = -1 EBADF (Bad file descriptor)
>>>close(89)                               = -1 EBADF (Bad file descriptor)
>>>close(88)                               = -1 EBADF (Bad file descriptor)
>>>close(87)                               = -1 EBADF (Bad file descriptor)
>>>close(86)                               = -1 EBADF (Bad file descriptor)
>>>close(85)                               = -1 EBADF (Bad file descriptor)
>>>close(84)                               = -1 EBADF (Bad file descriptor)
>>>close(83)                               = -1 EBADF (Bad file descriptor)
>>>close(82)                               = -1 EBADF (Bad file descriptor)
>>>close(81)                               = -1 EBADF (Bad file descriptor)
>>>close(80)                               = -1 EBADF (Bad file descriptor)
>>>close(79)                               = -1 EBADF (Bad file descriptor)
>>>close(78)                               = -1 EBADF (Bad file descriptor)
>>>close(77)                               = -1 EBADF (Bad file descriptor)
>>>close(76)                               = -1 EBADF (Bad file descriptor)
>>>close(75)                               = -1 EBADF (Bad file descriptor)
>>>close(74)                               = -1 EBADF (Bad file descriptor)
>>>close(73)                               = -1 EBADF (Bad file descriptor)
>>>close(72)                               = -1 EBADF (Bad file descriptor)
>>>close(71)                               = -1 EBADF (Bad file descriptor)
>>>close(70)                               = -1 EBADF (Bad file descriptor)
>>>close(69)                               = -1 EBADF (Bad file descriptor)
>>>close(68)                               = -1 EBADF (Bad file descriptor)
>>>close(67)                               = -1 EBADF (Bad file descriptor)
>>>close(66)                               = -1 EBADF (Bad file descriptor)
>>>close(65)                               = -1 EBADF (Bad file descriptor)
>>>close(64)                               = -1 EBADF (Bad file descriptor)
>>>close(63)                               = -1 EBADF (Bad file descriptor)
>>>close(62)                               = -1 EBADF (Bad file descriptor)
>>>close(61)                               = -1 EBADF (Bad file descriptor)
>>>close(60)                               = -1 EBADF (Bad file descriptor)
>>>close(59)                               = -1 EBADF (Bad file descriptor)
>>>close(58)                               = -1 EBADF (Bad file descriptor)
>>>close(57)                               = -1 EBADF (Bad file descriptor)
>>>close(56)                               = -1 EBADF (Bad file descriptor)
>>>close(55)                               = -1 EBADF (Bad file descriptor)
>>>close(54)                               = -1 EBADF (Bad file descriptor)
>>>close(53)                               = -1 EBADF (Bad file descriptor)
>>>close(52)                               = -1 EBADF (Bad file descriptor)
>>>close(51)                               = -1 EBADF (Bad file descriptor)
>>>close(50)                               = -1 EBADF (Bad file descriptor)
>>>close(49)                               = -1 EBADF (Bad file descriptor)
>>>close(48)                               = -1 EBADF (Bad file descriptor)
>>>close(47)                               = -1 EBADF (Bad file descriptor)
>>>close(46)                               = -1 EBADF (Bad file descriptor)
>>>close(45)                               = -1 EBADF (Bad file descriptor)
>>>close(44)                               = -1 EBADF (Bad file descriptor)
>>>close(43)                               = -1 EBADF (Bad file descriptor)
>>>close(42)                               = -1 EBADF (Bad file descriptor)
>>>close(41)                               = -1 EBADF (Bad file descriptor)
>>>close(40)                               = -1 EBADF (Bad file descriptor)
>>>close(39)                               = -1 EBADF (Bad file descriptor)
>>>close(38)                               = -1 EBADF (Bad file descriptor)
>>>close(37)                               = -1 EBADF (Bad file descriptor)
>>>close(36)                               = -1 EBADF (Bad file descriptor)
>>>close(35)                               = -1 EBADF (Bad file descriptor)
>>>close(34)                               = -1 EBADF (Bad file descriptor)
>>>close(33)                               = -1 EBADF (Bad file descriptor)
>>>close(32)                               = -1 EBADF (Bad file descriptor)
>>>close(31)                               = -1 EBADF (Bad file descriptor)
>>>close(30)                               = -1 EBADF (Bad file descriptor)
>>>close(29)                               = -1 EBADF (Bad file descriptor)
>>>close(28)                               = -1 EBADF (Bad file descriptor)
>>>close(27)                               = -1 EBADF (Bad file descriptor)
>>>close(26)                               = -1 EBADF (Bad file descriptor)
>>>close(25)                               = -1 EBADF (Bad file descriptor)
>>>close(24)                               = -1 EBADF (Bad file descriptor)
>>>close(23)                               = -1 EBADF (Bad file descriptor)
>>>close(22)                               = -1 EBADF (Bad file descriptor)
>>>close(21)                               = -1 EBADF (Bad file descriptor)
>>>close(20)                               = -1 EBADF (Bad file descriptor)
>>>close(19)                               = -1 EBADF (Bad file descriptor)
>>>close(18)                               = -1 EBADF (Bad file descriptor)
>>>close(17)                               = -1 EBADF (Bad file descriptor)
>>>close(16)                               = -1 EBADF (Bad file descriptor)
>>>close(15)                               = -1 EBADF (Bad file descriptor)
>>>close(14)                               = -1 EBADF (Bad file descriptor)
>>>close(13)                               = -1 EBADF (Bad file descriptor)
>>>close(12)                               = -1 EBADF (Bad file descriptor)
>>>close(11)                               = -1 EBADF (Bad file descriptor)
>>>close(10)                               = -1 EBADF (Bad file descriptor)
>>>close(9)                                = -1 EBADF (Bad file descriptor)
>>>close(8)                                = -1 EBADF (Bad file descriptor)
>>>close(7)                                = -1 EBADF (Bad file descriptor)
>>>close(6)                                = -1 EBADF (Bad file descriptor)
>>>close(5)                                = -1 EBADF (Bad file descriptor)
>>>close(4)                                = -1 EBADF (Bad file descriptor)
>>>close(3)                                = -1 EBADF (Bad file descriptor)
>>>stat64("/proc/fs/nfs/filehandle", {st_mode=S_IFREG|0600, st_size=0, ...}) = 0
>>>brk(0)                                  = 0x805e000
>>>brk(0x807f000)                          = 0x807f000
>>>open("/proc/net/rpc/auth.unix.ip/channel", O_RDWR) = 3
>>>open("/proc/net/rpc/nfsd.export/channel", O_RDWR) = 4
>>>open("/proc/net/rpc/nfsd.fh/channel", O_RDWR) = 5
>>>getsockname(0, 0xbffff7d0, [16])        = -1 ENOTSOCK (Socket operation on non-socket)
>>>socket(PF_NETLINK, SOCK_RAW, 0)         = 6
>>>bind(6, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
>>>getsockname(6, {sa_family=AF_NETLINK, pid=9562, groups=00000000}, [12]) = 0
>>>time(NULL)                              = 1114756567
>>>sendto(6, "\24\0\0\0\22\0\1\3\327\325qB\0\0\0\0\0%\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
>>>recvmsg(6, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\344\0\0\0\20\0\2\0\327\325qBZ%\0\0\0\0\4\3\1\0\0\0I\0"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 464
>>>recvmsg(6, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0\327\325qBZ%\0\0\0\0\0\0\1\0\0\0I\0\0"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
>>>sendto(6, "\24\0\0\0\26\0\1\3\330\325qB\0\0\0\0\0%\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
>>>recvmsg(6, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"<\0\0\0\24\0\2\0\330\325qBZ%\0\0\2\10\200\376\1\0\0\0\10"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 128
>>>recvmsg(6, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0\330\325qBZ%\0\0\0\0\0\0\1\0\0\0\10\0"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
>>>close(6)                                = 0
>>>gettimeofday({1114756567, 915668}, NULL) = 0
>>>socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) = 6
>>>getpid()                                = 9562
>>>bind(6, {sa_family=AF_INET, sin_port=htons(834), sin_addr=inet_addr("0.0.0.0")}, 16) = 0
>>>ioctl(6, FIONBIO, [1])                  = 0
>>>setsockopt(6, SOL_IP, IP_RECVERR, [1], 4) = 0
>>>sendto(6, "\22\347\237\221\0\0\0\0\0\0\0\2\0\1\206\240\0\0\0\2\0\0"..., 56, 0, {sa_family=AF_INET, sin_port=htons(111), sin_addr=inet_addr("127.0.0.1")}, 16) = 56
>>>poll([{fd=6, events=POLLIN, revents=POLLIN}], 1, 5000) = 1
>>>recvfrom(6, "\22\347\237\221\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 400, 0, {sa_family=AF_INET, sin_port=htons(111), sin_addr=inet_addr("127.0.0.1")}, [16]) = 28
>>>close(6)                                = 0
>>>socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) = 6
>>>setsockopt(6, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
>>>open("/etc/nsswitch.conf", O_RDONLY)    = 7
>>>fstat64(7, {st_mode=S_IFREG|0644, st_size=1331, ...}) = 0
>>>mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7fe9000
>>>read(7, "#ident $Id: nsswitch.ldap,v 2.4 "..., 4096) = 1331
>>>read(7, "", 4096)                       = 0
>>>close(7)                                = 0
>>>munmap(0xb7fe9000, 4096)                = 0
>>>open("/etc/ld.so.cache", O_RDONLY)      = 7
>>>fstat64(7, {st_mode=S_IFREG|0644, st_size=60778, ...}) = 0
>>>mmap2(NULL, 60778, PROT_READ, MAP_PRIVATE, 7, 0) = 0xb7fdb000
>>>close(7)                                = 0
>>>open("/usr/lib/libnss_ldap.so.2", O_RDONLY) = 7
>>>read(7, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0P\'\0\000"..., 512) = 512
>>>fstat64(7, {st_mode=S_IFREG|0755, st_size=66196, ...}) = 0
>>>mmap2(NULL, 104736, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 7, 0) = 0xb7e78000
>>>mmap2(0xb7e87000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 7, 0xf) = 0xb7e87000
>>>mmap2(0xb7e88000, 39200, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb7e88000
>>>close(7)                                = 0
>>>open("/usr/lib/libldap.so.2", O_RDONLY) = 7
>>>read(7, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\0\201\0"..., 512) = 512
>>>fstat64(7, {st_mode=S_IFREG|0755, st_size=234368, ...}) = 0
>>>mmap2(NULL, 228384, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 7, 0) = 0xb7e40000
>>>mmap2(0xb7e77000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 7, 0x37) = 0xb7e77000
>>>close(7)                                = 0
>>>open("/usr/lib/liblber.so.2", O_RDONLY) = 7
>>>read(7, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\220%\0"..., 512) = 512
>>>fstat64(7, {st_mode=S_IFREG|0755, st_size=48456, ...}) = 0
>>>mmap2(NULL, 46160, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 7, 0) = 0xb7e34000
>>>mmap2(0xb7e3f000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 7, 0xb) = 0xb7e3f000
>>>close(7)                                = 0
>>>open("/lib/libdl.so.2", O_RDONLY)       = 7
>>>read(7, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\340\v\0"..., 512) = 512
>>>fstat64(7, {st_mode=S_IFREG|0755, st_size=10952, ...}) = 0
>>>mmap2(NULL, 12392, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 7, 0) = 0xb7e30000
>>>mmap2(0xb7e32000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 7, 0x1) = 0xb7e32000
>>>close(7)                                = 0
>>>open("/lib/libresolv.so.2", O_RDONLY)   = 7
>>>read(7, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\300%\0"..., 512) = 512
>>>fstat64(7, {st_mode=S_IFREG|0755, st_size=73508, ...}) = 0
>>>mmap2(NULL, 84212, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 7, 0) = 0xb7e1b000
>>>mprotect(0xb7e2b000, 18676, PROT_NONE)  = 0
>>>mmap2(0xb7e2c000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 7, 0x10) = 0xb7e2c000
>>>mmap2(0xb7e2e000, 6388, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb7e2e000
>>>close(7)                                = 0
>>>open("/usr/lib/libssl.so.0.9.7", O_RDONLY) = 7
>>>read(7, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\20\204"..., 512) = 512
>>>fstat64(7, {st_mode=S_IFREG|0555, st_size=202424, ...}) = 0
>>>mmap2(NULL, 199524, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 7, 0) = 0xb7dea000
>>>mmap2(0xb7e18000, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 7, 0x2e) = 0xb7e18000
>>>close(7)                                = 0
>>>open("/usr/lib/libcrypto.so.0.9.7", O_RDONLY) = 7
>>>read(7, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\20\305"..., 512) = 512
>>>fstat64(7, {st_mode=S_IFREG|0555, st_size=1080628, ...}) = 0
>>>mmap2(NULL, 1052152, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 7, 0) = 0xb7ce9000
>>>mmap2(0xb7dd5000, 73728, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 7, 0xec) = 0xb7dd5000
>>>mmap2(0xb7de7000, 11768, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb7de7000
>>>close(7)                                = 0
>>>munmap(0xb7fdb000, 60778)               = 0
>>>rt_sigaction(SIGPIPE, {SIG_IGN}, {SIG_IGN}, 8) = 0
>>>getpid()                                = 9562
>>>geteuid32()                             = 0
>>>open("/etc/ldap.conf", O_RDONLY)        = 7
>>>fstat64(7, {st_mode=S_IFREG|0644, st_size=8832, ...}) = 0
>>>mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7fe9000
>>>read(7, "# @(#)$Id: ldap.conf,v 2.39 2005"..., 4096) = 4096
>>>read(7, "pam_password racf\n\n# Update Acti"..., 4096) = 4096
>>>read(7, "r is \"yes\".\n#tls_checkpeer yes\n\n"..., 4096) = 640
>>>read(7, "", 4096)                       = 0
>>>close(7)                                = 0
>>>munmap(0xb7fe9000, 4096)                = 0
>>>uname({sys="Linux", node="gebo", ...})  = 0
>>>gettimeofday({1114756567, 923035}, NULL) = 0
>>>getpid()                                = 9562
>>>open("/etc/resolv.conf", O_RDONLY)      = 7
>>>fstat64(7, {st_mode=S_IFREG|0644, st_size=42, ...}) = 0
>>>mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7fe9000
>>>read(7, "nameserver 192.168.0.1\ndomain lo"..., 4096) = 42
>>>read(7, "", 4096)                       = 0
>>>close(7)                                = 0
>>>munmap(0xb7fe9000, 4096)                = 0
>>>socket(PF_FILE, SOCK_STREAM, 0)         = 7
>>>fcntl64(7, F_GETFL)                     = 0x2 (flags O_RDWR)
>>>fcntl64(7, F_SETFL, O_RDWR|O_NONBLOCK)  = 0
>>>connect(7, {sa_family=AF_FILE, path="/var/run/nscd/socket"}, 110) = -1 ENOENT (No such file or directory)
>>>close(7)                                = 0
>>>socket(PF_FILE, SOCK_STREAM, 0)         = 7
>>>fcntl64(7, F_GETFL)                     = 0x2 (flags O_RDWR)
>>>fcntl64(7, F_SETFL, O_RDWR|O_NONBLOCK)  = 0
>>>connect(7, {sa_family=AF_FILE, path="/var/run/nscd/socket"}, 110) = -1 ENOENT (No such file or directory)
>>>close(7)                                = 0
>>>open("/etc/ld.so.cache", O_RDONLY)      = 7
>>>fstat64(7, {st_mode=S_IFREG|0644, st_size=60778, ...}) = 0
>>>mmap2(NULL, 60778, PROT_READ, MAP_PRIVATE, 7, 0) = 0xb7fdb000
>>>close(7)                                = 0
>>>open("/lib/libnss_files.so.2", O_RDONLY) = 7
>>>read(7, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0p\33\0\000"..., 512) = 512
>>>fstat64(7, {st_mode=S_IFREG|0755, st_size=39912, ...}) = 0
>>>mmap2(NULL, 41612, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 7, 0) = 0xb7cde000
>>>mmap2(0xb7ce7000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 7, 0x8) = 0xb7ce7000
>>>close(7)                                = 0
>>>munmap(0xb7fdb000, 60778)               = 0
>>>open("/etc/host.conf", O_RDONLY)        = 7
>>>fstat64(7, {st_mode=S_IFREG|0644, st_size=1302, ...}) = 0
>>>mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7fe9000
>>>read(7, "# /etc/host.conf:\n# $Header: /va"..., 4096) = 1302
>>>read(7, "", 4096)                       = 0
>>>close(7)                                = 0
>>>munmap(0xb7fe9000, 4096)                = 0
>>>open("/etc/hosts", O_RDONLY)            = 7
>>>fcntl64(7, F_GETFD)                     = 0
>>>fcntl64(7, F_SETFD, FD_CLOEXEC)         = 0
>>>fstat64(7, {st_mode=S_IFREG|0644, st_size=349, ...}) = 0
>>>mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7fe9000
>>>read(7, "127.0.0.1\tlocalhost \n192.168.0.1"..., 4096) = 349
>>>close(7)                                = 0
>>>munmap(0xb7fe9000, 4096)                = 0
>>>getrlimit(RLIMIT_NOFILE, {rlim_cur=1024, rlim_max=1024}) = 0
>>>open("/etc/openldap/ldap.conf", O_RDONLY) = 7
>>>fstat64(7, {st_mode=S_IFREG|0644, st_size=429, ...}) = 0
>>>mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7fe9000
>>>read(7, "# $OpenLDAP: pkg/ldap/libraries/"..., 4096) = 429
>>>read(7, "", 4096)                       = 0
>>>close(7)                                = 0
>>>munmap(0xb7fe9000, 4096)                = 0
>>>open("/root/ldaprc", O_RDONLY)          = -1 ENOENT (No such file or directory)
>>>open("/root/.ldaprc", O_RDONLY)         = -1 ENOENT (No such file or directory)
>>>open("ldaprc", O_RDONLY)                = -1 ENOENT (No such file or directory)
>>>getpid()                                = 9562
>>>geteuid32()                             = 0
>>>open("/etc/hosts", O_RDONLY)            = 7
>>>fcntl64(7, F_GETFD)                     = 0
>>>fcntl64(7, F_SETFD, FD_CLOEXEC)         = 0
>>>fstat64(7, {st_mode=S_IFREG|0644, st_size=349, ...}) = 0
>>>mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7fe9000
>>>read(7, "127.0.0.1\tlocalhost \n192.168.0.1"..., 4096) = 349
>>>read(7, "", 4096)                       = 0
>>>close(7)                                = 0
>>>munmap(0xb7fe9000, 4096)                = 0
>>>open("/etc/hosts", O_RDONLY)            = 7
>>>fcntl64(7, F_GETFD)                     = 0
>>>fcntl64(7, F_SETFD, FD_CLOEXEC)         = 0
>>>fstat64(7, {st_mode=S_IFREG|0644, st_size=349, ...}) = 0
>>>mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7fe9000
>>>read(7, "127.0.0.1\tlocalhost \n192.168.0.1"..., 4096) = 349
>>>close(7)                                = 0
>>>munmap(0xb7fe9000, 4096)                = 0
>>>socket(PF_INET, SOCK_STREAM, IPPROTO_IP) = 7
>>>setsockopt(7, SOL_TCP, TCP_NODELAY, [1], 4) = 0
>>>fcntl64(7, F_GETFL)                     = 0x2 (flags O_RDWR)
>>>fcntl64(7, F_SETFL, O_RDWR|O_NONBLOCK)  = 0
>>>connect(7, {sa_family=AF_INET, sin_port=htons(636), sin_addr=inet_addr("192.168.0.1")}, 16) = -1 EINPROGRESS (Operation now in progress)
>>>select(1024, NULL, [7], NULL, {30, 0})  = 1 (out [7], left {30, 0})
>>>getpeername(7, {sa_family=AF_INET, sin_port=htons(636), sin_addr=inet_addr("192.168.0.1")}, [16]) = 0
>>>fcntl64(7, F_GETFL)                     = 0x802 (flags O_RDWR|O_NONBLOCK)
>>>fcntl64(7, F_SETFL, O_RDWR)             = 0
>>>time(NULL)                              = 1114756567
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>open("/dev/urandom", O_RDONLY|O_NONBLOCK|O_NOCTTY) = 8
>>>select(9, [8], NULL, NULL, {0, 10000})  = 1 (in [8], left {0, 10000})
>>>read(8, "|@\366\370\322\v\0238\241\366\247\353\377\30}\2414\315"..., 32) = 32
>>>close(8)                                = 0
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getuid32()                              = 0
>>>getpid()                                = 9562
>>>time(NULL)                              = 1114756567
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>write(7, "\200\222\1\3\1\0i\0\0\0 \0\0009\0\0008\0\0005\0\0\26\0"..., 148) = 148
>>>read(7, "\26\3\1\0J\2\0", 7)            = 7
>>>time(NULL)                              = 1114756567
>>>time(NULL)                              = 1114756567
>>>getpid()                                = 9562
>>>read(7, "\0F\3\1Bqg2N28\33G&\4\264\250z\244\350&\271\230s\352\354"..., 72) = 72
>>>read(7, "\26\3\1\3\211", 5)             = 5
>>>read(7, "\v\0\3\205\0\3\202\0\3\1770\202\3{0\202\2\344\240\3\2\1"..., 905) = 905
>>>time([1114756567])                      = 1114756567
>>>open("/etc/localtime", O_RDONLY)        = 8
>>>fstat64(8, {st_mode=S_IFREG|0644, st_size=130, ...}) = 0
>>>fstat64(8, {st_mode=S_IFREG|0644, st_size=130, ...}) = 0
>>>mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7fe9000
>>>read(8, "TZif\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\3\0\0\0\3\0"..., 4096) = 130
>>>close(8)                                = 0
>>>munmap(0xb7fe9000, 4096)                = 0
>>>time([1114756567])                      = 1114756567
>>>getpid()                                = 9562
>>>read(7, "\26\3\1\0\4", 5)               = 5
>>>read(7, "\16\0\0\0", 4)                 = 4
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>getpid()                                = 9562
>>>write(7, "\26\3\1\0\206\20\0\0\202\0\200\245p\267j\351\211l\323d"..., 198) = 198
>>>read(7, "\24\3\1\0\1", 5)               = 5
>>>read(7, "\1", 1)                        = 1
>>>read(7, "\26\3\1\0000", 5)              = 5
>>>read(7, "#L\272\26q\353\346\272\331\240#\236!\23\16\211\202\5\255"..., 48) = 48
>>>write(7, "\25\3\1\0 \262\24EK\225\240\313\345(R\3dT\306\300\322/"..., 37) = 37
>>>time(NULL)                              = 1114756567
>>>write(7, "\27\3\1\0000\215\36\177S\214<\217\245\371\332\204\33A2"..., 53) = 53
>>>time(NULL)                              = 1114756567
>>>select(1024, [7], [], NULL, {30, 0})    = 1 (in [7], left {30, 0})
>>>read(7, "\27\3\1\0 ", 5)                = 5
>>>read(7, "\313\236Ve\251m\357\346\253\362\302\337\301\324\317K\266"..., 32) = 32
>>>read(7, "\27\3\1\0000", 5)              = 5
>>>read(7, "=If\31\320T_\356\207a\5\235\t\33\274\271p\2462\304\2\34"..., 48) = 48
>>>time(NULL)                              = 1114756567
>>>setsockopt(7, SOL_SOCKET, SO_KEEPALIVE, [0], 4) = 0
>>>fcntl64(7, F_SETFD, FD_CLOEXEC)         = 0
>>>getsockname(7, {sa_family=AF_INET, sin_port=htons(40691), sin_addr=inet_addr("192.168.0.3")}, [16]) = 0
>>>getpeername(7, {sa_family=AF_INET, sin_port=htons(636), sin_addr=inet_addr("192.168.0.1")}, [16]) = 0
>>>time([1114756567])                      = 1114756567
>>>getpid()                                = 9562
>>>geteuid32()                             = 0
>>>time(NULL)                              = 1114756567
>>>write(7, "\27\3\1\0 \360\35\276~\203\27\251\237\0315\2114\262p\300"..., 186) = 186
>>>select(1024, [7], [], NULL, NULL)       = 1 (in [7])
>>>read(7, "\27\3\1\0 ", 5)                = 5
>>>read(7, "\332.\266\330\271Z%\3069$\20_\311\274<3\4\315\322YLp\315"..., 32) = 32
>>>read(7, "\27\3\1\0000", 5)              = 5
>>>read(7, "\317l>\30\362r\332H\230\236\344\1\244|\26?\t\221\375\27"..., 48) = 48
>>>time(NULL)                              = 1114756567
>>>time([1114756567])                      = 1114756567
>>>rt_sigaction(SIGPIPE, {SIG_IGN}, NULL, 8) = 0
>>>--- SIGSEGV (Segmentation fault) @ 0 (0) ---
>>>+++ killed by SIGSEGV +++
>>>
>>>
>>>   
>>>
>>>      
>>>
>> 
>>
>>    
>>
>
>  
>

-- 
Thanks,
Marshall McMullen

The road to ruin is always in good repair, and the travellers pay the
expense of it.
		-- Josh Billings



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
