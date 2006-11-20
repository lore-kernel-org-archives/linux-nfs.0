From: "Ulrich Windl" <ulrich.windl@rz.uni-regensburg.de>
Subject: 2.6.16 with XEN (x86_64): nfsserver crashed kernel?
Date: Mon, 20 Nov 2006 12:17:11 +0100
Message-ID: <45619CC9.25908.1060C916@Ulrich.Windl.rkdvmks1.ngate.uni-regensburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gm79v-0006F7-Tf
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 03:17:56 -0800
Received: from rrzmta2.rz.uni-regensburg.de ([132.199.1.17])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gm79r-0008Qo-LV
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 03:17:54 -0800
Received: from rrzmta2.rz.uni-regensburg.de (localhost [127.0.0.1])
	by localhost (Postfix) with SMTP id C7C746D379
	for <nfs@lists.sourceforge.net>; Mon, 20 Nov 2006 12:17:46 +0100 (CET)
Received: from kgate1.dvm.klinik.uni-regensburg.de
	(kgate1.klinik.uni-regensburg.de [132.199.176.18])
	by rrzmta2.rz.uni-regensburg.de (Postfix) with ESMTP id B8D1B6D376
	for <nfs@lists.sourceforge.net>; Mon, 20 Nov 2006 12:17:46 +0100 (CET)
Received: from rkdvmks1.ngate.uni-regensburg.de
	(rkdvmks1.dvm.klinik.uni-regensburg.de [132.199.176.1])
	by kgate1.dvm.klinik.uni-regensburg.de
	(8.12.11.20060308/8.12.11/20051103MT-1) with ESMTP id kAKBHcSu016340
	for <nfs@lists.sourceforge.net>; Mon, 20 Nov 2006 12:17:38 +0100
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

while investigating the problem of being unable to get NFS locks with SLES10 on 
AMD Opteron in XEN (kernel-xen-2.6.16.21-0.25), it seems NFS server crashed the 
kernel during shutdown. I have a log from serial console:

Boot logging started on /dev/ttyS0(/dev/console) at Mon Nov 20 11:23:17 2006
Master Resource Control: previous runlevel: 3, switching to runlevel: 
[80C[10D[1m6[m

Shutting down the Firewall [80C[10D[1;33mskipped[m
Unable to handle kernel paging request at 0000000100000027 RIP: 
<ffffffff8012746c>{dup_fd+412}
PGD 13b1e067 PUD 0 
Oops: 0002 [1] SMP 
last sysfs file: /devices/pci0000:00/0000:00:01.0/0000:01:01.1/subsystem_device
CPU 2 
Modules linked in: nfs nfsd exportfs lockd nfs_acl sunrpc hfs vfat fat joydev st 
nls_utf8 xt_pkttype ipt_LOG xt_limit ipt_TCPMSS xt_physdev bridge blkbk netbk 
netloop af_packet bonding button battery ac ip6t_REJECT xt_tcpudp ipt_REJECT 
xt_state iptable_mangle iptable_nat ip_nat sr_mod iptable_filter ip6table_mangle 
ip_conntrack nfnetlink ip_tables ip6table_filter ip6_tables x_tables ipv6 loop 
usb_storage usbhid hw_random ohci_hcd i2c_amd756 usbcore shpchp i2c_amd8111 
i2c_core pci_hotplug ide_cd cdrom e1000 reiserfs dm_snapshot dm_mod fan thermal 
processor sg mptsas mptscsih mptbase scsi_transport_sas amd74xx sd_mod scsi_mod 
ide_disk ide_core
Pid: 27024, comm: nfsserver Not tainted 2.6.16.21-0.25-xen #1
RIP: e030:[<ffffffff8012746c>] <ffffffff8012746c>{dup_fd+412}
RSP: e02b:ffff88000e013d98  EFLAGS: 00010206
RAX: dfffffffffffffff RBX: ffff8800155bd800 RCX: 000000000000003d
RDX: 0000000000000000 RSI: ffff88000f1b9000 RDI: 00000000ffffffff
RBP: ffff880000666b80 R08: 000000000000003e R09: ffff8800186362c0
R10: ffff880014aa49f0 R11: 000000000000003e R12: 0000000000000100
R13: ffff8800089c5b80 R14: ffff8800089c5ed8 R15: ffff88000e013e04
FS:  00002b37d9ce9ae0(0000) GS:ffffffff80421100(0000) knlGS:0000000000000000
CS:  e033 DS: 0000 ES: 0000
Process nfsserver (pid: 27024, threadinfo ffff88000e012000, task 
ffff8800075b2080)
Stack: 0000000045618214 ffff8800005b3350 ffff8800005b3350 ffff8800005b3100 
       00000001075b2080 ffff8800005b3100 0000000000000000 ffff8800005b3100 
       ffff8800075b2080 0000000000000000 
Call Trace: <ffffffff8012759d>{copy_files+79} 
<ffffffff801281d3>{copy_process+1235}
       <ffffffff801297d4>{do_fork+197} <ffffffff8010aa6a>{system_call+134}
       <ffffffff80179bff>{sys_newstat+40} <ffffffff80134b82>{sigprocmask+180}
       <ffffffff8010aa6a>{system_call+134} 
<ffffffff8010ae25>{ptregscall_common+61}

Code: f0 ff 47 28 eb 1f 49 8b 71 20 4c 89 c2 44 88 c1 48 c1 ea 06 
RIP <ffffffff8012746c>{dup_fd+412} RSP <ffff88000e013d98>
CR2: 0000000100000027
 

Ulrich


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
