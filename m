Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:56310 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423Ab0GMJdH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jul 2010 05:33:07 -0400
Received: from [192.168.30.62] (goofy.thiele.lan [192.168.30.62])
	by mail.thiele.lan (Postfix) with ESMTP id 0E65738428
	for <linux-nfs@vger.kernel.org>; Tue, 13 Jul 2010 11:33:01 +0200 (CEST)
Message-ID: <4C3C32CC.5060907@thiele-hydraulik.de>
Date: Tue, 13 Jul 2010 11:33:00 +0200
From: Erik Thiele <erik.thiele@thiele-hydraulik.de>
To: linux-nfs@vger.kernel.org
Subject: strange lstat lockup on nfs3
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

hello,

summary:

on my system an lstat call on the nfs mountpoint blocks forever. for me 
this is reproducible. sometimes i have to wait a minute and then every 
start of the program fails again. once blocked, an ls on the mounted 
directory also blocks. a C-c of the lstat process frees the lock and the 
ls continues to run.

details:

on the server i use the -g RPCMOUNTDOPTS variable, because my users may 
have more then 16 groups. it once took me a year of pain to find out 
that this option is damn needed.

while locked, i do:

echo 0 >/proc/sys/sunrpc/rpc_debug

and i get:

Jul 13 10:40:09 goofy kernel: [425776.952565] -pid- proc flgs status 
-client- -prog- --rqstp- -timeout -rpcwait -action- ---ops--
Jul 13 10:40:09 goofy kernel: [425776.952565] 20804 0001 0080      0 
c6b02800 100003 d4495000    15000 xprt_pending f8ff9a08 f9008e94

when C-c the lstat process, the list will be empty again.

when the lstat process is blocked i do:

echo t > /proc/sysrq-trigger

and i get:

Jul 13 10:42:20 goofy kernel: [425932.998710]  =======================
Jul 13 10:42:20 goofy kernel: [425932.998710] PACKcxxmisc_F D 
0000006c     0  9659   8555 (now the process is called crashnfs, but it 
was called PACK.. before)
Jul 13 10:42:20 goofy kernel: [425932.998710]        c541c8c0 00000082 
0000006c 0000006c 00000000 c541ca4c c2011fc0 00000000
Jul 13 10:42:20 goofy kernel: [425932.998710]        d4495b64 0506902f 
00000000 00000286 00000000 00000000 00000000 000000ff
Jul 13 10:42:20 goofy kernel: [425932.998710]        e38ddd7c 00000000 
e38ddd84 c2001d90 f8ffd7bd c02b8f96 f8ffd798 c68f3488
Jul 13 10:42:20 goofy kernel: [425932.998710] Call Trace:
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<f8ffd7bd>] 
rpc_wait_bit_killable+0x25/0x2a [sunrpc]
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<c02b8f96>] 
__wait_on_bit+0x33/0x58
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<f8ffd798>] 
rpc_wait_bit_killable+0x0/0x2a [sunrpc]
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<f8ffd798>] 
rpc_wait_bit_killable+0x0/0x2a [sunrpc]
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<c02b901a>] 
out_of_line_wait_on_bit+0x5f/0x67
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<c0131a4d>] 
wake_bit_function+0x0/0x3c
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<f8ffdc02>] 
__rpc_execute+0xbe/0x1d9 [sunrpc]
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<f8ff8a72>] 
rpc_run_task+0x40/0x45 [sunrpc]
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<f8ff8b00>] 
rpc_call_sync+0x38/0x52 [sunrpc]
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<f8f8d34d>] 
nfs3_rpc_wrapper+0x14/0x49 [nfs]
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<f8f8d6b9>] 
nfs3_proc_getattr+0x52/0x73 [nfs]
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<f8f83349>] 
__nfs_revalidate_inode+0xed/0x211 [nfs]
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<c017a8fc>] 
do_lookup+0x53/0x153
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<c0186de8>] 
mntput_no_expire+0x13/0xd9
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<c017c84b>] 
__link_path_walk+0xa11/0xb26
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<c0158acf>] 
filemap_fault+0x1f5/0x35a
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<c0186de8>] 
mntput_no_expire+0x13/0xd9
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<c017c9c7>] 
path_walk+0x67/0x70
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<f8f83aaa>] 
nfs_getattr+0x8f/0xbe [nfs]
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<f8f83a1b>] 
nfs_getattr+0x0/0xbe [nfs]
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<c017748e>] 
vfs_getattr+0x36/0x4d
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<c0177566>] 
vfs_lstat_fd+0x27/0x39
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<c02222ee>] 
tty_ldisc_deref+0x4c/0x5b
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<c01775e5>] 
sys_lstat64+0xf/0x23
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<c0115bab>] 
do_page_fault+0x2a3/0x5c0
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<c017524a>] 
sys_write+0x3c/0x63
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<c0115908>] 
do_page_fault+0x0/0x5c0
Jul 13 10:42:20 goofy kernel: [425932.998710]  [<c0103857>] 
sysenter_past_esp+0x78/0xb1
Jul 13 10:42:20 goofy kernel: [425932.998710]  =======================

