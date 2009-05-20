From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Possible NFS failure with late kernel versions
Date: Wed, 20 May 2009 13:02:15 -0400
Message-ID: <1242838935.24471.20.camel@heimdal.trondhjem.org>
References: <0122F800A3B64C449565A9E8C297701005E6DE4B@hoexmb9.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
To: "Weathers, Norman R." <Norman.R.Weathers@conocophillips.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <0122F800A3B64C449565A9E8C297701005E6DE4B@hoexmb9.conoco.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-05-20 at 11:50 -0500, Weathers, Norman R. wrote:
> Hello, list.
> 
> I have run across some weird failures as of late.  The following is a
> kernel bug output from one kernel (2.6.27.24):
> 
> ------------[ cut here ]------------
> WARNING: at kernel/softirq.c:136 local_bh_enable_ip+0xb5/0xf0()
> Modules linked in: nfsd lockd nfs_acl exportfs autofs4 sunrpc
> scsi_dh_emc ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables
> ipv6 xfs uinput iTCO_wdt iTCO_vendor_support ipmi_si iw_nes qla2xxx
> ipmi_msghandler bnx2 serio_raw pcspkr joydev ib_core i5000_edac hpwdt
> scsi_transport_fc hpilo edac_core scsi_tgt libcrc32c dm_round_robin
> dm_multipath shpchp cciss [last unloaded: freq_table]
> Pid: 3094, comm: nfsd Not tainted 2.6.27.24 #1
> 
> Call Trace:
>  [<ffffffff81043b9f>] warn_on_slowpath+0x5f/0x90
>  [<ffffffff81049ebc>] ? local_bh_enable_ip+0x8c/0xf0
>  [<ffffffff813b9760>] ? _read_unlock_bh+0x10/0x20
>  [<ffffffff81384914>] ? ipt_do_table+0x1d4/0x550
>  [<ffffffff81337036>] ? nf_conntrack_in+0x236/0x5d0
>  [<ffffffff8133747a>] ? destroy_conntrack+0xaa/0x110
>  [<ffffffff81049ee5>] local_bh_enable_ip+0xb5/0xf0
>  [<ffffffff813b977f>] _spin_unlock_bh+0xf/0x20
>  [<ffffffff8133747a>] destroy_conntrack+0xaa/0x110
>  [<ffffffff813344e2>] nf_conntrack_destroy+0x12/0x20
>  [<ffffffff8130bc65>] skb_release_all+0xc5/0x100
>  [<ffffffff8130b541>] __kfree_skb+0x11/0xa0
>  [<ffffffff8130b5e7>] kfree_skb+0x17/0x40
>  [<ffffffffa010eed8>] nes_nic_send+0x408/0x4b0 [iw_nes]
>  [<ffffffff81319fac>] ? neigh_resolve_output+0x10c/0x2d0
>  [<ffffffffa010f089>] nes_netdev_start_xmit+0x109/0xa60 [iw_nes]
>  [<ffffffff81337579>] ? __nf_ct_refresh_acct+0x99/0x190
>  [<ffffffff8133add2>] ? tcp_packet+0xa42/0xeb0
>  [<ffffffff81348ff4>] ? ip_queue_xmit+0x1e4/0x3b0
>  [<ffffffff81384914>] ? ipt_do_table+0x1d4/0x550
>  [<ffffffff81049ebc>] ? local_bh_enable_ip+0x8c/0xf0
>  [<ffffffff813b9760>] ? _read_unlock_bh+0x10/0x20
>  [<ffffffff81384914>] ? ipt_do_table+0x1d4/0x550
>  [<ffffffff81337036>] ? nf_conntrack_in+0x236/0x5d0
>  [<ffffffff81313f5d>] dev_hard_start_xmit+0x21d/0x2a0
>  [<ffffffff81328b4e>] __qdisc_run+0x1ee/0x230
>  [<ffffffff813160a8>] dev_queue_xmit+0x2f8/0x580
>  [<ffffffff81319fac>] neigh_resolve_output+0x10c/0x2d0
>  [<ffffffff8134983c>] ip_finish_output+0x1cc/0x2f0
>  [<ffffffff813499c5>] ip_output+0x65/0xb0
>  [<ffffffff81348780>] ip_local_out+0x20/0x30
>  [<ffffffff81348ff4>] ip_queue_xmit+0x1e4/0x3b0
>  [<ffffffff8135cbcb>] tcp_transmit_skb+0x4eb/0x760
>  [<ffffffff8135cfe7>] tcp_send_ack+0xd7/0x110
>  [<ffffffff81355e3c>] __tcp_ack_snd_check+0x5c/0xc0
>  [<ffffffff8135add9>] tcp_rcv_established+0x6e9/0x9e0
>  [<ffffffff81363330>] tcp_v4_do_rcv+0x2c0/0x410
>  [<ffffffff81307aec>] ? lock_sock_nested+0xbc/0xd0
>  [<ffffffff813079c5>] release_sock+0x65/0xd0
>  [<ffffffff81350bd1>] tcp_ioctl+0xc1/0x190
>  [<ffffffff81371547>] inet_ioctl+0x27/0xc0
>  [<ffffffff81303cba>] kernel_sock_ioctl+0x3a/0x60
>  [<ffffffffa025882d>] svc_tcp_recvfrom+0x11d/0x450 [sunrpc]
>  [<ffffffffa02627b0>] svc_recv+0x560/0x850 [sunrpc]
>  [<ffffffff8103bcf0>] ? default_wake_function+0x0/0x10
>  [<ffffffffa02a69ad>] nfsd+0xdd/0x2d0 [nfsd]
>  [<ffffffffa02a68d0>] ? nfsd+0x0/0x2d0 [nfsd]
>  [<ffffffffa02a68d0>] ? nfsd+0x0/0x2d0 [nfsd]
>  [<ffffffff8105aa69>] kthread+0x49/0x90
>  [<ffffffff8100d5b9>] child_rip+0xa/0x11
>  [<ffffffff8100cbfc>] ? restore_args+0x0/0x30
>  [<ffffffff8105aa20>] ? kthread+0x0/0x90
>  [<ffffffff8100d5af>] ? child_rip+0x0/0x11
> 
> ---[ end trace 7decf549249f3f2a ]---
> 
> I have used 2.6.28.10 and 2.6.29 and they all have this same bug.  The
> end result is that under heavy load, these servers crash within a few
> minutes of emitting this trace.
> 
> Hardware:  HP Proliant Server, Dual 3.0 GHz Intel CPUs, 16 GB memory.
> Storage:    Qlogic QLA2xxx 4 Gb fibre card to EMC CX3-80 (Multipath)
> Network:    Intel / NetEffect 10 Gb iWarp NE20 (fibre)
> OS:           Fedora 10
> Clients:      CentOS 5.2 10 Gb nodes / 10 Gb switches, so a very fast
> network.
> 
> Any assistance would be greatly appreciated.
> 
> If need be, I can restart the server under the different kernels and see
> if I can get the error from those as well.

Your trace shows that this is happening down in the murky depths of the
netfilter code, so to me it looks more like a networking issue rather
than a NFS bug.

Ccing the linux networking list...

Cheers
  Trond

