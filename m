From: "Guzovsky, Eduard" <Edg@CROSSBEAMSYS.COM>
Subject: FW: linux 2.4.18-5 nfs/rpc problem
Date: Thu, 9 Oct 2003 17:46:24 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6FF58CD33A029D458692432F07B85AB713FDF0@newmail>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C38EAE.C9280926"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A7icf-0006kM-00
	for <nfs@lists.sourceforge.net>; Thu, 09 Oct 2003 14:47:01 -0700
Received: from [66.37.203.189] (helo=cbsvr1.crossbeamsys.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A7icd-00023J-1V
	for nfs@lists.sourceforge.net; Thu, 09 Oct 2003 14:46:59 -0700
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01C38EAE.C9280926
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

We ran into a deadlock problem running Red Hat linux 2.4.18-5
on a diskless machine. Root file system is mounted over=20
udp nfs v3. The problem is created by an application reading,
writing, renaming, deleting files. This machine has 256MB
of memory.

Bellow is some relevant info from the deadlocked machine.

It looks like "rpciod" (see the stack of thread ID 8 in the=20
gdb listing) hangs in __wait_on_page(page=3D0xc1241d7c) trying=20
to do nfs_commit_done() on a stale file handle. At the same=20
time "kupdated" (see the stack of thread ID 6) is stuck in=20
nfs_wait_on_request() while trying to do nfs_writepage()
on the same page rpciod hangs. The problem goes away if the=20
file system is mounted with "sync" option.=20

Is this a known problem ? Is a fix available ?

Thanks,

-Ed



rpc_show_tasks() output:
------------------------

-pid- proc flgs runs status -client- -prog- --rqstp- -timeout -rpcwait
-action- --exit--
33180 0004 0000 0002 000120 cff38aa0 100003 cff32160 00000000  <NULL>
c02090a0        0
32943 0021 0001 0002 -00116 cff38aa0 100003 cff32b58 00000000  <NULL>
0 c0176d10
32942 0021 0001 0002 000128 cff38aa0 100003 cff32078 00000000   schedq
c02090a0 c0176d10
32941 0021 0001 0002 000128 cff38aa0 100003 cff32418 00000000   schedq
c02090a0 c0176d10
00156 0000 0081 0002 -00110 cff38b20 100003        0 00000000   schedq
c016f890 c016f990
00006 0000 0081 0002 -00110 cff38aa0 100003        0 00000000   schedq
c016f890 c016f990

kernel gdb session:
-------------------

(gdb) info threads
  26 Thread 1064  schedule_timeout (timeout=3D0x7fffffff) at =
timer.c:851
  25 Thread 1055  sys_wait4 (pid=3D0xffffffff, stat_addr=3D0x0, =
options=3D0x0,=20
    ru=3D0x0) at exit.c:649
  24 Thread 855  schedule_timeout (timeout=3D0xcc1d5f00) at timer.c:879
  23 Thread 825  schedule_timeout (timeout=3D0x7fffffff) at timer.c:851
  22 Thread 782  schedule_timeout (timeout=3D0xcc2cbf00) at timer.c:879
  21 Thread 781  schedule_timeout (timeout=3D0x7fffffff) at timer.c:851
  20 Thread 763  sys_msgrcv (msqid=3D0x0, msgp=3D0xbffffc40, =
msgsz=3D0x100,=20
    msgtyp=3D0x1, msgflg=3D0x0) at msg.c:816
  19 Thread 745  schedule_timeout (timeout=3D0xcc3b3f74) at timer.c:879
  18 Thread 711  schedule_timeout (timeout=3D0xcc3d1f74) at timer.c:879
  17 Thread 691  schedule_timeout (timeout=3D0xcc3dff00) at timer.c:879
  16 Thread 673  schedule_timeout (timeout=3D0x7fffffff) at timer.c:851
  15 Thread 655  schedule_timeout (timeout=3D0x7fffffff) at timer.c:851
  14 Thread 616  schedule_timeout (timeout=3D0x7fffffff) at timer.c:851
  13 Thread 582  schedule_timeout (timeout=3D0x7fffffff) at timer.c:851
  12 Thread 498  schedule_timeout (timeout=3D0x7fffffff) at timer.c:851
  11 Thread 463  schedule_timeout (timeout=3D0x7fffffff) at timer.c:851
  10 Thread 445  do_syslog (type=3D0x2, buf=3D0x804df20 =
"u\b=1B-b=E8yS",
len=3D0xfff)=1B-A
    at printk.c:191
  9 Thread 440  schedule_timeout (timeout=3D0x7fffffff) at timer.c:851
  8 Thread 8  ___wait_on_page (page=3D0xc1241d7c)
    at /usr/src/linux_2.4.18.5/include/asm/bitops.h:243
  7 Thread 7  interruptible_sleep_on (q=3D0xc1393784) at sched.c:926
  6 Thread 6  nfs_wait_on_request (req=3D0xcff27ae0) at pagelist.c:223
  5 Thread 5  interruptible_sleep_on (q=3D0xc02c6d88) at sched.c:926
  4 Thread 4  schedule_timeout (timeout=3D0xc13a5f80) at timer.c:879
  3 Thread 3  ksoftirqd (__bind_cpu=3D0x0) at softirq.c:386
  2 Thread 2  context_thread (startup=3D0xc02f008c) at context.c:101
  1 Thread 1  schedule_timeout (timeout=3D0xc1357f00) at timer.c:879

[kupdated] info
---------------
(gdb) thread 6
[Switching to thread 6 (Thread 6)]#0  nfs_wait_on_request =
(req=3D0xcff27ae0)
    at pagelist.c:223
(gdb) bt
#0  nfs_wait_on_request (req=3D0xcff27ae0) at pagelist.c:223
#1  0xc0175636 in nfs_wait_on_requests (inode=3D0xcb931080, file=3D0x0, =

    idx_start=3D0x0, npages=3D0x1) at write.c:479