here is the sourcecode of the client crash program:

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <grp.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
  setresuid(-1, 0, -1);
  setresgid(-1, 0, -1);
  gid_t mygid=65534;
  setgroups(1, &mygid);
  setgid(65534);
  setuid(0);
  setgid(0);
  getuid();
  getuid();
  setuid(0);
  setgid(65534);
  setresuid(-1, 110, -1);
  struct stat64 mybuf;
  memset(&mybuf, 0, sizeof(mybuf));
  printf("prepare to block\n");
  lstat64("/thiele/DNC_POOL", &mybuf);
  printf("survived this time\n");
  return 0;
}

EOF

compile with:
gcc -Wall -Werror -D_GNU_SOURCE crashnfs.c -o crashnfs

when executed normally, you can C-c it and the process gets gone.

when executed under strace, you can C-c but the process stays alive. 
although strace terminates. you have to kill -9 then. -INT and -TERM 
won't work.

the program does work several times, then it fails several times again. 
don't know the thing that triggers the problem. but strange is that 
either it works some minute or it fails some minute. it's not that you 
call it and on each call you have maybe 30% chance, but instead you have 
some kind of time window in which the problem always fails or always works.

the strange sequence of setresgid etc. is stolen from the proftpd ftp 
server which initially triggered the problem. if i leave out the setgid 
etc. stuff, everything works. but i don't know in which way this might 
be only some kind of timing issue also ...

some other interesting fact i found out:

when starting the crashnfs program and it blocks, i can "ls 
/thiele/DNC_POOL" and get locked also. but if i instead do "ls 
/thiele/DNC_POOL/MC60" which is a subdirecory, then the ls works and not 
blocks. and after that ls i can also do ls "/thiele/DNC_POOL" without 
blocking. but the crashnfs program will never unlock.

when starting crashnfs and it blocks, i can do "ls /thiele/DNC_POOL" and 
get blocked also. then on another console i do "ls 
/thiele/DNC_POOL/MC60" (subdirectory), and it will not block. then 
afterwards i can do "ls /thiele/DNC_POOL" without blocking! but the 
initial "ls /thiele/DNC_POOL" keeps blocking until C-c of crashnfs.

when starting crashnfs and it blocks, i can run as many "ls 
/thiele/DNC_POOL" processes as i want and every one of them blocks. then 
once i do "ls /thiele/DNC_POOL/MC60" (subdirectory), it works, and then 
all new "ls /thiele/DNC_POOL" work also. but the initial created "ls 
/thiele/DNC_POOL" processes all won't ever unlock until kill of crashnfs 
process.

i ran some wireshark analysis and found out that when the crashnfs 
program starts and blocks, it sends a GETATTR, the server does a TCP ACK 
but won't reply to the GETATTR request. see:
364    31.472536    192.168.30.62    192.168.30.2    NFS    V3 GETATTR 
Call, FH:0xa2be3531
365    31.512536    192.168.30.2    192.168.30.62    TCP    nfs > 929 
[ACK] Seq=15961 Ack=76425 Win=1002 Len=0 TSV=154782046 TSER=84877917
wireshark sais in "seq / ack analysis" that 365 is a ack to 364.
there comes no real reply to the request. so that's why it blocks.

i have to say, that the client has much more nfs stuff mounted from that 
server at the same time and all works without problems. i.e. home 
directory with heavy KDE polling traffic all the time.


******************** server:
hostname: fileserv
os: debian lenny on xen (also debian lenny)
kernel: Linux fileserv 2.6.26-2-xen-686 #1 SMP Mon Jun 21 10:37:05 UTC 
2010 i686 GNU/Linux
/etc/exports has 102 entries. the relevant entry here is:
/thiele/DNC_POOL goofy.thiele.lan(rw,sync,no_subtree_check,no_root_squash)
RPCMOUNTDOPTS="-N 1 -N 2 -g"

******************** client:
hostname: goofy
os: debian lenny
kernel: Linux goofy 2.6.26-2-686 #1 SMP Mon Jun 21 05:58:44 UTC 2010 
i686 GNU/Linux
/etc/fstab:  nfs.thiele.lan:/thiele/DNC_POOL /thiele/DNC_POOL nfs 
nolock,nosuid,nodev 0 0

cat /proc/mounts:
nfs.thiele.lan:/thiele/DNC_POOL /thiele/DNC_POOL nfs 
rw,nosuid,nodev,noatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,nointr,nolock,proto=tcp,timeo=600,retrans=2,sec=sys,mountproto=udp,addr=192.168.30.2 
0 0




OK that's it. i gained no more information and am calling for your help 
here.


thanks
Erik
