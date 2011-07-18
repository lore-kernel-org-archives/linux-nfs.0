Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ironport01-1.csupomona.edu ([134.71.187.41]:9124 "EHLO
	ironport01-1.csupomona.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750933Ab1GRUKc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jul 2011 16:10:32 -0400
Received: from localhost (localhost [127.0.0.1])
	by sparky.unx.csupomona.edu (Postfix) with ESMTP id 979C0DC7DC
	for <linux-nfs@vger.kernel.org>; Mon, 18 Jul 2011 13:01:04 -0700 (PDT)
Received: from sparky.unx.csupomona.edu ([127.0.0.1])
	by localhost (sparky.unx.csupomona.edu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id tX0od0FFeFHY for <linux-nfs@vger.kernel.org>;
	Mon, 18 Jul 2011 13:01:04 -0700 (PDT)
Received: from woof (woof.iitsystems.csupomona.edu [134.71.248.29])
	(using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: bldewolf)
	by sparky.unx.csupomona.edu (Postfix) with ESMTPSA id 6F8C8DC792
	for <linux-nfs@vger.kernel.org>; Mon, 18 Jul 2011 13:01:04 -0700 (PDT)
Date: Mon, 18 Jul 2011 13:01:03 -0700
From: Brian De Wolf <bldewolf@csupomona.edu>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Warning call traces when NFS under load
Message-ID: <20110718130103.20918542@woof>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

We recently upgraded from 2.6.34 to 2.6.37 and now we get call traces
when NFS is under load.  An example call trace:

Jul 14 11:53:59 crabtree kernel: ------------[ cut here ]------------
Jul 14 11:53:59 crabtree kernel: WARNING: at net/sunrpc/clnt.c:1562 call_decode+0xa7/0x696()
Jul 14 11:53:59 crabtree kernel: Hardware name: Sun Fire X4100 M2
Jul 14 11:53:59 crabtree kernel: Modules linked in: sha1_generic autofs4 ipt_LOG xt_limit xt_tcpudp nf_conntrack_ipv4 nf_defrag_ipv4 xt_state iptable_filter xt_hashlimit xt_conntrack nf_conntrack ip_tables x_t
ables ipmi_watchdog ipmi_devintf ipmi_si ipmi_msghandler e1000
Jul 14 11:53:59 crabtree kernel: Pid: 381, comm: kworker/2:1 Not tainted 2.6.37-gentoo-r4 #2
Jul 14 11:53:59 crabtree kernel: Call Trace:
Jul 14 11:53:59 crabtree kernel: [<ffffffff8103252d>] ? warn_slowpath_common+0x78/0x8c
Jul 14 11:53:59 crabtree kernel: [<ffffffff811297e1>] ? nfs4_xdr_dec_read+0x0/0xf0
Jul 14 11:53:59 crabtree kernel: [<ffffffff812de609>] ? call_decode+0xa7/0x696
Jul 14 11:53:59 crabtree kernel: [<ffffffff812e44d7>] ? __rpc_execute+0x6f/0x1cb
Jul 14 11:53:59 crabtree kernel: [<ffffffff812e466b>] ? rpc_async_schedule+0x0/0x11
Jul 14 11:53:59 crabtree kernel: [<ffffffff81043a70>] ? process_one_work+0x20e/0x34e
Jul 14 11:53:59 crabtree kernel: [<ffffffff81043faf>] ? worker_thread+0x1c9/0x33e
Jul 14 11:53:59 crabtree kernel: [<ffffffff8102812a>] ? __wake_up_common+0x41/0x78
Jul 14 11:53:59 crabtree kernel: [<ffffffff81043de6>] ? worker_thread+0x0/0x33e
Jul 14 11:53:59 crabtree kernel: [<ffffffff81043de6>] ? worker_thread+0x0/0x33e
Jul 14 11:53:59 crabtree kernel: [<ffffffff81046a7b>] ? kthread+0x7a/0x82
Jul 14 11:53:59 crabtree kernel: [<ffffffff81002c14>] ? kernel_thread_helper+0x4/0x10
Jul 14 11:53:59 crabtree kernel: [<ffffffff81046a01>] ? kthread+0x0/0x82
Jul 14 11:53:59 crabtree kernel: [<ffffffff81002c10>] ? kernel_thread_helper+0x0/0x10
Jul 14 11:53:59 crabtree kernel: ---[ end trace b49f8814787e2cbd ]---

These might look familiar because Joshua Scoggins reported the issue
last month but ended up switching to an older kernel (I work in the
department that provides the NFS services).

The setup is a Linux NFSv4 client using sec=krb5p to a Solaris 10u9
NFSv4 server.

Since it's been reported already, I decided to do my homework before
sending this email and ran through a git bisect.  The issue itself is
fairly easy to reproduce with a few runs of bonnie++ on the NFSv4 share
and tends to show up during the "Rewriting..." test phase (if that
helps).  The guilty commit is:
http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=commit;h=4018bf3eec5ff6bf1234a602a4e72518757a7f55

Any ideas on a fix or on more debugging to do?  I'd love to help make
these things no longer show up (although I don't really want to
sacrifice 3DES for it).


Also, what impact do these warnings have?  Is the I/O during the
process lost/corrupted?

Thanks,
Brian De Wolf
