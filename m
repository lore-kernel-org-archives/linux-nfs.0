Return-Path: linux-nfs-owner@vger.kernel.org
Received: from intranet.asianux.com ([58.214.24.6]:55956 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617Ab2JOC3z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Oct 2012 22:29:55 -0400
Message-ID: <507B70F1.7040903@asianux.com>
Date: Mon, 15 Oct 2012 10:12:01 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>, Trond.Myklebust@netapp.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [Bug fix] nfs-client: fix nfs_inode_attrs_need_update for async read_done
 comes during truncating to smaller size
Content-Type: text/plain; charset=GB2312
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Trond Myklebust, Jeff Layton:

1) Root Cause:
   A) begin truncate to smaller, after async read finish starting.
   B) async read done come, after truncate operation change inode size.
   C) in nfs_inode_attrs_need_update, nfs_size_need_update return true.
      i)   the bigger size is the original old size of client itself.
      ii)  the smaller size is the current true size.
      iii) nfs_inode_attrs_need_update not consider this situation.

2) Fix nfs_size_need_update:
   A) delete it:
      i)   it is for performance, not necessary (not for correctness).
      ii)  if it was necessary, it should use "!=" instead of '>'.
      iii) it is the simplest way to fix this bug (maybe not best way).
   B) consider this situation in it:
      i)   it is the best way.
      ii)  it is a little complex (need think of)
      iii) sorry for I do not know how to fix it (at least now).
   C) not touch it:
      i)   correct another place (such as nfs_update_inode)
      ii)  it is a bad idea (at least, I think it is)
      iii) we need keep the source code as clearer as possible.

3) Test Result:
   A) it is one client and one server separately, under 3.6-rc5 x86_32.
   B) use one process (fsx-linux) test (only one user mode thread).
   C) only use read, truncate, llseek, fstat operation for one file.

   Before delete nfs_size_need_update, it causes issue.
   After delete nfs_size_need_update, it is ok.


User Mode Log:
-------------------------------------------------------------------------
<<<test_start>>>
tag=nfsx-linux stime=1350202875
cmdline="export VERSION SOCKET_TYPE; TCbin=$LTPROOT/testcases/bin fsx.sh"
contacts=""
analysis=exit
<<<test_output>>>

Test Options:
 VERSION: 2
 RHOST: dhcp122.asianux.net
 ITERATIONS: 50000
 SOCKET_TYPE: udp
 NFS_TYPE: nfs
Setting up remote machine: dhcp122.asianux.net
Mounting NFS filesystem dhcp122.asianux.net:/tmp/fsx1447.testdir on
/opt/ltp/testcases/bin/fsx1447 with options '-o proto=udp,vers=2 '
fsx-linux -N 50000 /opt/ltp/testcases/bin/fsx1447/testfile Starting
truncating to largest ever: 0x13e76
truncating to largest ever: 0x2e52c
truncating to largest ever: 0x3c2c2
truncating to largest ever: 0x3f15f
truncating to largest ever: 0x3fcb9
truncating to largest ever: 0x3fe96
truncating to largest ever: 0x3ff9d
Size error: expected 0x36ef9 stat 0x3bbca seek 0x36ef9
LOG DUMP (5652 total operations):

...