#2  0xc0177268 in nfs_sync_file (inode=3D0xcb931080, file=3D0x0, =
idx_start=3D0x0,=20
    npages=3D0x1, how=3D0x6) at write.c:1307
#3  0xc0175436 in nfs_writepage (page=3D0xc1241d7c)
    at /usr/src/linux_2.4.18.5/include/linux/nfs_fs.h:257
#4  0xc0127d14 in filemap_fdatasync (mapping=3D0xcb931134) at =
filemap.c:594
#5  0xc0149be1 in sync_unlocked_inodes () at inode.c:224
#6  0xc013b778 in sync_old_buffers () at buffer.c:2801
#7  0xc013ba72 in kupdate (startup=3D0xc02f0100) at buffer.c:2996
#8  0xc0107306 in kernel_thread (fn=3D0x202a2, arg=3D0xc1356000, =
flags=3D0x0)
    at process.c:499

(gdb) p *(struct nfs_page *)0xcff27ae0
$3 =3D {wb_hash =3D {next =3D 0xcff27ae0, prev =3D 0xcff27ae0}, wb_lru =
=3D {
    next =3D 0xcff27848, prev =3D 0xcff27788}, wb_list =3D {next =3D =
0xcff27af0,=20
    prev =3D 0xcff27af0}, wb_list_head =3D 0x0, wb_file =3D 0x0,=20
  wb_inode =3D 0xcb931080, wb_cred =3D 0xcff38ba0, wb_page =3D =
0xc1241d7c,=20
  wb_wait =3D {lock =3D {gcc_is_buggy =3D 0x0}, task_list =3D {next =3D =
0xc13a1eb0,=20
      prev =3D 0xc13a1eb0}}, wb_timeout =3D 0xa785, wb_offset =3D 0x0,=20
  wb_bytes =3D 0x400, wb_count =3D 0x3, wb_flags =3D 0x1, wb_verf =3D {
    committed =3D NFS_UNSTABLE, verifier =3D {0xbf766b3f, 0x87af0400}}}

deadlocking page info
---------------------
(gdb) p *(struct page *)(0xc1241d7c)
$6 =3D {list =3D {next =3D 0xcb931144, prev =3D 0xcb931144}, mapping =
=3D 0xcb931134,=20
  index =3D 0x0, next_hash =3D 0x0, count =3D {counter =3D 0x4}, flags =
=3D 0x100004d,=20
  lru =3D {next =3D 0xc125a468, prev =3D 0xc123b9dc}, age =3D 0x5, =
pte_chain =3D 0x0,=20
  pprev_hash =3D 0xcffdee60, buffers =3D 0x0}
(gdb) p *((struct page *)(0xc1241d7c))->mapping
$7 =3D {clean_pages =3D {next =3D 0xcb931134, prev =3D 0xcb931134}, =
dirty_pages =3D {
    next =3D 0xcb93113c, prev =3D 0xcb93113c}, locked_pages =3D {next =
=3D
0xc1241d7c,=20
    prev =3D 0xc1241d7c}, nrpages =3D 0x1, a_ops =3D 0xc02c8820, host =
=3D
0xcb931080,=20
  i_mmap =3D 0x0, i_mmap_shared =3D 0x0, i_shared_lock =3D =
{gcc_is_buggy =3D 0x0},=20
  gfp_mask =3D 0x1d2}
(gdb) p *((struct page *)(0xc1241d7c))->mapping->a_ops
$8 =3D {writepage =3D 0xc0175400 <nfs_writepage>,=20
  readpage =3D 0xc0174a50 <nfs_readpage>,=20
  sync_page =3D 0xc016f400 <nfs_sync_page>,=20
  prepare_write =3D 0xc016f3e0 <nfs_prepare_write>,=20
  commit_write =3D 0xc016f3f0 <nfs_commit_write>, bmap =3D 0, flushpage =
=3D 0,=20
  releasepage =3D 0, direct_IO =3D 0, removepage =3D 0}

[rpciod] info
-------------
(gdb) thread 8
[Switching to thread 8 (Thread 8)]#0  ___wait_on_page =
(page=3D0xc1241d7c)
    at /usr/src/linux_2.4.18.5/include/asm/bitops.h:243
