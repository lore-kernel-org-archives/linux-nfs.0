Return-Path: linux-nfs-owner@vger.kernel.org
Received: from xes-mad.com ([216.165.139.218]:60163 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752275AbaCFUqO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Mar 2014 15:46:14 -0500
Date: Thu, 6 Mar 2014 14:45:58 -0600 (CST)
From: Andrew Martin <amartin@xes-inc.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jim Rees <rees@umich.edu>, bhawley@luminex.com, Brown Neil <neilb@suse.de>,
        linux-nfs-owner@vger.kernel.org, linux-nfs@vger.kernel.org
Message-ID: <521763040.159828.1394138758307.JavaMail.zimbra@xes-inc.com>
In-Reply-To: <76B038DA-3E86-4C46-BFB6-928BFB8202D8@primarydata.com>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com> <20140306162208.GA18207@umich.edu> <1094203678.52139.1394124222574.JavaMail.zimbra@xes-inc.com> <20140306173632.GA18545@umich.edu> <1397912955.101159.1394130906695.JavaMail.zimbra@xes-inc.com> <B454F556-9381-4DB7-B864-EC066DBEAC63@primarydata.com> <2043391310.134091.1394135196565.JavaMail.zimbra@xes-inc.com> <76B038DA-3E86-4C46-BFB6-928BFB8202D8@primarydata.com>
Subject: Re: Optimal NFS mount options to safely allow interrupts and
 timeouts on newer kernels
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message -----
> From: "Trond Myklebust" <trond.myklebust@primarydata.com>
> > I attempted to get a backtrace from one of the uninterruptable apache
> > processes:
> > echo w > /proc/sysrq-trigger
> > 
> > Here's one example:
> > [1227348.003904] apache2       D 0000000000000000     0 10175   1773
> > 0x00000004
> > [1227348.003906]  ffff8802813178c8 0000000000000082 0000000000015e00
> > 0000000000015e00
> > [1227348.003908]  ffff8801d88f03d0 ffff880281317fd8 0000000000015e00
> > ffff8801d88f0000
> > [1227348.003910]  0000000000015e00 ffff880281317fd8 0000000000015e00
> > ffff8801d88f03d0
> > [1227348.003912] Call Trace:
> > [1227348.003918]  [<ffffffffa00a5ca0>] ? rpc_wait_bit_killable+0x0/0x40
> > [sunrpc]
> > [1227348.003923]  [<ffffffffa00a5cc4>] rpc_wait_bit_killable+0x24/0x40
> > [sunrpc]
> > [1227348.003925]  [<ffffffff8156a41f>] __wait_on_bit+0x5f/0x90
> > [1227348.003930]  [<ffffffffa00a5ca0>] ? rpc_wait_bit_killable+0x0/0x40
> > [sunrpc]
> > [1227348.003932]  [<ffffffff8156a4c8>] out_of_line_wait_on_bit+0x78/0x90
> > [1227348.003934]  [<ffffffff81086790>] ? wake_bit_function+0x0/0x40
> > [1227348.003939]  [<ffffffffa00a6611>] __rpc_execute+0x191/0x2a0 [sunrpc]
> > [1227348.003945]  [<ffffffffa00a6746>] rpc_execute+0x26/0x30 [sunrpc]
> 
> That basically means that the process is hanging in the RPC layer, somewhere
> in the state machine. ‘echo 0 >/proc/sys/sunrpc/rpc_debug’ as the ‘root’
> user should give us a dump of which state these RPC calls are in. Can you
> please try that?
Yes I will definitely run that the next time it happens, but since it occurs
sporadically (and I have not yet found a way to reproduce it on demand), it 
could be days before it occurs again. I'll also run "netstat -tn" to check the
TCP connections the next time this happens.
