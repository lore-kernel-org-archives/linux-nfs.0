From: "Andrew Dixie" <andrew-0FSrDVjkvKm9koe0gwxAeg@public.gmane.org>
Subject: Re: (fwd) nfs hang on 2.6.24
Date: Thu, 7 Feb 2008 11:40:38 +1300 (NZDT)
Message-ID: <55598.203.167.214.129.1202337638.squirrel@mail.orcon.net.nz>
References: <20080205090132.GA8286@stro.at>
    <1202248931.12271.18.camel@heimdal.trondhjem.org>
    <003301c86888$ed735a20$0301a8c0@MURTLE>
    <1202310021.12647.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Andrew Dixie" <andrew-0FSrDVjkvKm9koe0gwxAeg@public.gmane.org>, linux-nfs@vger.kernel.org,
	"maximilian attems" <max-U9r9yeDMy7A@public.gmane.org>
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out3.orcon.net.nz ([219.88.242.31]:47870 "EHLO
	mx5.orcon.net.nz" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756183AbYBFWkl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2008 17:40:41 -0500
Received: from Debian-exim by mx5.orcon.net.nz with local (Exim 4.67)
	(envelope-from <andrew-0FSrDVjkvKm9koe0gwxAeg@public.gmane.org>)
	id 1JMswZ-0008FB-LN
	for linux-nfs@vger.kernel.org; Thu, 07 Feb 2008 11:40:39 +1300
In-Reply-To: <1202310021.12647.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>   What is rpciod doing while the machine hangs?
>   Does 'netstat -t' show an active tcp connection to the server?
>   Does tcpdump show any traffic going on the wire?
>   What server are you running against? From the error messages below, I
> see it is a Linux machine, but which kernel is it running?

Server is 2.6.18-5 from debian.

>From /proc/mounts:

server1:/files /files nfs
rw,vers=3,rsize=8192,wsize=8192,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=10.64.2.90
0 0
devfile:/srv/linshared_srv /srv nfs
rw,vers=3,rsize=32768,wsize=32768,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=10.64.2.21
0 0
devfile:/home /home nfs4
rw,vers=4,rsize=32768,wsize=32768,hard,intr,proto=tcp,timeo=600,retrans=3,sec=sys,addr=10.64.2.21
0 0

The nfs connections went into CLOSE_WAIT:
tcp        0      0 10.64.2.25:888          10.64.2.21:2049        
CLOSE_WAIT
tcp        0      0 10.64.2.25:974          10.64.2.21:2049        
CLOSE_WAIT

I can't see any traffic for it attempting to reconnect.

Below are the rpciod stacktraces from the previous hang.
Also rpc.idmap looks to be in the middle of something.

Cheers,
Andrew

rpciod/0      S f76f9e7c     0  2663      2
       f7d7c1f0 00000046 00000002 f76f9e7c f76f9e74 00000000 00000286
f669bc00
       f7d7c358 c180a940 00000000 015b37db f669bc00 dfbc8c80 000000ff
00000000
       00000000 00000000 f76f9ebc 00000000 f76f9ec4 c180284c f8c62e85
c02bc97f
Call Trace:
 [<f8c62e85>] rpc_wait_bit_interruptible+0x1a/0x1f [sunrpc]
 [<c02bc97f>] __wait_on_bit+0x33/0x58
 [<f8c62e6b>] rpc_wait_bit_interruptible+0x0/0x1f [sunrpc]
 [<f8c62e6b>] rpc_wait_bit_interruptible+0x0/0x1f [sunrpc]
 [<c02bca07>] out_of_line_wait_on_bit+0x63/0x6b
 [<c013545e>] wake_bit_function+0x0/0x3c
 [<f8c62e19>] __rpc_wait_for_completion_task+0x32/0x39 [sunrpc]
 [<f8ce1352>] nfs4_wait_for_completion_rpc_task+0x1b/0x2f [nfs]
 [<f8ce2336>] nfs4_proc_delegreturn+0x116/0x172 [nfs]
 [<f8c63411>] rpc_async_schedule+0x0/0xa [sunrpc]
 [<f8ced370>] nfs_do_return_delegation+0xf/0x1d [nfs]
 [<f8cd135f>] nfs_dentry_iput+0xd/0x49 [nfs]
 [<c01865d2>] dentry_iput+0x74/0x93
 [<c018666d>] d_kill+0x2d/0x46
 [<c0186970>] dput+0xd5/0xdc
 [<f8ce4016>] nfs4_free_closedata+0x26/0x41 [nfs]
 [<f8c62c8d>] rpc_release_calldata+0x16/0x20 [sunrpc]
 [<c013220d>] run_workqueue+0x7d/0x109
 [<c0132a83>] worker_thread+0x0/0xc5
 [<c0132b3d>] worker_thread+0xba/0xc5
 [<c0135429>] autoremove_wake_function+0x0/0x35
 [<c0135362>] kthread+0x38/0x5e
 [<c013532a>] kthread+0x0/0x5e
 [<c0104b0f>] kernel_thread_helper+0x7/0x10

rpciod/1-3 identical:
       df848710 00000046 00000002 f76fbfa0 f76fbf98 00000000 f8c633fd
00000572
       df848878 c1812940 00000001 015b36d3 df9abc08 f8c63411 000000ff
00000000
       00000000 00000000 f776a840 c0132a83 f76fbfd0 00000000 c0132b0b
00000000
Call Trace:
 [<f8c633fd>] __rpc_execute+0x21d/0x231 [sunrpc]
 [<f8c63411>] rpc_async_schedule+0x0/0xa [sunrpc]
 [<c0132a83>] worker_thread+0x0/0xc5
 [<c0132b0b>] worker_thread+0x88/0xc5
 [<c0135429>] autoremove_wake_function+0x0/0x35
 [<c0135362>] kthread+0x38/0x5e
 [<c013532a>] kthread+0x0/0x5e
 [<c0104b0f>] kernel_thread_helper+0x7/0x10
 =======================
rpc.idmapd    S f777ff10     0  2687      1
       f7cea610 00000086 00000002 f777ff10 f777ff08 00000000 00000000
00000000
       f7cea778 c1822940 00000003 015d5741 00000000 00000000 000000ff
00000000
       00000000 00000000 7fffffff f75e2b00 080536e8 00000286 c02bc7f1
00000000
Call Trace:
 [<c01355e8>] add_wait_queue+0x12/0x32
 [<c017d287>] pipe_poll+0x24/0x7d
 [<c0183476>] do_select+0x365/0x3bc
 [<c0183a60>] __pollwait+0x0/0xac
 [<c011f44f>] default_wake_function+0x0/0x8
message repeated 10 times
 [<c0259bb5>] skb_release_all+0xa3/0xfa
 [<c025e590>] dev_hard_start_xmit+0x20c/0x277
 [<c026d227>] __qdisc_run+0x9e/0x164
 [<c02564e7>] sk_reset_timer+0xc/0x16
 [<c0260758>] dev_queue_xmit+0x288/0x2b0
 [<c026b72e>] eth_header+0x0/0xb6
 [<c0264fe5>] neigh_resolve_output+0x203/0x235
 [<c027dd59>] ip_finish_output+0x0/0x208
 [<c027df29>] ip_finish_output+0x1d0/0x208
 [<c027edd1>] ip_output+0x7d/0x92
 [<c01e240c>] number+0x147/0x215
 [<c0183750>] core_sys_select+0x283/0x2a0
 [<c01e2d23>] vsnprintf+0x440/0x47c
 [<c0187123>] d_lookup+0x1b/0x3b
 [<c01a5fe3>] proc_flush_task+0x12b/0x235
 [<c0135a53>] posix_cpu_timers_exit_group+0x4a/0x50
 [<c0108472>] convert_fxsr_from_user+0x15/0xd5
 [<c0183be2>] sys_select+0xd6/0x187
 [<c018a6ce>] mntput_no_expire+0x11/0x66
 [<c0176b05>] filp_close+0x51/0x58
 [<c012743f>] sys_wait4+0x31/0x34
 [<c0103e5e>] sysenter_past_esp+0x6b/0xa1