(gdb) bt
#0  ___wait_on_page (page=3D0xc1241d7c)
    at /usr/src/linux_2.4.18.5/include/asm/bitops.h:243
#1  0xc01278d5 in truncate_list_pages (head=3D0xcb931144, start=3D0x0,=20
    partial=3D0xcff2df1c)
    at /usr/src/linux_2.4.18.5/include/linux/pagemap.h:97
#2  0xc012796e in truncate_inode_pages (mapping=3D0xcb931134, =
lstart=3D0x0)
    at filemap.c:349
#3  0xc014acb2 in iput (inode=3D0xcb931080) at inode.c:1086
#4  0xc0176f45 in nfs_commit_done (task=3D0xcfe284c0) at write.c:353
#5  0xc020c71a in __rpc_execute (task=3D0xcfe284c0) at sched.c:648
#6  0xc020c909 in __rpc_schedule () at sched.c:733
#7  0xc020d168 in rpciod (ptr=3D0xc02d954c) at sched.c:1076
#8  0xc0107306 in kernel_thread (fn=3D0xc0316660 <tcp_hashinfo>,
arg=3D0xc139fc00,=20
    flags=3D0x0) at process.c:499
#9  0x00000008 in ?? ()

rpc_task (tk_pid 32943) info (note: tk_status =3D -116 ESTALE)
------------------------------------------------------------
(gdb) p *(struct rpc_task *)0xcfe284c0
$9 =3D {tk_list =3D {next =3D 0xc02d9514, prev =3D 0xc02d9514}, =
tk_magic =3D 0xf00baa,

  tk_task =3D {next =3D 0xcfe28c4c, prev =3D 0xcfe2804c}, tk_client =3D =
0xcff38aa0,=20
  tk_rqstp =3D 0xcff32b58, tk_status =3D 0xffffff8c, tk_rpcwait =3D =
0x0, tk_msg =3D
{
    rpc_proc =3D 0x15, rpc_argp =3D 0xcfe28550, rpc_resp =3D =
0xcfe285a8,=20
    rpc_cred =3D 0xcff38ba0}, tk_buffer =3D 0xcff78000, tk_garb_retry =
=3D 0x2,=20
  tk_cred_retry =3D 0x2, tk_suid_retry =3D 0x1, tk_timeout_fn =3D 0,=20
  tk_callback =3D 0, tk_action =3D 0, tk_exit =3D 0xc0176d10 =
<nfs_commit_done>,=20
  tk_release =3D 0xc0175070 <nfs_writedata_release>, tk_calldata =3D =
0xcfe284c0,

  tk_timer =3D {list =3D {next =3D 0x0, prev =3D 0x0}, expires =3D =
0xa7c8,=20
    data =3D 0xcfe284c0, function =3D 0xc020bab0 <rpc_run_timer>}, =
tk_wait =3D {
    lock =3D {gcc_is_buggy =3D 0x0}, task_list =3D {next =3D =
0xcfe2852c,=20
      prev =3D 0xcfe2852c}}, tk_timeout =3D 0x0, tk_flags =3D 0x1, =
tk_lock =3D 0x0,=20
  tk_active =3D 0x1, tk_wakeup =3D 0x0, tk_runstate =3D 0x2, tk_pid =3D =
0x80af}
(gdb) p/d 0x80af
$10 =3D 32943

(gdb) p *((struct rpc_task *)0xcfe284c0)->tk_rqstp
$11 =3D {rq_xprt =3D 0xcff32000, rq_timeout =3D {to_current =3D 0x46,=20
    to_initval =3D 0x46, to_maxval =3D 0x1770, to_increment =3D 0x0,=20
    to_resrvval =3D 0x2ee0, to_retries =3D 0x3, to_exponential =3D =
0x1},=20
  rq_snd_buf =3D {io_vec =3D {{iov_base =3D 0xcff78000, iov_len =3D =
0x64}, {
        iov_base =3D 0x0, iov_len =3D 0x0}, {iov_base =3D 0x0, iov_len =
=3D 0x0}, {
        iov_base =3D 0x0, iov_len =3D 0x0}, {iov_base =3D 0x0, iov_len =
=3D 0x0}, {
        iov_base =3D 0x0, iov_len =3D 0x0}, {iov_base =3D 0x0, iov_len =
=3D 0x0}, {
        iov_base =3D 0x0, iov_len =3D 0x0}, {iov_base =3D 0x0, iov_len =
=3D 0x0}, {
        iov_base =3D 0x0, iov_len =3D 0x0}}, io_nr =3D 0x1, io_len =3D =
0x64},=20
  rq_rcv_buf =3D {io_vec =3D {{iov_base =3D 0xcff78280, iov_len =3D =
0x280}, {
        iov_base =3D 0x0, iov_len =3D 0x0}, {iov_base =3D 0x0, iov_len =
=3D 0x0}, {
        iov_base =3D 0x0, iov_len =3D 0x0}, {iov_base =3D 0x0, iov_len =
=3D 0x0}, {
        iov_base =3D 0x0, iov_len =3D 0x0}, {iov_base =3D 0x0, iov_len =
=3D 0x0}, {
        iov_base =3D 0x0, iov_len =3D 0x0}, {iov_base =3D 0x0, iov_len =
=3D 0x0}, {
        iov_base =3D 0x0, iov_len =3D 0x0}}, io_nr =3D 0x1, io_len =3D =
0x280},=20
  rq_task =3D 0xcfe284c0, rq_xid =3D 0x424070ad, rq_next =3D 0x0, =
rq_cong =3D 0x0,=20
  rq_received =3D 0x1, rq_creddata =3D {0x0, 0x0}, rq_bytes_sent =3D =
0x0}

