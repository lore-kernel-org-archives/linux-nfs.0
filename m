From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: FW: RHEL 3.0 update 2 doesn't have fix for posix locking bug
Date: Fri, 21 May 2004 16:00:06 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435E0BF@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BRIzv-00088A-34
	for nfs@lists.sourceforge.net; Fri, 21 May 2004 16:00:15 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BRIzu-0005PK-QY
	for nfs@lists.sourceforge.net; Fri, 21 May 2004 16:00:14 -0700
Received: from hawk.corp.netapp.com (hawk [10.57.156.122])
	by mx01.netapp.com (8.12.10/8.12.10/NTAP-1.4) with ESMTP id i4LN09Mj008295
	for <nfs@lists.sourceforge.net>; Fri, 21 May 2004 16:00:09 -0700 (PDT)
Received: from svlexc01.hq.netapp.com (svlexc01.corp.netapp.com [10.57.156.135])
	by hawk.corp.netapp.com (8.12.9/8.12.9/NTAP-1.5) with ESMTP id i4LN08Al022657
	for <nfs@lists.sourceforge.net>; Fri, 21 May 2004 16:00:09 -0700 (PDT)
To: <nfs@lists.sourceforge.net>
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

saw this originally in SLES 8 SP 3 a while back, now we've verified it
in RHEL 3.0 update 2 as well.  when running with multiple threads, sio
appears to hit a bug in the POSIX locking code in 2.4.

-----Original Message-----
From: Lever, Charles=20
Sent: Friday, May 21, 2004 3:53 PM
To: Steve Dickson
Cc: 'Trond Myklebust'; Suggs, Darrell
Subject: RHEL 3.0 update 2 doesn't have fix for posix locking bug


got this oops running sio (5.46) on my RHEL 3.0 update 2 system:

NMI Watchdog detected LOCKUP on CPU0, eip 02157674, registers:

CPU:    0
EIP:    0060:[<02157674>]    Not tainted
EFLAGS: 00000086

EIP is at .text.lock.usercopy [kernel] 0x2f (2.4.21pre1/i686)
eax: 02605c80   ebx: 00000000   ecx: 00000000   edx: 00000000
esi: 021c7b85   edi: 04807c04   ebp: 04807c04   esp: 04807ba4
ds: 0068   es: 0068   ss: 0068
Process sio_linux (pid: 5861, stackpage=3D04807000)
Stack: 00000010 024706c0 00000010 02605c80 00000000 021c7b85 04807c04
00000002
       0215741b 021c7b85 04807c04 00000002 00000000 00000000 021c7b85
fffffff2
       04807d9c 0210abed 00000002 04807c04 021c7b85 00000006 00003733
00003746
Call Trace:   [<021c7b85>] nlmclnt_proc [kernel] 0x1b5 (0x04807bb8)
[<0215741b>] get_user_size [kernel] 0x4b (0x04807bc4) [<021c7b85>]
nlmclnt_proc [kernel] 0x1b5 (0x04807bc8) [<021c7b85>] nlmclnt_proc
[kernel] 0x1b5 (0x04807bdc) [<0210abed>] handle_BUG [kernel] 0x5d
(0x04807be8) [<021c7b85>] nlmclnt_proc [kernel] 0x1b5 (0x04807bf4)
[<0211b950>] do_page_fault [kernel] 0x0 (0x04807c10) [<0210ad10>] die
[kernel] 0x40 (0x04807c18) [<0211bc21>] do_page_fault [kernel] 0x2d1
(0x04807c2c) [<02324a5b>] rpc_call_sync [kernel] 0xcb (0x04807c74)
[<0211b950>] do_page_fault [kernel] 0x0 (0x04807cd0) [<021c0068>]
nfs_update_request [kernel] 0x158 (0x04807d00) [<021c7b85>] nlmclnt_proc
[kernel] 0x1b5 (0x04807d0c) [<021b852d>] nfs_lock [kernel] 0x1fd
(0x04807f34) [<021c1a9a>] nfs_sync_file [kernel] 0x7a (0x04807f4c)
[<021712da>] locks_remove_posix [kernel] 0xda (0x04807f74) [<02158cd7>]
filp_close [kernel] 0x87 (0x04807f94) [<02158d86>] sys_close [kernel]
0x66 (0x04807fb0)

trond, don't you have a fix for this for 2.4 kernels?

        - Chuck Lever
--
corporate:     <cel at netapp dot com>
personal:      <chucklever at bigfoot dot com>


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
