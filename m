From: Andrew Ryan <andrewr@collab.net>
Subject: oops in FC1 update kernel, in refile_inode
Date: Mon, 26 Apr 2004 14:26:38 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <408D7E8E.7040801@collab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BIDdb-0001dR-IA
	for nfs@lists.sourceforge.net; Mon, 26 Apr 2004 14:27:39 -0700
Received: from laswell.sfo.collab.net ([64.125.134.138] helo=laswell.sp.collab.net)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1BIDdb-0005bP-AS
	for nfs@lists.sourceforge.net; Mon, 26 Apr 2004 14:27:39 -0700
To: nfs@lists.sourceforge.net
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

I realize that this list is the wrong place to go for Fedora/RH support, 
but we're having a unpleasant problem and I'm hoping someone here could 
shed some light on it. We're running load tests on Subversion with 
repositories on NFS-mounted filesystems, and getting reliable oops'es 
after a few hours-days of testing. With the repos on local disk, no 
oops, and the tests complete normally. For all I know, the bug has 
nothing to do with NFS, but there seems to be a correlation.

I filed a RH bugzilla issue today, which has a decoded oops, SysRq+T 
output, and vmstat output for the period preceding the crash.
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=121732

The hardware is dual Xeon 3.0GHz, running hyperthreading, kernel
2.4.22-1.2179.nptlsmp. The mount options in use are:
rw,tcp,nfsvers=3,rsize=32768,wsize=32768,intr
The NFS server is a NetApp. Both NFS client and server are running at
100Mb switched ethernet.

In the 2.4.26 kernel's Changelog
(http://kernel.org/pub/linux/kernel/v2.4/ChangeLog-2.4.26) I saw
mention of a refile_inode bug fixed by Trond, which made me think
perhaps this is what is affecting us, but I don't know. I'm all for 
trying out pretty much any patch which might help us.

A few minutes before the machine crashes, the virtual memory system
seems to deteriorate rapidly, with large amounts of 'si' and
especially 'so' traffic.

The bug doesn't seem to affect us on a RH 7.2-based system running a
vanilla 2.4.21 kernel that includes Trond's NFS-ALL patch cluster.


Unable to handle kernel NULL pointer dereference at virtual address
00000000
  printing eip:
c01690b7
*pde = 00000000
Oops: 0002
nfs lockd sunrpc iptable_filter ip_tables autofs tg3 keybdev mousedev
hid input usb-ohci usbcore ext3 jbd cciss sd_mod scsi_mod
CPU:    3
EIP:    0060:[<c01690b7>]    Not tainted
EFLAGS: 00010246

EIP is at refile_inode [kernel] 0x47 (2.4.22-1.2179.nptlsmp)
eax: 00000000   ebx: dc141b80   ecx: 00000000   edx: dc141b88
esi: c0375ea8   edi: c0374e58   ebp: 00023354   esp: e76a5dd4
ds: 0068   es: 0068   ss: 0068
Process svnlook (pid: 2038, stackpage=e76a5000)
Stack: c17de430 dc141c44 c013c5e2 dc141b80 c17de430 00000000 c17de430
c01460ca
        c17de430 000001d2 e76a4000 00000a57 000001d2 00000019 00000020
000001d2
        c0374e58 c0374e58 c01463ba e76a5e40 000001d2 0000003c 00000020
c0146432
Call Trace:   [<c013c5e2>] __remove_inode_page [kernel] 0x82 (0xe76a5ddc)
[<c01460ca>] shrink_cache [kernel] 0x30a (0xe76a5df0)
[<c01463ba>] shrink_caches [kernel] 0x4a (0xe76a5e1c)
[<c0146432>] try_to_free_pages_zone [kernel] 0x62 (0xe76a5e30)
[<f885827b>] ext3_do_update_inode [ext3] 0x19b (0xe76a5e38)
[<c0147012>] balance_classzone [kernel] 0x52 (0xe76a5e54)
[<c0147348>] __alloc_pages [kernel] 0x188 (0xe76a5e70)
[<c013df51>] do_generic_file_read [kernel] 0x401 (0xe76a5eb0)
[<c013e3b0>] file_read_actor [kernel] 0x0 (0xe76a5ee0)
[<c013e575>] generic_file_new_read [kernel] 0xc5 (0xe76a5f00)
[<c013e3b0>] file_read_actor [kernel] 0x0 (0xe76a5f10)
[<c0163131>] do_select [kernel] 0x151 (0xe76a5f24)
[<c013e69f>] generic_file_read [kernel] 0x2f (0xe76a5f4c)
[<f89fd608>] nfs_file_read [nfs] 0x98 (0xe76a5f64)
[<c01504ba>] sys_pread [kernel] 0xca (0xe76a5f8c)
[<c0109b27>] system_call [kernel] 0x33 (0xe76a5fc0)




-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