------_=_NextPart_001_01C38EAE.C9280926
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
5.5.2653.12">
<TITLE>FW: linux 2.4.18-5 nfs/rpc problem</TITLE>
</HEAD>
<BODY>

<P><FONT SIZE=3D2>We ran into a deadlock problem running Red Hat linux =
2.4.18-5</FONT>
<BR><FONT SIZE=3D2>on a diskless machine. Root file system is mounted =
over </FONT>
<BR><FONT SIZE=3D2>udp nfs v3. The problem is created by an application =
reading,</FONT>
<BR><FONT SIZE=3D2>writing, renaming, deleting files. This machine has =
256MB</FONT>
<BR><FONT SIZE=3D2>of memory.</FONT>
</P>

<P><FONT SIZE=3D2>Bellow is some relevant info from the deadlocked =
machine.</FONT>
</P>

<P><FONT SIZE=3D2>It looks like &quot;rpciod&quot; (see the stack of =
thread ID 8 in the </FONT>
<BR><FONT SIZE=3D2>gdb listing) hangs in =
__wait_on_page(page=3D0xc1241d7c) trying </FONT>
<BR><FONT SIZE=3D2>to do nfs_commit_done() on a stale file handle. At =
the same </FONT>
<BR><FONT SIZE=3D2>time &quot;kupdated&quot; (see the stack of thread =
ID 6) is stuck in </FONT>
<BR><FONT SIZE=3D2>nfs_wait_on_request() while trying to do =
nfs_writepage()</FONT>
<BR><FONT SIZE=3D2>on the same page rpciod hangs. The problem goes away =
if the </FONT>
<BR><FONT SIZE=3D2>file system is mounted with &quot;sync&quot; option. =
</FONT>
</P>

<P><FONT SIZE=3D2>Is this a known problem ? Is a fix available ?</FONT>
</P>

<P><FONT SIZE=3D2>Thanks,</FONT>
</P>

<P><FONT SIZE=3D2>-Ed</FONT>
</P>
<BR>
<BR>

<P><FONT SIZE=3D2>rpc_show_tasks() output:</FONT>
<BR><FONT SIZE=3D2>------------------------</FONT>
</P>

<P><FONT SIZE=3D2>-pid- proc flgs runs status -client- -prog- --rqstp- =
-timeout -rpcwait -action- --exit--</FONT>
<BR><FONT SIZE=3D2>33180 0004 0000 0002 000120 cff38aa0 100003 cff32160 =
00000000&nbsp; &lt;NULL&gt;&nbsp; =
c02090a0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0</FONT>
<BR><FONT SIZE=3D2>32943 0021 0001 0002 -00116 cff38aa0 100003 cff32b58 =
00000000&nbsp; =
&lt;NULL&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 =
c0176d10</FONT>
<BR><FONT SIZE=3D2>32942 0021 0001 0002 000128 cff38aa0 100003 cff32078 =
00000000&nbsp;&nbsp; schedq c02090a0 c0176d10</FONT>
<BR><FONT SIZE=3D2>32941 0021 0001 0002 000128 cff38aa0 100003 cff32418 =
00000000&nbsp;&nbsp; schedq c02090a0 c0176d10</FONT>
<BR><FONT SIZE=3D2>00156 0000 0081 0002 -00110 cff38b20 =
100003&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 00000000&nbsp;&nbsp; =
schedq c016f890 c016f990</FONT>
<BR><FONT SIZE=3D2>00006 0000 0081 0002 -00110 cff38aa0 =
100003&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 00000000&nbsp;&nbsp; =
schedq c016f890 c016f990</FONT>
</P>

<P><FONT SIZE=3D2>kernel gdb session:</FONT>
<BR><FONT SIZE=3D2>-------------------</FONT>
</P>

