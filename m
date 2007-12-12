From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: Kernel Bug with 2.6.24-rc2-CITI_NFS4-ALL-1  in net/sunrpc/svc_xprt.c
Date: Wed, 12 Dec 2007 15:49:01 +0100
Message-ID: <475FF4DD.6010700@bull.net>
References: <4757D2B5.4070800@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: nfsv4 <nfsv4@linux-nfs.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:53681 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbXLLOs2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2007 09:48:28 -0500
In-Reply-To: <4757D2B5.4070800@bull.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi,
Running as client RHEL5.1 Public Gold on a X86_64 bi-ways and
as server 2.6.24-rc2-CITI_NFS4_ALL-1 on a X86_64 bi-ways,
I get the following Oops on the server when on the client I run
in a infinite loop iozone with -U option:

while true
do
./iozone -+q 30 -ace -r 64 -i 0 -i 1 -i 2 -f /mnt/nosec/nfs4_gb -U 
/mnt/nosec
date
sleep 30
done

=============================================================================
Fedora Core release 6 (Zod)
Kernel 2.6.24-rc2-CITI_NFS4_ALL-1 on an x86_64

nfs4gb login: ------------[ cut here ]------------
kernel BUG at net/sunrpc/svc_xprt.c:323!
invalid opcode: 0000 [1] SMP
Entering kdb (current=0xffff8100031e6080, pid 3227) on processor 1 Oops: 
<NULL>
due to oops @ 0xffffffff805bfef1
     r15 = 0x0000000000001000      r14 = 0xffff810006cfc000
     r13 = 0xffff8100035363c0      r12 = 0xffff810004c30bc0
     rbp = 0xffff810007df4000      rbx = 0xffff810006994000
     r11 = 0xffff8100098c1d80      r10 = 0x0000000000007d2b
      r9 = 0x0000000000000004       r8 = 0xffff810004df9180
     rax = 0x0000000000041000      rcx = 0x0000000000000001
     rdx = 0x0000000000000000      rsi = 0x0000000000000001
     rdi = 0xffff810006994010 orig_rax = 0xffffffffffffffff
     rip = 0xffffffff805bfef1       cs = 0x0000000000000010
  eflags = 0x0000000000010203      rsp = 0xffff810007d73d90
      ss = 0x0000000000000018 &regs = 0xffff810007d73cf8
[1]kdb>
[1]kdb> bt
Stack traceback for pid 3227
0xffff8100031e6080     3227        2  1    1   R  0xffff8100031e63a0 *nfsd
rsp                rip                Function (args)
0xffff810007d73d78 0xffffffff805bfef1 svc_xprt_enqueue+0x19a 
(0xffff810006994000)
0xffff810007d73dc8 0xffffffff805b9198 svc_tcp_recvfrom+0x367 
(0xffff810006cfc000)
0xffff810007d73e48 0xffffffff805c0db8 svc_recv+0x62d 
(0xffff810006cfc000, 0xdbba0)
0xffff810007d73f08 0xffffffff803329db nfsd+0xdb (0xffff810006cfc000)
0xffff810007d73f48 0xffffffff8020cbf8 child_rip+0xa (invalid, invalid)
[1]kdb>

More at:
Bug:  http://bugzilla.linux-nfs.org/show_bug.cgi?id=155

Regards


-- 
-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic 
Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
Fax     : 33 (4) 76.29.75.18
----------------------------------------------------------------- 

