From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: Oops with kerberos flavor on 2.6.23-rc9-CITI_NFS4_ALL-1
Date: Thu, 11 Oct 2007 10:01:12 +0200
Message-ID: <470DD848.2090204@bull.net>
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

Running 2.6.23-rc9-CITI_NFS4_ALL-1 on two Intel X86_64 two ways machines 
as client and server with NFSV4 mounting
using kerberos flavors (krb5 or krb5i or krb5p),
I get the following Oops when running several robustness tests 
(fsx,iozone,fssb,connectathon,fss_stress):

frec kernel: Unable to handle kernel NULL pointer dereference at 
0000000000000080 RIP:
frec kernel:  [<ffffffff805ac308>] svc_gss_principal+0x12/0x1a
frec kernel: PGD 2bd43067 PUD 2c1bb067 PMD 0
frec kernel: Oops: 0000 [1] SMP
frec kernel: CPU 0
frec kernel: Modules linked in: hidp hid rfcomm l2cap bluetooth 
dm_multipath backlight radeon drm
parport_pc lp parport floppy nvram e752x_edac edac_core i6300esb 
i2c_i801 i2c_core dm_snapshot dm_zero dm_mirror dm_mod
frec kernel: Pid: 3280, comm: nfsd Not tainted 2.6.23-rc9-CITI_NFS4_ALL-1 #2
frec kernel: RIP: 0010:[<ffffffff805ac308>]  [<ffffffff805ac308>] 
svc_gss_principal+0x12/0x1a
frec kernel: RSP: 0018:ffff81006555bd78  EFLAGS: 00010286
frec kernel: RAX: 0000000000000000 RBX: ffff81007c1e0a00 RCX: 
0000000000000000
frec kernel: RDX: ffff810065153c00 RSI: 0000000000000028 RDI: 
ffff8100655d2000
frec kernel: RBP: ffffffff808b5ed0 R08: ffff8100604706e0 R09: 
0000000000000000
frec kernel: R10: ffff81006a8641c0 R11: 0000000000000058 R12: 
0000000000000000
frec kernel: R13: ffff8100655d2000 R14: ffff8100655d2028 R15: 
ffff8100657e4080
frec kernel: FS:  00002b97ba3c06f0(0000) GS:ffffffff807a1000(0000) 
knlGS:0000000000000000
frec kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
frec kernel: CR2: 0000000000000080 CR3: 000000002bd40000 CR4: 
00000000000006e0
frec kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
frec kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
frec kernel: Process nfsd (pid: 3280, threadinfo ffff81006555a000, task 
ffff81007d0ee860)
frec kernel: Stack:  ffffffff8034702f 0000000000000286 ffffffff808b5ed0 
3439653362313538
frec kernel:  3633316539316532 3462383431386532 3232313935306462 
0000000000000000
frec kernel:  ffffffff805b39ad ffffffff00000028 ffff81005a53b080 
ffff81006555be10
frec kernel: Call Trace:
frec kernel:  [<ffffffff8034702f>] nfsd4_setclientid+0x247/0x496
frec kernel:  [<ffffffff805b39ad>] _spin_unlock_bh+0x9/0x15
frec kernel:  [<ffffffff8033d453>] nfsd4_proc_compound+0x1ad/0x2b9
frec kernel:  [<ffffffff8032ecb5>] nfsd_dispatch+0xde/0x1b6

------------------------------------------------------------- 
See Bug: 
  http://bugzilla.linux-nfs.org/show_bug.cgi?id=149  

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
