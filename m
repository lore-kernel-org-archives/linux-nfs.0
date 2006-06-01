From: "Ed L. Cashin" <ecashin@coraid.com>
Subject: nfsd pointer in __d_lookup
Date: Thu, 1 Jun 2006 16:12:57 -0400
Message-ID: <20060601201257.GE20253@coraid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fltuf-000510-MN
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 13:37:01 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fltuf-0001YK-Ev
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 13:37:01 -0700
Received: from ns1.coraid.com
	([65.14.39.133] helo=coraid.com ident=none)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Fltud-0007KX-Rj
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 13:37:01 -0700
To: nfs@lists.sourceforge.net
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

Hi.  On an x86_64 machine, the trace below appears in the system logs
just before NFS service becomes unavailable (until a reboot).

I'm working on getting more specifics, but this machine is exporting
an XFS on an LVM logical volume on one or more AoE device.  The aoe
driver in use is not the one in 2.6.16.18 (it's aoe6-23), but I'm
asking the end user to verify that this still happens with the aoe
driver in 2.6.16.18.

Meanwhile, I'm hoping that the trace below will look familiar to
someone.  It looks to me like a 32-bit all-ones value might have been
put into a 64-bit variable by mistake.

  Unable to handle kernel paging request at 00000000ffffffff RIP: 
  <ffffffff80179456>{__d_lookup+216}
  PGD 3d29d067 PUD 0 
  CPU 0 
  Modules linked in: ipv6 nfsd lockd nfs_acl sunrpc xfs exportfs dm_mod aoe i2c_i801 i2c_core piix md_mod rtc psmouse unix
  Pid: 2535, comm: nfsd Not tainted 2.6.16.18-c1 #8
  RIP: 0010:[__d_lookup+216/253] <ffffffff80179456>{__d_lookup+216}
  RSP: 0018:ffff81003e6dd958  EFLAGS: 00010206
  RAX: 00000000ffffffff RBX: ffff81003ca443c0 RCX: 0000000000000011
  RDX: 0000000000014faf RSI: 00c3df84ef894faf RDI: ffff810037552080
  RBP: 00000000ffffffff R08: 0000000000000000 R09: 0000000000000000
  R10: 000000000000000c R11: 0000000000000130 R12: ffff810037552080
  R13: ffff81003e6dd9c8 R14: 00000000d8788a14 R15: 000000000000000c
  FS:  00002b9fd29cbae0(0000) GS:ffffffff803e6000(0000) knlGS:0000000000000000
  CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
  CR2: 00000000ffffffff CR3: 000000003d29c000 CR4: 00000000000006e0
  Process nfsd (pid: 2535, threadinfo ffff81003e6dc000, task ffff81003f15f790)
  Stack: ffff81003c1e2be2 0000000000000000 ffff810037552080 ffff81003e6dd9c8 
         0000000000000000 ffff8100375547f8 ffff81003c53d140 ffffffff80170839 
         000000000000000c ffff810037552080 
  Call Trace: <ffffffff80170839>{__lookup_hash+96} <ffffffff80170935>{lookup_one_len+95}
         <ffffffff88116998>{:nfsd:compose_entry_fh+203} <ffffffff88119121>{:nfsd:encode_entry+453}
         <ffffffff88119431>{:nfsd:nfs3svc_encode_entry_plus+11}
         <ffffffff880ae26d>{:xfs:linvfs_readdir+325} <ffffffff88119426>{:nfsd:nfs3svc_encode_entry_plus+0}
         <ffffffff88119426>{:nfsd:nfs3svc_encode_entry_plus+0}
         <ffffffff801747de>{vfs_readdir+90} <ffffffff80163cdf>{default_llseek+0}
         <ffffffff88119426>{:nfsd:nfs3svc_encode_entry_plus+0}
         <ffffffff8810ebc4>{:nfsd:nfsd_readdir+108} <ffffffff88116391>{:nfsd:nfsd3_proc_readdirplus+244}
         <ffffffff8810b3c2>{:nfsd:nfsd_dispatch+221} <ffffffff880d6360>{:sunrpc:svc_process+975}
         <ffffffff802c652f>{__down_read+18} <ffffffff8810b648>{:nfsd:nfsd+451}
         <ffffffff8012c278>{do_exit+2054} <ffffffff8010b702>{child_rip+8}
         <ffffffff8810b485>{:nfsd:nfsd+0} <ffffffff8010b6fa>{child_rip+0}


-- 
  Ed L Cashin <ecashin@coraid.com>


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
