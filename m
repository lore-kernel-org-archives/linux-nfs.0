Return-Path: <nfsv4-bounces@linux-nfs.org>
Message-ID: <48AE6C38.9040507@bull.net>
Date: Fri, 22 Aug 2008 09:35:20 +0200
From: Le Rouzic <aime.le-rouzic@bull.net>
To: nfsv4 <nfsv4@linux-nfs.org>
Subject: linux-2.6.27-rc3: kernel BUG at fs/nfs/write.c:252
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        nfs@lists.sourceforge.net
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Hi,
Client and server On Intel X86_64 with linux-2.6.27-rc3.

Doing several stress benchmarks simultaneously:
fsstress
iozone   (without  -U )
fsx
ffsb
cthon

The server crashed.

Here is the trace on the server:
------------[ cut here ]------------
kernel BUG at fs/nfs/write.c:252!

Entering kdb (current=0xffff8800621c78d0, pid 25953) on processor 1 due to
KDB_ENTER()
[1]kdb> bt
Stack traceback for pid 25953
0xffff8800621c78d0    25953     5308  1    1   R  0xffff8800621c7c38 *fsx-linux
sp                ip                Function (args)
0xffff8800660cdb88 0xffffffff80330871 nfs_do_writepage+0xe7
(0xffffe20001770140, invalid, 0xffff8800660cdd18)
0xffff8800660cdbf0 0xffffffff80330cd0 nfs_writepages_callback+0xf
(0xffffe20001770140)
0xffff8800660cdc10 0xffffffff802657f9 write_cache_pages+0x1ca
(0xffff880062402468, 0xffff8800660cddc8, 0xffffffff80330cc1,
0xffff8800660cdd18)
0xffff8800660cdd10 0xffffffff80330c95 nfs_writepages+0x72 (0xffff880062402468,
0xffff8800660cddc8)
0xffff8800660cdd90 0xffffffff803315b6 __nfs_write_mapping+0x19
(0xffff880062402468, 0xffff8800660cddc8, invalid)
0xffff8800660cddc0 0xffffffff80331655 nfs_write_mapping+0x68
(0xffff880062402468, invalid)
0xffff8800660cde30 0xffffffff80331675 nfs_wb_nocommit+0x15 (invalid)
0xffff8800660cde40 0xffffffff80327638 nfs_getattr+0x5c (0xffff88007fbbf1c0,
invalid, 0xffff8800660cdef8)
0xffff8800660cde80 0xffffffff8028c637 vfs_getattr+0x44 (0xffff88007fbbf1c0,
0xffff8800664e00b8, 0xffff8800660cdef8)
0xffff8800660cdec0 0xffffffff8028c687 vfs_fstat+0x33 (invalid,
0xffff8800660cdef8)
0xffff8800660cdef0 0xffffffff8028c6b8 sys_newfstat+0x1a (invalid,
0x7fffec90f890)
  not matched: from 0xffffffff8020bead to 0xffffffff8020bf25 drop_through 0
bb_jmp[7]
bb_special_case: Invalid bb_reg_state.memory, missing trailing entries
bb_special_case: on transfer to int_with_check
  system_call_fastpath has memory parameters but no register parameters.
  Assuming it is a 'pass through' function that does not refer to its register
  parameters and setting 6 register parameters
kdb_bb: 0xffffffff8020be3b [kernel]system_call_fastpath failed at
0xffffffff8020bec8

Using old style backtrace, unreliable with no arguments
sp                ip                Function (args)
0xffff8800660cdb88 0xffffffff80330871 nfs_do_writepage+0xe7
0xffff8800660cdbb0 0xffffffff80330871 nfs_do_writepage+0xe7
0xffff8800660cdbf0 0xffffffff80330cd0 nfs_writepages_callback+0xf
0xffff8800660cdc10 0xffffffff802657f9 write_cache_pages+0x1ca
0xffff8800660cdc20 0xffffffff80330cc1 nfs_writepages_callback
0xffff8800660cdc68 0xffffffff8032d3bc nfs_wait_bit_killable
0xffff8800660cdc80 0xffffffff80603a87 out_of_line_wait_on_bit+0x6e
0xffff8800660cdca8 0xffffffff8023f9b8 wake_bit_function
0xffff8800660cdd10 0xffffffff80330c95 nfs_writepages+0x72
0xffff8800660cdd50 0xffffffff80331c41 nfs_flush_one
0xffff8800660cdd90 0xffffffff803315b6 __nfs_write_mapping+0x19
0xffff8800660cddc0 0xffffffff80331655 nfs_write_mapping+0x68
0xffff8800660cde30 0xffffffff80331675 nfs_wb_nocommit+0x15
0xffff8800660cde40 0xffffffff80327638 nfs_getattr+0x5c
0xffff8800660cde80 0xffffffff8028c637 vfs_getattr+0x44
0xffff8800660cdec0 0xffffffff8028c687 vfs_fstat+0x33
0xffff8800660cdef0 0xffffffff8028c6b8 sys_newfstat+0x1a
0xffff8800660cdf40 0xffffffff80242540 up_write+0x9
0xffff8800660cdf50 0xffffffff802731c5 sys_munmap+0x4d

Bug registered at:



------------------------------------------------------------- 
Bug: 
 http://bugzilla.linux-nfs.org/show_bug.cgi?id=168 



Best Regards

-- 
-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic 
Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
Fax     : 33 (4) 76.29.75.18
----------------------------------------------------------------- 

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