<P><FONT SIZE=3D2>(gdb) info threads</FONT>
<BR><FONT SIZE=3D2>&nbsp; 26 Thread 1064&nbsp; schedule_timeout =
(timeout=3D0x7fffffff) at timer.c:851</FONT>
<BR><FONT SIZE=3D2>&nbsp; 25 Thread 1055&nbsp; sys_wait4 =
(pid=3D0xffffffff, stat_addr=3D0x0, options=3D0x0, </FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; ru=3D0x0) at exit.c:649</FONT>
<BR><FONT SIZE=3D2>&nbsp; 24 Thread 855&nbsp; schedule_timeout =
(timeout=3D0xcc1d5f00) at timer.c:879</FONT>
<BR><FONT SIZE=3D2>&nbsp; 23 Thread 825&nbsp; schedule_timeout =
(timeout=3D0x7fffffff) at timer.c:851</FONT>
<BR><FONT SIZE=3D2>&nbsp; 22 Thread 782&nbsp; schedule_timeout =
(timeout=3D0xcc2cbf00) at timer.c:879</FONT>
<BR><FONT SIZE=3D2>&nbsp; 21 Thread 781&nbsp; schedule_timeout =
(timeout=3D0x7fffffff) at timer.c:851</FONT>
<BR><FONT SIZE=3D2>&nbsp; 20 Thread 763&nbsp; sys_msgrcv (msqid=3D0x0, =
msgp=3D0xbffffc40, msgsz=3D0x100, </FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; msgtyp=3D0x1, msgflg=3D0x0) at =
msg.c:816</FONT>
<BR><FONT SIZE=3D2>&nbsp; 19 Thread 745&nbsp; schedule_timeout =
(timeout=3D0xcc3b3f74) at timer.c:879</FONT>
<BR><FONT SIZE=3D2>&nbsp; 18 Thread 711&nbsp; schedule_timeout =
(timeout=3D0xcc3d1f74) at timer.c:879</FONT>
<BR><FONT SIZE=3D2>&nbsp; 17 Thread 691&nbsp; schedule_timeout =
(timeout=3D0xcc3dff00) at timer.c:879</FONT>
<BR><FONT SIZE=3D2>&nbsp; 16 Thread 673&nbsp; schedule_timeout =
(timeout=3D0x7fffffff) at timer.c:851</FONT>
<BR><FONT SIZE=3D2>&nbsp; 15 Thread 655&nbsp; schedule_timeout =
(timeout=3D0x7fffffff) at timer.c:851</FONT>
<BR><FONT SIZE=3D2>&nbsp; 14 Thread 616&nbsp; schedule_timeout =
(timeout=3D0x7fffffff) at timer.c:851</FONT>
<BR><FONT SIZE=3D2>&nbsp; 13 Thread 582&nbsp; schedule_timeout =
(timeout=3D0x7fffffff) at timer.c:851</FONT>
<BR><FONT SIZE=3D2>&nbsp; 12 Thread 498&nbsp; schedule_timeout =
(timeout=3D0x7fffffff) at timer.c:851</FONT>
<BR><FONT SIZE=3D2>&nbsp; 11 Thread 463&nbsp; schedule_timeout =
(timeout=3D0x7fffffff) at timer.c:851</FONT>
<BR><FONT SIZE=3D2>&nbsp; 10 Thread 445&nbsp; do_syslog (type=3D0x2, =
buf=3D0x804df20 &quot;u\b=1B-b=E8yS&quot;, len=3D0xfff)=1B-A</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; at printk.c:191</FONT>
<BR><FONT SIZE=3D2>&nbsp; 9 Thread 440&nbsp; schedule_timeout =
(timeout=3D0x7fffffff) at timer.c:851</FONT>
<BR><FONT SIZE=3D2>&nbsp; 8 Thread 8&nbsp; ___wait_on_page =
(page=3D0xc1241d7c)</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; at =
/usr/src/linux_2.4.18.5/include/asm/bitops.h:243</FONT>
<BR><FONT SIZE=3D2>&nbsp; 7 Thread 7&nbsp; interruptible_sleep_on =
(q=3D0xc1393784) at sched.c:926</FONT>
<BR><FONT SIZE=3D2>&nbsp; 6 Thread 6&nbsp; nfs_wait_on_request =
(req=3D0xcff27ae0) at pagelist.c:223</FONT>
<BR><FONT SIZE=3D2>&nbsp; 5 Thread 5&nbsp; interruptible_sleep_on =
(q=3D0xc02c6d88) at sched.c:926</FONT>
<BR><FONT SIZE=3D2>&nbsp; 4 Thread 4&nbsp; schedule_timeout =
(timeout=3D0xc13a5f80) at timer.c:879</FONT>
<BR><FONT SIZE=3D2>&nbsp; 3 Thread 3&nbsp; ksoftirqd (__bind_cpu=3D0x0) =
at softirq.c:386</FONT>
<BR><FONT SIZE=3D2>&nbsp; 2 Thread 2&nbsp; context_thread =
(startup=3D0xc02f008c) at context.c:101</FONT>
<BR><FONT SIZE=3D2>&nbsp; 1 Thread 1&nbsp; schedule_timeout =
(timeout=3D0xc1357f00) at timer.c:879</FONT>
</P>

