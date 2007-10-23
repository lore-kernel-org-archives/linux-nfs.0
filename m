From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: nfsd 100% cpu usage with linux-2.6.23-rc9-CITI_NFS4_ALL-1
Date: Tue, 23 Oct 2007 13:39:39 +0200
Message-ID: <471DDD7B.9040003@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: nfsv4 <nfsv4@linux-nfs.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

Hi,

Running 2.6.23-rc9-CITI_NFS4_ALL-1 on one Intel X86_64 bi-ways machine acting
as client and server, if I do a NFSV4 mounting on itself
I get after about 1-2 hours a nfsd loop using 100% cpu  suspending several
robustness tests (fsx,iozone,fssb,connectathon,fss_stress) which were running.

You will find more traces at :

Bug: 
  http://bugzilla.linux-nfs.org/show_bug.cgi?id=152  
  

Here are some:

  Top gives:
~~~~~~~~~~~
top - 10:00:28 up 3 days, 17:03,  8 users,  load average: 21.05, 21.02, 20.94
Tasks: 178 total,   5 running, 173 sleeping,   0 stopped,   0 zombie
Cpu(s):  0.0%us, 50.0%sy,  0.0%ni, 49.8%id,  0.0%wa,  0.0%hi,  0.2%si,  0.0%st
Mem:   2056356k total,  2039940k used,    16416k free,   363516k buffers
Swap:        0k total,        0k used,        0k free,   480960k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
 3459 root      20   0     0    0    0 R  100  0.0   1051:05 nfsd
    1 root      20   0 10312  668  552 S    0  0.0   0:04.18 init
    2 root      15  -5     0    0    0 S    0  0.0   0:00.40 kthreadd

nfssd_debug gives in /var/log/messages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
root@nfs1gb ~]# echo 32767 > /proc/sys/sunrpc/nfsd_debug

Oct 23 09:56:16 frec kernel: NFSD: laundromat_main - sleeping for 90 seconds
Oct 23 09:57:46 frec kernel: NFSD: laundromat service - starting
Oct 23 09:57:46 frec kernel: NFSD: laundromat_main - sleeping for 90 seconds
Oct 23 09:57:46 frec kernel: NFSD: laundromat service - starting

echo "t" >/proc/sysrq-trigger gives in /var/log/messages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
kernel:
kernel: nfsd4         S ffff81005e5cdc98  6184  3454      2
kernel:  ffff81005e587ed0 0000000000000046 ffff8100716a6440 ffff81005e587e70
kernel:  ffffffff808b60d0 ffff8100653a67a0 ffff81007dda07e0 ffff8100653a69a8
kernel:  000000015e587e70 ffff81005e587e70 00000000ffffffff 0000000000000246
kernel: Call Trace:
kernel:  [<ffffffff80238aa9>] worker_thread+0x74/0x9b
kernel:  [<ffffffff8023b818>] autoremove_wake_function+0x0/0x2e
kernel:  [<ffffffff80238a35>] worker_thread+0x0/0x9b
kernel:  [<ffffffff8023b706>] kthread+0x47/0x75
kernel:  [<ffffffff8020c978>] child_rip+0xa/0x12
kernel:  [<ffffffff8023b6bf>] kthread+0x0/0x75
kernel:  [<ffffffff8020c96e>] child_rip+0x0/0x12

kernel:
kernel: nfsd          S 0000000104c723ee  3784  3455      2
kernel:  ffff81005e6a3df0 0000000000000046 ffff810001190000 ffff81005e6a3e00
kernel:  ffff81005e6a3dc8 ffff81006561e080 ffff810064c29100 ffff81006561e288
kernel:  0000000100000000 ffff81005e6a3e00 0000000000000286 0000000000000286
kernel: Call Trace:
kernel:  [<ffffffff80231cec>] __mod_timer+0xb6/0xc4
kernel:  [<ffffffff805b2b56>] schedule_timeout+0x8a/0xad
kernel:  [<ffffffff80231aa9>] process_timeout+0x0/0x5
kernel:  [<ffffffff805a9bcb>] svc_recv+0x278/0x719
kernel:  [<ffffffff805a938e>] svc_send+0x77/0xa1
kernel:  [<ffffffff805a0cc1>] svc_process+0x452/0x6dd
kernel:  [<ffffffff802236a1>] default_wake_function+0x0/0xe
kernel:  [<ffffffff8032f5d3>] nfsd+0xdb/0x2ac
kernel:  [<ffffffff8020c978>] child_rip+0xa/0x12
kernel:  [<ffffffff8032f4f8>] nfsd+0x0/0x2ac
kernel:  [<ffffffff8020c96e>] child_rip+0x0/0x12
kernel:
kernel:
kernel:
kernel: nfsd          R  running task     3784  3459      2
kernel: nfsd          S 0000000104c723ee  3608  3460      2
kernel:  ffff81005e00bdf0 0000000000000046 ffff810001190000 ffff81005e00be00
kernel:  ffff81005e00bdc8 ffff8100721b7040 ffff81000117a040 ffff8100721b7248
kernel:  0000000100000000 ffff81005e00be00 0000000000000286 0000000000000286
kernel: Call Trace:
kernel:  [<ffffffff80231cec>] __mod_timer+0xb6/0xc4
kernel:  [<ffffffff805b2b56>] schedule_timeout+0x8a/0xad
kernel:  [<ffffffff80231aa9>] process_timeout+0x0/0x5
kernel:  [<ffffffff805a9bcb>] svc_recv+0x278/0x719
kernel:  [<ffffffff805a938e>] svc_send+0x77/0xa1
kernel:  [<ffffffff805a0cc1>] svc_process+0x452/0x6dd
kernel:  [<ffffffff802236a1>] default_wake_function+0x0/0xe
kernel:  [<ffffffff8032f5d3>] nfsd+0xdb/0x2ac
kernel:  [<ffffffff8020c978>] child_rip+0xa/0x12
kernel:  [<ffffffff8032f4f8>] nfsd+0x0/0x2ac
kernel:  [<ffffffff8020c96e>] child_rip+0x0/0x12
kernel:
kernel:
kernel: nfsd          S 0000000000000000  3992  3461      2
kernel:  ffff81005e04ddf0 0000000000000046 ffff81005e04ddb8 ffff81005e04de00
kernel:  ffff81005e04ddc8 ffff81005e049820 ffff81000117a7a0 ffff81005e049a28
kernel:  0000000100000000 ffff81005e04de00 00000000ffffffff 0000000000000286
kernel: Call Trace:
kernel:  [<ffffffff805b2b56>] schedule_timeout+0x8a/0xad
kernel:  [<ffffffff80231aa9>] process_timeout+0x0/0x5
kernel:  [<ffffffff805a9bcb>] svc_recv+0x278/0x719
kernel:  [<ffffffff805a938e>] svc_send+0x77/0xa1
kernel:  [<ffffffff805a0cc1>] svc_process+0x452/0x6dd
kernel:  [<ffffffff802236a1>] default_wake_function+0x0/0xe
kernel:  [<ffffffff8032f5d3>] nfsd+0xdb/0x2ac
kernel:  [<ffffffff8020c978>] child_rip+0xa/0x12
kernel:  [<ffffffff8032f4f8>] nfsd+0x0/0x2ac
kernel:  [<ffffffff8020c96e>] child_rip+0x0/0x12


Cheers
-- 
-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic 
Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
Fax     : 33 (4) 76.29.75.18
----------------------------------------------------------------- 
