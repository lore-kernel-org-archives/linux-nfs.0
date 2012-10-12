Return-Path: linux-nfs-owner@vger.kernel.org
Received: from peace.netnation.com ([204.174.223.2]:51771 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389Ab2JLIPS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Oct 2012 04:15:18 -0400
Date: Fri, 12 Oct 2012 01:15:16 -0700
From: Simon Kirby <sim@hostway.ca>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Yan-Pai Chen <yanpai.chen@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [3.2.5] NFSv3 CLOSE_WAIT hang
Message-ID: <20121012081516.GA20046@hostway.ca>
References: <447c.504a05c9.dd0a9@altium.nl>
 <447c.504a05c9.dd0a9@altium.nl>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908F8E833@SACEXCMBX04-PRD.hq.netapp.com>
 <74c7.504b9d45.a5956@altium.nl>
 <loom.20120910T105944-416@post.gmane.org>
 <20120911194051.GB11160@hostway.ca>
 <1347401844.15208.17.camel@lade.trondhjem.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908F9F734@SACEXCMBX04-PRD.hq.netapp.com>
 <20120919220148.GA8249@hostway.ca>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908FD9796@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908FD9796@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 19, 2012 at 10:11:57PM +0000, Myklebust, Trond wrote:

> On Wed, 2012-09-19 at 15:01 -0700, Simon Kirby wrote:
> 
> > Yes, based on data collected today, this seems to fix the problem!
> > Awesome! :)
> 
> Great! I'm adding "Tested-by:" and "Cc: stable" lines since you've been
> seeing this for some time.

This has been working well, except we just saw one case now where we
still got a CLOSE_WAIT hang. The issue was that the queue_work() was not
called because setting XPRT_LOCKED failed, which you asked about before.

This trace from our debugging patches:

WARNING: at net/sunrpc/xprt.c:648 xprt_force_disconnect+0x12a/0x140() 
Hardware name: PowerEdge 1950 
xprt_force_disconnect(): setting XPRT_LOCKED failed                                                                                                                                                
Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2 serio_raw evdev                             
Pid: 0, comm: swapper/1 Tainted: G        W    3.2.28-hw+ #25 
Call Trace: 
 <IRQ>  [<ffffffff816b74ba>] ? xprt_force_disconnect+0x12a/0x140 
 [<ffffffff8105db70>] warn_slowpath_common+0x80/0xc0 
 [<ffffffff8105dca9>] warn_slowpath_fmt+0x69/0x70 
 [<ffffffff81701c8c>] ? printk+0x67/0x69 
 [<ffffffff81704ef1>] ? _raw_spin_lock_bh+0x11/0x40 
 [<ffffffff816b74ba>] xprt_force_disconnect+0x12a/0x140 
 [<ffffffff816ba99c>] xs_tcp_state_change+0xdc/0x340 
 [<ffffffff81669deb>] tcp_fin+0x17b/0x210 
 [<ffffffff8166aaf2>] tcp_data_queue+0x4c2/0xe70 
 [<ffffffff8166e259>] ? tcp_validate_incoming+0x109/0x340 
 [<ffffffff8166e5d9>] tcp_rcv_established+0x149/0xb50 
 [<ffffffff8167711c>] tcp_v4_do_rcv+0x15c/0x2e0 
 [<ffffffff8164b6e4>] ? nf_iterate+0x84/0xb0 
 [<ffffffff816778ef>] tcp_v4_rcv+0x64f/0x8b0 
 [<ffffffff8164b85d>] ? nf_hook_slow+0x6d/0x130 
 [<ffffffff81656160>] ? ip_rcv+0x2f0/0x2f0 
 [<ffffffff8165620a>] ip_local_deliver_finish+0xaa/0x1d0 
 [<ffffffff816563bd>] ip_local_deliver+0x8d/0xa0 
 [<ffffffff81655bdb>] ip_rcv_finish+0x7b/0x310 
 [<ffffffff816560ed>] ip_rcv+0x27d/0x2f0 
 [<ffffffff816272b7>] __netif_receive_skb+0x437/0x490 
 [<ffffffff81629148>] netif_receive_skb+0x78/0x80 
