From: Mark Hindley <mark@hindley.org.uk>
Subject: [OOPS] 2.6.23-rc5 in tcp/net/nfsd
Date: Tue, 11 Sep 2007 09:32:00 +0100
Message-ID: <20070911083200.GA3409@hindley.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nfs@lists.sourceforge.net, neilb@suse.de
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

This oops appeared over night on a box running 2.6.23-rc5 (recent with the
tcp_input.c fix).

I can't find a similar one reported.

Mark


BUG: unable to handle kernel NULL pointer dereference at virtual address 0000007e 
 printing eip: 
c02625bf 
*pde = 00000000 
Oops: 0002 [#1] 
PREEMPT
Modules linked in: softdog nfs cpufreq_userspace nfsd exportfs lockd sunrpc ppdev lp ac battery ipv6 cpufreq_ondemand cpufreq_powersave longhaul af_packet tcp_diag inev
CPU:    0
EIP:    0060:[<c02625bf>]    Not tainted VLI
EFLAGS: 00010246   (2.6.23-rc5-2-mcyrixiii #1)
EIP is at ip_fragment+0x7f/0x680
eax: c3c09c00   ebx: 00000000   ecx: b524d006   edx: 0000007b
esi: c1f77810   edi: c1f77e00   ebp: 00000000   esp: ccb48b3c
ds: 007b   es: 007b   fs: 0000  gs: 0000  ss: 0068
Process nfsd (pid: 2942, ti=ccb48000 task=cf78c530 task.ti=ccb48000)
Stack: 00000060 00000060 c0262dd0 c3c09c00 c0382600 00000158 000005c8 00000014
       cbbc5424 00000158 00000000 00008b80 00000000 c1134a40 c3c09c00 00000000
       cee8b780 c0382600 c0264115 00000282 ceabbe40 00000158 c026306c 00000000
Call Trace:
 [<c0262dd0>] ip_finish_output2+0x0/0x1c0
 [<c0264115>] ip_output+0xd5/0x290
 [<c026306c>] ip_generic_getfrag+0x4c/0xa0
 [<c025d3e8>] __ip_select_ident+0x58/0xc0
 [<c02619ef>] ip_push_pending_frames+0x2df/0x3a0
 [<c0263020>] ip_generic_getfrag+0x0/0xa0
 [<c027afab>] udp_push_pending_frames+0x2ab/0x2d0
 [<c027bfc9>] udp_sendmsg+0x469/0x590
 [<c025c470>] __ip_route_output_key+0x6f0/0x710
 [<c0261f8f>] ip_append_data+0x4df/0x970
 [<c01203d0>] irq_exit+0x40/0x70
 [<c02811fb>] inet_sendmsg+0x3b/0x50
 [<c023a79b>] sock_sendmsg+0xbb/0xe0
 [<c012bf80>] autoremove_wake_function+0x0/0x40
 [<c02811fb>] inet_sendmsg+0x3b/0x50
 [<c023ba57>] kernel_sendmsg+0x27/0x40
 [<c023c53a>] sock_no_sendpage+0x5a/0x70
 [<c027c766>] udp_sendpage+0xd6/0x130
 [<d030a5a0>] nfsd_acceptable+0x0/0xd0 [nfsd]
 [<c027c690>] udp_sendpage+0x0/0x130
 [<c0281265>] inet_sendpage+0x55/0x90
 [<c0281210>] inet_sendpage+0x0/0x90
 [<c0239acf>] kernel_sendpage+0x3f/0x50
 [<d02e7893>] svc_sendto+0x1b3/0x280 [sunrpc]
 [<d031312a>] encode_post_op_attr+0x4a/0x60 [nfsd]
 [<c01593e5>] __slab_free+0x55/0x280
 [<d02e7971>] svc_udp_sendto+0x11/0x30 [sunrpc]
 [<d02e8737>] svc_send+0xb7/0x100 [sunrpc]
 [<d02ea34b>] svcauth_unix_release+0x3b/0x50 [sunrpc]
 [<d0312ed0>] nfs3svc_release_fhandle+0x0/0x10 [nfsd]
 [<d02e7178>] svc_process+0x418/0x690 [sunrpc]
 [<d02e9f1a>] svc_recv+0x35a/0x3d0 [sunrpc]
 [<d0308775>] nfsd+0x185/0x2a0 [nfsd]
 [<d03085f0>] nfsd+0x0/0x2a0 [nfsd]
 [<c0105027>] kernel_thread_helper+0x7/0x10
 =======================
Code: 01 00 00 03 75 0e 8b 42 18 8b 40 0c 8b 80 c4 00 00 00 eb 0a 8b 4c 24 08 8b 41 18 8b 40 28 0f c8 89 04 24 8b 44 24 08 b9 04 00 00 <00> ba 03 00 00 00 bf a6 ff ff
EIP: [<c02625bf>] ip_fragment+0x7f/0x680 SS:ESP 0068:ccb48b3c
