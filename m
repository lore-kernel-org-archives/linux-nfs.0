From: Jan Rekorajski <baggins@sith.mimuw.edu.pl>
Subject: Oops in lockd (2.6.20.1)
Date: Mon, 5 Mar 2007 14:47:06 +0100
Message-ID: <20070305134706.GA6072@sith.mimuw.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HODWw-00032X-0S
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 05:47:10 -0800
Received: from sith.mimuw.edu.pl ([193.0.96.4] ident=postfix)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HODWw-0004kg-L5
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 05:47:12 -0800
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
I have NFS server, serving /, /home and /usr to some 100 workstations,
and the following oops bit me today in the morning.

yellow11 is a workstation (probably someone rebooted it with a power
switch).
Server is 4xDualCore Opteron with 32GB RAM and 500GB of exported
filesystems .

This kernel is heavily patched, but nothing AFAIK touches NFS or
anything near it.

lockd: server yellow11 not responding, timed out
lockd: couldn't create RPC handle for yellow11
lockd: server yellow11 not responding, timed out
lockd: couldn't create RPC handle for yellow11
general protection fault: 0000 [1] SMP 
CPU 0 
Modules linked in: vroot nfsd exportfs lockd nfs_acl sunrpc tg3 ext2 mbcache dm_mod 8021q
Pid: 4114:#0, comm: lockd Not tainted 2.6.20.1 #3
RIP: 0010:[<ffffffff8807e058>]  [<ffffffff8807e058>] :lockd:nlm_release_host+0x28/0x110
RSP: 0018:ffff8107c5075e40  EFLAGS: 00010246
RAX: 0000000000000000 RBX: 0008000000000000 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000086 RDI: 0008000000000000
RBP: ffff81077ce4d080 R08: 0000000000000000 R09: 0000000000000000
R10: 2222222222222222 R11: 2222222222222222 R12: 00000000ffffffdb
R13: 000000000000000a R14: ffff8107c5075ea0 R15: ffffffff880849c0
FS:  00002b5d76afeb00(0000) GS:ffffffff805e0000(0000) knlGS:00000000f7b5a6c0
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000000f7ee0ba9 CR3: 00000005d50db000 CR4: 00000000000006e0
Process lockd (pid: 4114[#0], threadinfo ffff8107c5074000, task ffff8107d8e1c100)
Stack:  ffff8107b75ab000 ffffffff8807cc1d ffff8107b75ab000 ffffffff8807cfca
0000000000000000 ffff8107b75ab038 ffff8107da3132c0 ffff8107b75ab000
ffff8106c24bd4c0 ffffffff8807e7a0 0000000000000000 ffffffff8807d032
Call Trace:
[<ffffffff8807cc1d>] :lockd:nlm_release_call+0xd/0x20
[<ffffffff8807cfca>] :lockd:__nlm_async_call+0x9a/0xc0
[<ffffffff8807e7a0>] :lockd:lockd+0x0/0x280
[<ffffffff8807d032>] :lockd:nlm_async_call+0x42/0x50
[<ffffffff8807fbae>] :lockd:nlmsvc_grant_blocked+0x12e/0x170
[<ffffffff8807fdd3>] :lockd:nlmsvc_retry_blocked+0x73/0xa0
[<ffffffff8807e8d7>] :lockd:lockd+0x137/0x280
[<ffffffff80253df8>] child_rip+0xa/0x12
[<ffffffff8807e7a0>] :lockd:lockd+0x0/0x280
[<ffffffff8807e7a0>] :lockd:lockd+0x0/0x280
[<ffffffff80253dee>] child_rip+0x0/0x12


Code: 8b 73 74 85 f6 79 25 48 c7 c1 60 47 08 88 ba 24 01 00 00 48 
RIP  [<ffffffff8807e058>] :lockd:nlm_release_host+0x28/0x110
RSP <ffff8107c5075e40>

-- 
Jan Rekorajski            |  ALL SUSPECTS ARE GUILTY. PERIOD!
baggins<at>mimuw.edu.pl   |  OTHERWISE THEY WOULDN'T BE SUSPECTS, WOULD THEY?
BOFH, MANIAC              |                   -- TROOPS by Kevin Rubio

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