<P><FONT SIZE=3D2>[kupdated] info</FONT>
<BR><FONT SIZE=3D2>---------------</FONT>
<BR><FONT SIZE=3D2>(gdb) thread 6</FONT>
<BR><FONT SIZE=3D2>[Switching to thread 6 (Thread 6)]#0&nbsp; =
nfs_wait_on_request (req=3D0xcff27ae0)</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; at pagelist.c:223</FONT>
<BR><FONT SIZE=3D2>(gdb) bt</FONT>
<BR><FONT SIZE=3D2>#0&nbsp; nfs_wait_on_request (req=3D0xcff27ae0) at =
pagelist.c:223</FONT>
<BR><FONT SIZE=3D2>#1&nbsp; 0xc0175636 in nfs_wait_on_requests =
(inode=3D0xcb931080, file=3D0x0, </FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; idx_start=3D0x0, npages=3D0x1) at =
write.c:479</FONT>
<BR><FONT SIZE=3D2>#2&nbsp; 0xc0177268 in nfs_sync_file =
(inode=3D0xcb931080, file=3D0x0, idx_start=3D0x0, </FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; npages=3D0x1, how=3D0x6) at =
write.c:1307</FONT>
<BR><FONT SIZE=3D2>#3&nbsp; 0xc0175436 in nfs_writepage =
(page=3D0xc1241d7c)</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; at =
/usr/src/linux_2.4.18.5/include/linux/nfs_fs.h:257</FONT>
<BR><FONT SIZE=3D2>#4&nbsp; 0xc0127d14 in filemap_fdatasync =
(mapping=3D0xcb931134) at filemap.c:594</FONT>
<BR><FONT SIZE=3D2>#5&nbsp; 0xc0149be1 in sync_unlocked_inodes () at =
inode.c:224</FONT>
<BR><FONT SIZE=3D2>#6&nbsp; 0xc013b778 in sync_old_buffers () at =
buffer.c:2801</FONT>
<BR><FONT SIZE=3D2>#7&nbsp; 0xc013ba72 in kupdate =
(startup=3D0xc02f0100) at buffer.c:2996</FONT>
<BR><FONT SIZE=3D2>#8&nbsp; 0xc0107306 in kernel_thread (fn=3D0x202a2, =
arg=3D0xc1356000, flags=3D0x0)</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; at process.c:499</FONT>
</P>

<P><FONT SIZE=3D2>(gdb) p *(struct nfs_page *)0xcff27ae0</FONT>
<BR><FONT SIZE=3D2>$3 =3D {wb_hash =3D {next =3D 0xcff27ae0, prev =3D =
0xcff27ae0}, wb_lru =3D {</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; next =3D 0xcff27848, prev =3D =
0xcff27788}, wb_list =3D {next =3D 0xcff27af0, </FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; prev =3D 0xcff27af0}, =
wb_list_head =3D 0x0, wb_file =3D 0x0, </FONT>
<BR><FONT SIZE=3D2>&nbsp; wb_inode =3D 0xcb931080, wb_cred =3D =
0xcff38ba0, wb_page =3D 0xc1241d7c, </FONT>
<BR><FONT SIZE=3D2>&nbsp; wb_wait =3D {lock =3D {gcc_is_buggy =3D 0x0}, =
task_list =3D {next =3D 0xc13a1eb0, </FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; prev =3D =
0xc13a1eb0}}, wb_timeout =3D 0xa785, wb_offset =3D 0x0, </FONT>
<BR><FONT SIZE=3D2>&nbsp; wb_bytes =3D 0x400, wb_count =3D 0x3, =
wb_flags =3D 0x1, wb_verf =3D {</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; committed =3D NFS_UNSTABLE, =
verifier =3D {0xbf766b3f, 0x87af0400}}}</FONT>
</P>

