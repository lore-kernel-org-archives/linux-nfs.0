From: "Peter Lojkin" <ia6432@inbox.ru>
Subject: Another NFS related oops on smp servers
Date: Thu, 26 Dec 2002 17:48:03 +0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18RZIp-00011c-00@f10.mail.ru>
Reply-To: "Peter Lojkin" <ia6432@inbox.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx10.mail.ru ([194.67.57.20])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18RZIu-0002qh-00
	for <nfs@lists.sourceforge.net>; Thu, 26 Dec 2002 06:48:09 -0800
Received: from f10.int ([10.0.0.78] helo=f10.mail.ru)
	by mx10.mail.ru with esmtp (Exim MX.A)
	id 18RZIp-0000Fo-00
	for nfs@lists.sourceforge.net; Thu, 26 Dec 2002 17:48:03 +0300
Received: from mail by f10.mail.ru with local (Exim FE.10)
	id 18RZIp-00011c-00
	for nfs@lists.sourceforge.net; Thu, 26 Dec 2002 17:48:03 +0300
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

we had 3 nfs related oopses on our servers in 2 days. such oopses
never happened before. the kernel on oopsed servers is basically
2.4.20aa1 + trond's waitq fix. one of the oopsed servers had also
trond's fix for another our oops problem, discussed earlier.
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

after oops any process accessing nfs hangs.

ksymoops parsed kern.log:
==================================================================
Dec 24 16:43:36 raven kernel: 3136MB HIGHMEM available.
Dec 24 16:43:36 raven kernel: cpu: 0, clocks: 1002304, slice: 200460
Dec 24 16:43:36 raven kernel: cpu: 1, clocks: 1002304, slice: 200460
Dec 24 16:43:36 raven kernel: cpu: 2, clocks: 1002304, slice: 200460
Dec 24 16:43:36 raven kernel: cpu: 3, clocks: 1002304, slice: 200460
Dec 24 16:43:36 raven kernel:   Receiver lock-up bug exists -- enabling work-around.
Dec 24 16:43:36 raven kernel: e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex
Dec 26 16:20:14 raven kernel: kernel BUG at inode.c:1100!
Dec 26 16:20:14 raven kernel: invalid operand: 0000 2.4.20aa1 #1 SMP Tue Dec 24 16:00:13 MSK 2002
Dec 26 16:20:14 raven kernel: CPU:    2
Dec 26 16:20:14 raven kernel: EIP:    0010:[iput+32/508]    Not tainted
Dec 26 16:20:14 raven kernel: EFLAGS: 00010246
Dec 26 16:20:14 raven kernel: eax: 00000001   ebx: c7f15120   ecx: 00000000   edx: c7f15201
Dec 26 16:20:14 raven kernel: esi: c5767c00   edi: 00000000   ebp: e1924a60   esp: ccf6df3c
Dec 26 16:20:14 raven kernel: ds: 0018   es: 0018   ss: 0018
Dec 26 16:20:14 raven kernel: Process rpciod (pid: 406, stackpage=ccf6d000)
Dec 26 16:20:14 raven kernel: Stack: c7f15120 efa8dbc0 c7f152e8 c0191a08 c7f15120 e1924ab4 ccf6c000 c038d208
Dec 26 16:20:14 raven kernel:        00000000 e1924b90 e1924b08 e1924aec e1924a60 c02786f6 e1924a60 e1924a60
Dec 26 16:20:14 raven kernel:        ccf6c000 c038d208 00000000 ccf6c000 ccf6c000 c0355c00 ccf6dfdc c44fe000
Dec 26 16:20:14 raven kernel: Call Trace:    [nfs_writeback_done+764/1340] [__rpc_execute+726/880] [__rpc_schedule+231/364] [rpciod+245/584] [kernel_thread+40/56]
Dec 26 16:20:14 raven kernel: Code: 0f 0b 4c 04 92 49 29 c0 85 f6 74 03 8b 7e 20 85 ff 74 0d 8b


>>ebx; c7f15120 <END_OF_CODE+23df381/????>
>>edx; c7f15201 <END_OF_CODE+23df462/????>
>>esi; c5767c00 <_end+53897e4/5711be4>
>>ebp; e1924a60 <END_OF_CODE+1bdeecc1/????>
>>esp; ccf6df3c <END_OF_CODE+743819d/????>

Code;  00000000 Before first symbol
00000000 <_EIP>:
Code;  00000000 Before first symbol
   0:   0f 0b                     ud2a
Code;  00000002 Before first symbol
   2:   4c                        dec    %esp
Code;  00000003 Before first symbol
   3:   04 92                     add    $0x92,%al
Code;  00000005 Before first symbol
   5:   49                        dec    %ecx
Code;  00000006 Before first symbol
   6:   29 c0                     sub    %eax,%eax
Code;  00000008 Before first symbol
   8:   85 f6                     test   %esi,%esi
Code;  0000000a Before first symbol
   a:   74 03                     je     f <_EIP+0xf> 0000000f Before first symbol
Code;  0000000c Before first symbol
   c:   8b 7e 20                  mov    0x20(%esi),%edi
Code;  0000000f Before first symbol
   f:   85 ff                     test   %edi,%edi
Code;  00000011 Before first symbol
  11:   74 0d                     je     20 <_EIP+0x20> 00000020 Before first symbol
Code;  00000013 Before first symbol
  13:   8b 00                     mov    (%eax),%eax

==================================================================




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