5636: 1350203089.781599 READ     0x143b6 thru 0x21ccb (0xd916 bytes)
5637: 1350203090.028214 READ     0x2a629 thru 0x2d0a1 (0x2a79 bytes)
5638: 1350203090.072029 TRUNCATE DOWN   from 0x2d0a2 to 0x1bb35
5639: 1350203090.087401 READ     0x11a05 thru 0x1bb34 (0xa130 bytes)
5640: 1350203090.223985 READ     0x508c thru 0xa9da (0x594f bytes)
5641: 1350203090.245717 TRUNCATE DOWN   from 0x1bb35 to 0x8830
5642: 1350203090.353502 READ     0x548f thru 0x882f (0x33a1 bytes)
5643: 1350203090.366596 READ     0x5802 thru 0x882f (0x302e bytes)
5644: 1350203090.366629 TRUNCATE UP     from 0x8830 to 0x20011
5645: 1350203090.379476 TRUNCATE DOWN   from 0x20011 to 0x134f4
5646: 1350203090.396234 READ     0x124a0 thru 0x134f3 (0x1054 bytes)
5647: 1350203090.401805 READ     0x880b thru 0x1189d (0x9093 bytes)
5648: 1350203090.532050 READ     0x134c7 thru 0x134f3 (0x2d bytes)
5649: 1350203090.532057 TRUNCATE UP     from 0x134f4 to 0x3bbca
5650: 1350203090.546373 READ     0x2944c thru 0x2c1d6 (0x2d8b bytes)
5651: 1350203090.561228 READ     0xdbe1 thru 0x16260 (0x8680 bytes)
5652: 1350203090.751937 TRUNCATE DOWN   from 0x3bbca to 0x36ef9
Correct content saved for comparison
(maybe hexdump "/opt/ltp/testcases/bin/fsx1447/testfile" vs
"/opt/ltp/testcases/bin/fsx1447/testfile.fsxgood")
fsx-linux -N 50000 /opt/ltp/testcases/bin/fsx1447/testfile Finished
Cleaning up testcase
Unmounting /opt/ltp/testcases/bin/fsx1447
Test Failed: Errors have resulted from this test
incrementing stop
<<<execution_status>>>
initiation_status="ok"
duration=218 termination_type=exited termination_id=1 corefile=no
cutime=43 cstime=82
<<<test_end>>>


-------------------------------------------------------------------------


Kernel Mode Log: (using printk which I add)
-------------------------------------------------------------------------
Time:          My Mark:   Task ptr:  comments (include function name):
[  280.883701] gchen_tag: f5c30000, nfs_read_done call
nfs_refresh_inode, cur=0x3bbca, new=0x3bbca
[  280.890677] gchen_tag: f5c30000, nfs_read_done call
nfs_refresh_inode, cur=0x3bbca, new=0x3bbca
[  280.897437] gchen_tag: f5c30000, nfs_read_done call
nfs_refresh_inode, cur=0x3bbca, new=0x3bbca
[  280.897441] gchen_tag: f5e48c90, nfs_setattr_update_inode, cur=3bbca,
new=36ef9
[  280.897450] gchen_tag: f5e48c90, nfs_setattr
[  280.897462] gchen_tag: hit, f5c30000, nfs_refresh_inode_locked,
cur=36ef9, new=3bbca
[  280.897469] gchen_tag: f5c30000, nfs_update_inode, change size,
cur=36ef9, new=3bbca
[  280.898129] gchen_tag: f5e48c90, nfs_update_inode, change size,
cur=3bbca, new=36ef9
[  280.977915] gchen_tag: f5c30000, nfs_update_inode, not change size,
cur=36ef9, new=2000, pages=55
[  281.019879] gchen_tag: f5c30000, nfs_update_inode, not change size,
cur=36ef9, new=a000, pages=53
[  281.070325] gchen_tag: f5c30000, nfs_update_inode, not change size,
cur=36ef9, new=e000, pages=45
[  281.087103] gchen_tag: f5c30000, nfs_update_inode, not change size,
cur=36ef9, new=12000, pages=43
[  281.129061] gchen_tag: f5c30000, nfs_update_inode, not change size,
cur=36ef9, new=16000, pages=41
[  281.163012] gchen_tag: f5c30000, nfs_update_inode, not change size,
cur=36ef9, new=18000, pages=37
[  281.213481] gchen_tag: f5c30000, nfs_update_inode, not change size,
cur=36ef9, new=1c000, pages=33
[  281.255727] gchen_tag: f5c30000, nfs_update_inode, not change size,
cur=36ef9, new=22000, pages=31
[  281.306177] gchen_tag: f5c30000, nfs_update_inode, not change size,
cur=36ef9, new=24000, pages=27
[  281.356888] gchen_tag: f5c30000, nfs_update_inode, not change size,
cur=36ef9, new=2e000, pages=21
[  281.398859] gchen_tag: f5c30000, nfs_update_inode, not change size,
cur=36ef9, new=36000, pages=19
[  281.585491] gchen_tag: f5c30000, nfs_update_inode, not change size,
cur=104d8, new=2000, pages=17
[  281.644207] gchen_tag: f5c30000, nfs_update_inode, not change size,
cur=104d8, new=10000, pages=15
-------------------------------------------------------------------------


Thanks.

--
Chen Gang

Asianux Corporation