...
-pid- flgs status -client- --rqstp- -timeout ---ops--
60022 0080    -11 ffff880096e5bc00   (null)        0 ffffffff817beb20 nfsv3 FSINFO a:call_reserveresult q:xprt_sending
SUNRPC: xprt(ffff88021e87d800) state=283, snd_task->tk_pid=0
SUNRPC: xprt(ffff88022509b000) state=18, snd_task=0
SUNRPC: xprt(ffff88022509b000) state=18, snd_task=0
SUNRPC: xprt(ffff88022509b000) state=18, snd_task=0
SUNRPC: xprt(ffff88022509b000) state=18, snd_task=0
SUNRPC: xprt(ffff88022509b000) state=18, snd_task=0
SUNRPC: xprt(ffff880142c1d800) state=16, snd_task=0
SUNRPC: xprt(ffff880032175800) state=16, snd_task=0
SUNRPC: xprt(ffff8800c2da9000) state=16, snd_task=0
SUNRPC: xprt(ffff88022509b000) state=18, snd_task=0
SUNRPC: xprt(ffff880221977000) state=16, snd_task=0
SUNRPC: xprt(ffff88022212f800) state=16, snd_task=0
SUNRPC: xprt(ffff880221504000) state=0, snd_task=0
SUNRPC: xprt(ffff88022509c800) state=18, snd_task=0
SUNRPC: xprt(ffff88022509c800) state=18, snd_task=0
SUNRPC: xprt(ffff880222711000) state=18, snd_task=0
SUNRPC: xprt(ffff880222711000) state=18, snd_task=0
SUNRPC: xprt(ffff880221737800) state=18, snd_task=0
SUNRPC: xprt(ffff880221737800) state=18, snd_task=0
SUNRPC: xprt(ffff88021f275800) state=18, snd_task=0
SUNRPC: xprt(ffff88021f275800) state=18, snd_task=0
SUNRPC: xprt(ffff8802252b3800) state=18, snd_task=0
SUNRPC: xprt(ffff880222704000) state=18, snd_task=0
SUNRPC: xprt(ffff880222704000) state=18, snd_task=0
SUNRPC: xprt(ffff8802252b3800) state=18, snd_task=0
SUNRPC: xprt(ffff8802252b3800) state=18, snd_task=0
SUNRPC: xprt(ffff88022234e800) state=18, snd_task=0
SUNRPC: xprt(ffff88022234e800) state=18, snd_task=0
SUNRPC: xprt(ffff880221734000) state=18, snd_task=0
SUNRPC: xprt(ffff880221734000) state=18, snd_task=0
SUNRPC: xprt(ffff880222702000) state=18, snd_task=0
SUNRPC: xprt(ffff880222702000) state=18, snd_task=0
 1758 0080    -11 ffff880225562400   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 1770 0080    -11 ffff880225562400   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 1799 0080    -11 ffff880225562400   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
SUNRPC: xprt(ffff88021e87d800) state=283, snd_task->tk_pid=0
59728 0001    -11 ffff8802253d9e00   (null)        0 ffffffff8173ff20 nfsv3 COMMIT a:call_reserveresult q:xprt_sending
 1449 0080    -11 ffff8802253d9e00   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 1766 0080    -11 ffff8802253d9e00   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 1811 0080    -11 ffff8802253d9e00   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
SUNRPC: xprt(ffff88021e87d800) state=283, snd_task->tk_pid=0
 1431 0080    -11 ffff8802253d6000   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 1604 0080    -11 ffff8802253d6000   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 1851 0080    -11 ffff8802253d6000   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 1870 0080    -11 ffff8802253d6000   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 5693 0080    -11 ffff8802253d6000   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 5791 0080    -11 ffff8802253d6000   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
SUNRPC: xprt(ffff88021e87d800) state=283, snd_task->tk_pid=0
 1871 0080    -11 ffff880225522800   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
SUNRPC: xprt(ffff88021e87d800) state=283, snd_task->tk_pid=0
 1442 0080    -11 ffff8802253d7600   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 1457 0080    -11 ffff8802253d7600   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 1829 0080    -11 ffff8802253d7600   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 5784 0080    -11 ffff8802253d7600   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
SUNRPC: xprt(ffff88021e87d800) state=283, snd_task->tk_pid=0
 1625 0080    -11 ffff880225522000   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 2152 0080    -11 ffff880225522000   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 2196 0080    -11 ffff880225522000   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
SUNRPC: xprt(ffff88021e87d800) state=283, snd_task->tk_pid=0
 1517 0080    -11 ffff8802253d5a00   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 1733 0080    -11 ffff8802253d5a00   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 1741 0080    -11 ffff8802253d5a00   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 1872 0080    -11 ffff8802253d5a00   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 2211 0080    -11 ffff8802253d5a00   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 4316 0080    -11 ffff8802253d5a00   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 4350 0080    -11 ffff8802253d5a00   (null)        0 ffffffff817beb20 nfsv3 LOOKUP a:call_reserveresult q:xprt_sending
 4353 0080    -11 ffff8802253d5a00   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 5862 0080    -11 ffff8802253d5a00   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 6982 0080    -11 ffff8802253d5a00   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
 9869 0080    -11 ffff8802253d5a00   (null)        0 ffffffff817beb20 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
SUNRPC: xprt(ffff88021e87d800) state=283, snd_task->tk_pid=0
SUNRPC: xprt(ffff88021e87d800) state=283, snd_task->tk_pid=0
SUNRPC: xprt(ffff88022509b000) state=18, snd_task=0
SUNRPC: xprt(ffff880225098800) state=16, snd_task=0
SUNRPC: xprt(ffff88022509b000) state=18, snd_task=0

We've only seen this once, so we're definitely better than before.

Simon-
