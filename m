From: "Peter Lojkin" <ia6432@inbox.ru>
Subject: NFS oopses on smp servers
Date: Sun, 15 Dec 2002 17:58:12 +0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18NaDc-000MXq-00@f20.mail.ru>
Reply-To: "Peter Lojkin" <ia6432@inbox.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx1.mail.ru ([194.67.57.11])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18NaDf-0006WR-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Dec 2002 06:58:15 -0800
Received: from f20.int ([10.0.0.142] helo=f20.mail.ru)
	by mx1.mail.ru with esmtp (Exim MX.1)
	id 18NaDc-0006fs-00
	for nfs@lists.sourceforge.net; Sun, 15 Dec 2002 17:58:12 +0300
Received: from mail by f20.mail.ru with local (Exim FE.1)
	id 18NaDc-000MXq-00
	for nfs@lists.sourceforge.net; Sun, 15 Dec 2002 17:58:12 +0300
To: nfs@lists.sourceforge.net
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

Hello,

we keep getting nfs related oopses on our servers. we tried stock
2.4.19 and 2.4.20, ac kernels, aa kernels, with and without different
mix of trond and neilb patches.
the setup is:
 - intel 4-way smp general-purpose servers with debian 3.0
 - intel and sparc fileservers with solaris8
 - intel workstations with solaris7/8, redhat 7.2/7.3 and debian 3.0

the workload is mostly software development. developers are running
simultaneous builds on our genereal-purpose servers, accessing a
multitude of files exported from fileservers and workstations in
parallel. there's no nfsd running on workservrs. we use autofs with
no special mount options, so we get
rw,nosuid,v3,rsize=8192,wsize=8192,hard,intr,udp,lock
for linux exports and
rw,nosuid,v3,rsize=32768,wsize=32768,hard,intr,udp,lock
for solaris exports.

oopses are hard to track, they happen once or twice a week on random
server with nothing unusual in workload or logs prior to it. none of
our tests (high load, network disconnects, lost packets, etc.)
triggered the problem, so we can't provide a test case.

when we had nfs compiled as module (autoloaded) we had this oopses
(ksymoops from kern.log):
==================================================================
Nov 14 11:44:43 server kernel: Unable to handle kernel NULL pointer dereference at virtual address 00000000
Nov 14 11:44:43 server kernel: f8a4d441
Nov 14 11:44:43 server kernel: *pde = 00000000
Nov 14 11:44:43 server kernel: Oops: 0000
Nov 14 11:44:43 server kernel: CPU:    2
Nov 14 11:44:43 server kernel: EIP:    0010:[nfs:__insmod_nfs_S.text_L62016+21473/62016]    Not tainted
Nov 14 11:44:43 server kernel: EFLAGS: 00010246
Nov 14 11:44:43 server kernel: eax: 00000000   ebx: e7c48f80   ecx: e7c48f88   edx: e7c48f88
Nov 14 11:44:43 server kernel: esi: f1ac9e00   edi: f28b30fc   ebp: e7c48f80   esp: f1ac9de0
Nov 14 11:44:43 server kernel: ds: 0018   es: 0018   ss: 0018
Nov 14 11:44:43 server kernel: Process test1 (pid: 10621, stackpage=f1ac9000)
Nov 14 11:44:43 server kernel: Stack: 00000000 f8a4dabc e7c48f80 e7c48f80 ec8897c0 f28b30fc 00000000 f1ac8000 
Nov 14 11:44:43 server kernel:        f1ac9e00 f1ac9e00 f8a4d2e8 f28b30fc 00000000 ebb1a780 00000000 ebb1a938 
Nov 14 11:44:43 server kernel:        f8a5204e f8a507c8 00000000 ebb1a780 c418f168 00000000 00001000 c418f168 
Nov 14 11:44:43 server kernel: Call Trace:    [nfs:__insmod_nfs_S.text_L62016+23132/62016] [nfs:__insmod_nfs_S.text_L62016+21128/62016] [nfs:__insmod_nfs_S.text_L62016+40942/62016] [nfs:__insmod_nfs_S.text_L62016+34664/62016] [nfs:__insmod_nfs_S.text_L62016+32758/62016]
Nov 14 11:44:43 server kernel: Code: 8b 00 85 c0 7d 08 0f 0b a9 00 57 86 a5 f8 53 e8 0b ff ff ff 
Using defaults from ksymoops -t elf32-i386 -a i386


>>ebx; e7c48f80 <_end+2790d20c/386b428c>
>>ecx; e7c48f88 <_end+2790d214/386b428c>
>>edx; e7c48f88 <_end+2790d214/386b428c>
>>esi; f1ac9e00 <_end+3178e08c/386b428c>
>>edi; f28b30fc <_end+32577388/386b428c>
>>ebp; e7c48f80 <_end+2790d20c/386b428c>
>>esp; f1ac9de0 <_end+3178e06c/386b428c>

Code;  00000000 Before first symbol
00000000 <_EIP>:
Code;  00000000 Before first symbol
   0:   8b 00                     mov    (%eax),%eax
Code;  00000002 Before first symbol
   2:   85 c0                     test   %eax,%eax
Code;  00000004 Before first symbol
   4:   7d 08                     jge    e <_EIP+0xe> 0000000e Before first symbol
Code;  00000006 Before first symbol
   6:   0f 0b                     ud2a   