<P><FONT SIZE=3D2>deadlocking page info</FONT>
<BR><FONT SIZE=3D2>---------------------</FONT>
<BR><FONT SIZE=3D2>(gdb) p *(struct page *)(0xc1241d7c)</FONT>
<BR><FONT SIZE=3D2>$6 =3D {list =3D {next =3D 0xcb931144, prev =3D =
0xcb931144}, mapping =3D 0xcb931134, </FONT>
<BR><FONT SIZE=3D2>&nbsp; index =3D 0x0, next_hash =3D 0x0, count =3D =
{counter =3D 0x4}, flags =3D 0x100004d, </FONT>
<BR><FONT SIZE=3D2>&nbsp; lru =3D {next =3D 0xc125a468, prev =3D =
0xc123b9dc}, age =3D 0x5, pte_chain =3D 0x0, </FONT>
<BR><FONT SIZE=3D2>&nbsp; pprev_hash =3D 0xcffdee60, buffers =3D =
0x0}</FONT>
<BR><FONT SIZE=3D2>(gdb) p *((struct page =
*)(0xc1241d7c))-&gt;mapping</FONT>
<BR><FONT SIZE=3D2>$7 =3D {clean_pages =3D {next =3D 0xcb931134, prev =
=3D 0xcb931134}, dirty_pages =3D {</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; next =3D 0xcb93113c, prev =3D =
0xcb93113c}, locked_pages =3D {next =3D 0xc1241d7c, </FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; prev =3D 0xc1241d7c}, nrpages =3D =
0x1, a_ops =3D 0xc02c8820, host =3D 0xcb931080, </FONT>
<BR><FONT SIZE=3D2>&nbsp; i_mmap =3D 0x0, i_mmap_shared =3D 0x0, =
i_shared_lock =3D {gcc_is_buggy =3D 0x0}, </FONT>
<BR><FONT SIZE=3D2>&nbsp; gfp_mask =3D 0x1d2}</FONT>
<BR><FONT SIZE=3D2>(gdb) p *((struct page =
*)(0xc1241d7c))-&gt;mapping-&gt;a_ops</FONT>
<BR><FONT SIZE=3D2>$8 =3D {writepage =3D 0xc0175400 =
&lt;nfs_writepage&gt;, </FONT>
<BR><FONT SIZE=3D2>&nbsp; readpage =3D 0xc0174a50 &lt;nfs_readpage&gt;, =
</FONT>
<BR><FONT SIZE=3D2>&nbsp; sync_page =3D 0xc016f400 =
&lt;nfs_sync_page&gt;, </FONT>
<BR><FONT SIZE=3D2>&nbsp; prepare_write =3D 0xc016f3e0 =
&lt;nfs_prepare_write&gt;, </FONT>
<BR><FONT SIZE=3D2>&nbsp; commit_write =3D 0xc016f3f0 =
&lt;nfs_commit_write&gt;, bmap =3D 0, flushpage =3D 0, </FONT>
<BR><FONT SIZE=3D2>&nbsp; releasepage =3D 0, direct_IO =3D 0, =
removepage =3D 0}</FONT>
</P>

<P><FONT SIZE=3D2>[rpciod] info</FONT>
<BR><FONT SIZE=3D2>-------------</FONT>
<BR><FONT SIZE=3D2>(gdb) thread 8</FONT>
<BR><FONT SIZE=3D2>[Switching to thread 8 (Thread 8)]#0&nbsp; =
___wait_on_page (page=3D0xc1241d7c)</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; at =
/usr/src/linux_2.4.18.5/include/asm/bitops.h:243</FONT>
<BR><FONT SIZE=3D2>(gdb) bt</FONT>
<BR><FONT SIZE=3D2>#0&nbsp; ___wait_on_page (page=3D0xc1241d7c)</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; at =
/usr/src/linux_2.4.18.5/include/asm/bitops.h:243</FONT>
<BR><FONT SIZE=3D2>#1&nbsp; 0xc01278d5 in truncate_list_pages =
(head=3D0xcb931144, start=3D0x0, </FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; partial=3D0xcff2df1c)</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; at =
/usr/src/linux_2.4.18.5/include/linux/pagemap.h:97</FONT>
<BR><FONT SIZE=3D2>#2&nbsp; 0xc012796e in truncate_inode_pages =
(mapping=3D0xcb931134, lstart=3D0x0)</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; at filemap.c:349</FONT>
<BR><FONT SIZE=3D2>#3&nbsp; 0xc014acb2 in iput (inode=3D0xcb931080) at =
inode.c:1086</FONT>
<BR><FONT SIZE=3D2>#4&nbsp; 0xc0176f45 in nfs_commit_done =
(task=3D0xcfe284c0) at write.c:353</FONT>
<BR><FONT SIZE=3D2>#5&nbsp; 0xc020c71a in __rpc_execute =
(task=3D0xcfe284c0) at sched.c:648</FONT>
<BR><FONT SIZE=3D2>#6&nbsp; 0xc020c909 in __rpc_schedule () at =
sched.c:733</FONT>
<BR><FONT SIZE=3D2>#7&nbsp; 0xc020d168 in rpciod (ptr=3D0xc02d954c) at =
sched.c:1076</FONT>
<BR><FONT SIZE=3D2>#8&nbsp; 0xc0107306 in kernel_thread =
(fn=3D0xc0316660 &lt;tcp_hashinfo&gt;, arg=3D0xc139fc00, </FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; flags=3D0x0) at =
process.c:499</FONT>
<BR><FONT SIZE=3D2>#9&nbsp; 0x00000008 in ?? ()</FONT>
</P>

