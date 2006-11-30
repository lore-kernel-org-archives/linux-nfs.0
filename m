From: Chris Caputo <ccaputo@alt.net>
Subject: Re: NFS hang
Date: Thu, 30 Nov 2006 21:19:51 +0000 (GMT)
Message-ID: <Pine.LNX.4.64.0611302108180.16297@nacho.alt.net>
References: <1162840599.31460.8.camel@zod.rchland.ibm.com>
	<Pine.LNX.4.64.0611230737500.10489@nacho.alt.net>
	<Pine.LNX.4.64.0611271907070.10489@nacho.alt.net>
	<1164655027.5727.5.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0611271929220.10489@nacho.alt.net>
	<1164657487.5727.12.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0611272110270.24703@nacho.alt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Frank Filz <ffilz@us.ibm.com>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GptK2-0001Mu-6y
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 13:19:58 -0800
Received: from nacho.alt.net ([207.14.113.18])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1GptK1-0004BB-Bc
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 13:19:59 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <Pine.LNX.4.64.0611272110270.24703@nacho.alt.net>
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

On Mon, 27 Nov 2006, Chris Caputo wrote:
> On Mon, 27 Nov 2006, Trond Myklebust wrote:
> > No. There is no way this can work. You would need something that
> > guarantees that the task stays queued while you are taking the queue
> > lock.
> > 
> > Have you instead tried Christophe Saout's patch (see attachment)?
> 
> Thank you for the suggestion.  With 65 minutes of uptime so far, Saout's 
> November 5th patch is looking good.  For reference, normally I see the 
> race happen in under 15 minutes.
> 
> I'll report back if any problems develop.  This machine is an outgoing 
> newsfeed server and so it pounds on NFS client routines 24x7.

I am not sure if this is related, but at just over 3 days of uptime with 
2.6.19-rc6 and the Saout patch, I had this happen:

---
BUG: unable to handle kernel NULL pointer dereference at virtual address 00000028
 printing eip:
c029cf64
*pde = 00000000
Oops: 0000 [#1]
SMP 
Modules linked in: weasel_pci
CPU:    1
EIP:    0060:[<c029cf64>]    Not tainted VLI
EFLAGS: 00010202   (2.6.19-rc6 #5)
EIP is at call_start+0x5c/0x6f
eax: c030ae00   ebx: d2c80ac4   ecx: 00000001   edx: f6ad7550
esi: 00000000   edi: 00000000   ebp: f6adbdd0   esp: f6adbd18
ds: 007b   es: 007b   ss: 0068
Process feeder (pid: 4557, ti=f6adb000 task=f6ad7550 task.ti=f6adb000)
Stack: 00000000 00000282 c02ade34 00000001 f6ad7550 c0112a05 d2c80ac4 d2c80b2c 
       c02a22de d2c80c54 f78ca6e0 f6adbdd0 c02adc03 d2c80ac4 d2c80c54 f78ca6e0 
       c01a0795 80000000 00000000 d2c80ac0 d2c80c54 00002000 c01a0cf8 00002000 
Call Trace:
 [<c02ade34>] __down+0xa1/0xd7
 [<c0112a05>] default_wake_function+0x0/0xc
 [<c02a22de>] __rpc_execute+0x82/0x1b8
 [<c02adc03>] __down_failed+0x7/0xc
 [<c01a0795>] nfs_execute_read+0x35/0x49
 [<c01a0cf8>] nfs_pagein_one+0x239/0x251
 [<c01a0fb2>] nfs_readpages+0x140/0x1a2
 [<c01377d1>] __alloc_pages+0x55/0x284
 [<c0138ead>] __do_page_cache_readahead+0x126/0x1e5
 [<c025bdc0>] lock_sock+0x88/0x90
 [<c025eebc>] __alloc_skb+0x49/0xef
 [<c02adf66>] _spin_lock_bh+0x8/0x18
 [<c025bcaf>] release_sock+0xf/0x98
 [<c027b43a>] tcp_sendpage+0x55b/0x575
 [<c02ac57a>] __sched_text_start+0x69a/0x73d
 [<c0138fb8>] blockable_page_cache_readahead+0x4c/0x9f
 [<c0139087>] make_ahead_window+0x7c/0x99
 [<c0139216>] page_cache_readahead+0x172/0x195
 [<c0133e83>] do_generic_mapping_read+0x13f/0x42e
 [<c01341c0>] generic_file_sendfile+0x4e/0x60
 [<c0133283>] file_send_actor+0x0/0x53
 [<c014c1b9>] do_sendfile+0x193/0x23e
 [<c0133283>] file_send_actor+0x0/0x53
 [<c014c346>] sys_sendfile+0x4d/0x94
 [<c0102a03>] syscall_call+0x7/0xb
 =======================
Code: 8b 46 14 89 44 24 0c 8b 46 20 c7 04 24 d7 dc 2e c0 89 44 24 08 0f b7 83 b0 00 00 00 89 44 24 04 e8 69 b3 e7 ff 8b 43 1c ff 40 10 <8b> 46 28 ff 40 18 c7 43 3c 77 cf 29 c0 83 c4 18 5b 5e c3 53 89 
EIP: [<c029cf64>] call_start+0x5c/0x6f SS:ESP 0068:f6adbd18
---

# nfsstat -c
Client rpc stats:
calls      retrans    authrefrsh
747221801   4444       0
Client nfs v2:
null       getattr    setattr    root       lookup     readlink
0       0% 19831747  2% 0       0% 0       0% 16718708  2% 0       0%
read       wrcache    write      create     remove     rename
710082513 95% 0       0% 588780  0% 6       0% 3       0% 3       0%
link       symlink    mkdir      rmdir      readdir    fsstat
0       0% 0       0% 0       0% 0       0% 9       0% 29      0%

I am now compiling 2.6.19 with the Saout patch...

Chris

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