Code;  00000008 Before first symbol
   8:   a9 00 57 86 a5            test   $0xa5865700,%eax
Code;  0000000d Before first symbol
   d:   f8                        clc    
Code;  0000000e Before first symbol
   e:   53                        push   %ebx
Code;  0000000f Before first symbol
   f:   e8 0b ff ff ff            call   ffffff1f <_EIP+0xffffff1f> ffffff1f <END_OF_CODE+75a5ba4/????>

Nov 15 18:58:33 server kernel: 3136MB HIGHMEM available.
Nov 15 18:58:34 server kernel: cpu: 0, clocks: 1002260, slice: 200452
Nov 15 18:58:34 server kernel: cpu: 1, clocks: 1002260, slice: 200452
Nov 15 18:58:34 server kernel: cpu: 2, clocks: 1002260, slice: 200452
Nov 15 18:58:34 server kernel: cpu: 3, clocks: 1002260, slice: 200452
Nov 15 18:58:34 server kernel:   Receiver lock-up bug exists -- enabling work-around.
Nov 15 18:58:34 server kernel: e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex
==================================================================



when we tried to compile nfs in kernel we start getting this oopes:
==================================================================
Dec 12 04:09:46 server kernel: Unable to handle kernel NULL pointer dereference at virtual address 00000000
Dec 12 04:09:46 server kernel: c018d381
Dec 12 04:09:46 server kernel: *pde = 00000000
Dec 12 04:09:46 server kernel: Oops: 0000 2.4.20-aa1 #1 SMP Thu Dec 5 12:01:04 GMT 2002
Dec 12 04:09:46 server kernel: CPU:    0
Dec 12 04:09:46 server kernel: EIP:    0010:[nfs_release_request+137/180]    Not tainted
Dec 12 04:09:46 server kernel: EFLAGS: 00010246
Dec 12 04:09:46 server kernel: eax: 00000000   ebx: dab0f240   ecx: dab0f248   edx: dab0f248
Dec 12 04:09:46 server kernel: esi: c68fb4fc   edi: c68fb4fc   ebp: dab0f240   esp: edfd9e4c
Dec 12 04:09:46 server kernel: ds: 0018   es: 0018   ss: 0018
Dec 12 04:09:46 server kernel: Process test2 (pid: 19656, stackpage=edfd9000)
Dec 12 04:09:46 server kernel: Stack: 00000000 c018da0c dab0f240 dab0f240 c82d3700 c68fb4fc 00000000 edfd8000 
Dec 12 04:09:46 server kernel:        edfd9e6c edfd9e6c c018d228 c68fb4fc 00000000 00000000 00000000 d83d4bb8 
Dec 12 04:09:46 server kernel:        c544f4d4 c01906c8 d3962c20 d83d4a00 c14ff2e0 00000000 00000200 d4cd3ce0 
Dec 12 04:09:46 server kernel: Call Trace:    [nfs_try_to_free_pages+268/288] [nfs_create_request+168/288] [nfs_update_request+544/828] [nfs_updatepage+165/516] [nfs_commit_write+63/108]
Dec 12 04:09:46 server kernel: Code: 8b 00 85 c0 7d 08 0f 0b a9 00 52 0c 2a c0 53 e8 0b ff ff ff 


>>ebx; dab0f240 <END_OF_CODE+13fecfbd/????>
>>ecx; dab0f248 <END_OF_CODE+13fecfc5/????>
>>edx; dab0f248 <END_OF_CODE+13fecfc5/????>
>>esi; c68fb4fc <_end+651f120/6723c24>
>>edi; c68fb4fc <_end+651f120/6723c24>
>>ebp; dab0f240 <END_OF_CODE+13fecfbd/????>
>>esp; edfd9e4c <END_OF_CODE+274b7bc9/????>

Code;  00000000 Before first symbol
00000000 <_EIP>:
Code;  00000000 Before first symbol
   0:   8b 00                     mov    (%eax),%eax
Code;  00000002 Before first symbol
   2:   85 c0                     test   %eax,%eax
Code;  00000004 Before first symbol
   4:   7d 08                     jge    e <_EIP+0xe> 0000000e Before first symbol
Code;  00000006 Before first symbol
   6:   0f 0b                     ud2a   
Code;  00000008 Before first symbol
   8:   a9 00 52 0c 2a            test   $0x2a0c5200,%eax
Code;  0000000d Before first symbol
   d:   c0 53 e8 0b               rclb   $0xb,0xffffffe8(%ebx)
Code;  00000011 Before first symbol
  11:   ff                        (bad)  
Code;  00000012 Before first symbol
  12:   ff                        (bad)  
Code;  00000013 Before first symbol
  13:   ff 00                     incl   (%eax)

Dec 15 11:06:01 server kernel: 3136MB HIGHMEM available.
Dec 15 11:06:01 server kernel: cpu: 0, clocks: 1002300, slice: 200460
Dec 15 11:06:01 server kernel: cpu: 1, clocks: 1002300, slice: 200460
Dec 15 11:06:01 server kernel: cpu: 3, clocks: 1002300, slice: 200460
Dec 15 11:06:01 server kernel: cpu: 2, clocks: 1002300, slice: 200460
Dec 15 11:06:01 server kernel:   Receiver lock-up bug exists -- enabling work-around.
Dec 15 11:06:01 server kernel: e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex
==================================================================




-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