<P><FONT SIZE=3D2>rpc_task (tk_pid 32943) info (note: tk_status =3D =
-116 ESTALE)</FONT>
<BR><FONT =
SIZE=3D2>------------------------------------------------------------</F=
ONT>
<BR><FONT SIZE=3D2>(gdb) p *(struct rpc_task *)0xcfe284c0</FONT>
<BR><FONT SIZE=3D2>$9 =3D {tk_list =3D {next =3D 0xc02d9514, prev =3D =
0xc02d9514}, tk_magic =3D 0xf00baa, </FONT>
<BR><FONT SIZE=3D2>&nbsp; tk_task =3D {next =3D 0xcfe28c4c, prev =3D =
0xcfe2804c}, tk_client =3D 0xcff38aa0, </FONT>
<BR><FONT SIZE=3D2>&nbsp; tk_rqstp =3D 0xcff32b58, tk_status =3D =
0xffffff8c, tk_rpcwait =3D 0x0, tk_msg =3D {</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; rpc_proc =3D 0x15, rpc_argp =3D =
0xcfe28550, rpc_resp =3D 0xcfe285a8, </FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; rpc_cred =3D 0xcff38ba0}, =
tk_buffer =3D 0xcff78000, tk_garb_retry =3D 0x2, </FONT>
<BR><FONT SIZE=3D2>&nbsp; tk_cred_retry =3D 0x2, tk_suid_retry =3D 0x1, =
tk_timeout_fn =3D 0, </FONT>
<BR><FONT SIZE=3D2>&nbsp; tk_callback =3D 0, tk_action =3D 0, tk_exit =
=3D 0xc0176d10 &lt;nfs_commit_done&gt;, </FONT>
<BR><FONT SIZE=3D2>&nbsp; tk_release =3D 0xc0175070 =
&lt;nfs_writedata_release&gt;, tk_calldata =3D 0xcfe284c0, </FONT>
<BR><FONT SIZE=3D2>&nbsp; tk_timer =3D {list =3D {next =3D 0x0, prev =
=3D 0x0}, expires =3D 0xa7c8, </FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; data =3D 0xcfe284c0, function =3D =
0xc020bab0 &lt;rpc_run_timer&gt;}, tk_wait =3D {</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; lock =3D {gcc_is_buggy =3D 0x0}, =
task_list =3D {next =3D 0xcfe2852c, </FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; prev =3D =
0xcfe2852c}}, tk_timeout =3D 0x0, tk_flags =3D 0x1, tk_lock =3D 0x0, =
</FONT>
<BR><FONT SIZE=3D2>&nbsp; tk_active =3D 0x1, tk_wakeup =3D 0x0, =
tk_runstate =3D 0x2, tk_pid =3D 0x80af}</FONT>
<BR><FONT SIZE=3D2>(gdb) p/d 0x80af</FONT>
<BR><FONT SIZE=3D2>$10 =3D 32943</FONT>
</P>

<P><FONT SIZE=3D2>(gdb) p *((struct rpc_task =
*)0xcfe284c0)-&gt;tk_rqstp</FONT>
<BR><FONT SIZE=3D2>$11 =3D {rq_xprt =3D 0xcff32000, rq_timeout =3D =
{to_current =3D 0x46, </FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; to_initval =3D 0x46, to_maxval =
=3D 0x1770, to_increment =3D 0x0, </FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp; to_resrvval =3D 0x2ee0, =
to_retries =3D 0x3, to_exponential =3D 0x1}, </FONT>
<BR><FONT SIZE=3D2>&nbsp; rq_snd_buf =3D {io_vec =3D {{iov_base =3D =
0xcff78000, iov_len =3D 0x64}, {</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; iov_base =
=3D 0x0, iov_len =3D 0x0}, {iov_base =3D 0x0, iov_len =3D 0x0}, =
{</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; iov_base =
=3D 0x0, iov_len =3D 0x0}, {iov_base =3D 0x0, iov_len =3D 0x0}, =
{</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; iov_base =
=3D 0x0, iov_len =3D 0x0}, {iov_base =3D 0x0, iov_len =3D 0x0}, =
{</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; iov_base =
=3D 0x0, iov_len =3D 0x0}, {iov_base =3D 0x0, iov_len =3D 0x0}, =
{</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; iov_base =
=3D 0x0, iov_len =3D 0x0}}, io_nr =3D 0x1, io_len =3D 0x64}, </FONT>
<BR><FONT SIZE=3D2>&nbsp; rq_rcv_buf =3D {io_vec =3D {{iov_base =3D =
0xcff78280, iov_len =3D 0x280}, {</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; iov_base =
=3D 0x0, iov_len =3D 0x0}, {iov_base =3D 0x0, iov_len =3D 0x0}, =
{</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; iov_base =
=3D 0x0, iov_len =3D 0x0}, {iov_base =3D 0x0, iov_len =3D 0x0}, =
{</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; iov_base =
=3D 0x0, iov_len =3D 0x0}, {iov_base =3D 0x0, iov_len =3D 0x0}, =
{</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; iov_base =
=3D 0x0, iov_len =3D 0x0}, {iov_base =3D 0x0, iov_len =3D 0x0}, =
{</FONT>
<BR><FONT SIZE=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; iov_base =
=3D 0x0, iov_len =3D 0x0}}, io_nr =3D 0x1, io_len =3D 0x280}, </FONT>
<BR><FONT SIZE=3D2>&nbsp; rq_task =3D 0xcfe284c0, rq_xid =3D =
0x424070ad, rq_next =3D 0x0, rq_cong =3D 0x0, </FONT>
<BR><FONT SIZE=3D2>&nbsp; rq_received =3D 0x1, rq_creddata =3D {0x0, =
0x0}, rq_bytes_sent =3D 0x0}</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C38EAE.C9280926--


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
