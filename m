Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:47757 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916Ab0JYL5Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Oct 2010 07:57:24 -0400
Message-ID: <4CC5706F.3020308@bull.net>
Date: Mon, 25 Oct 2010 13:56:31 +0200
From: Menyhart Zoltan <Zoltan.Menyhart@bull.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: "xprt" reference count drops to 0
References: <4C7E4469.70807@duchatelet.net> <4CAAE046.5060209@bull.net> <20101021203801.GA12038@fieldses.org> <4CC1A722.4060907@bull.net> <20101022212007.GB22837@fieldses.org>
In-Reply-To: <20101022212007.GB22837@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> Maybe your fix is right, but I'm not sure: It looks to me like if
> svc_xprt_enqueue() gets to "process:" in a situation where the caller
> holds the only reference, then that's already a bug.  Do you know who
> the caller of svc_xprt_enqueue() was when this happened?

Unfortunately, I do not.
We saw lots of warnings like this (before my patch):

WARNING: at lib/kref.c:43 kref_get+0x23/0x2d()
Hardware name: Stoutland Platform
Modules linked in: rdma_ucm ib_sdp rdma_cm iw_cm ib_addr ib_ipoib ib_cm ib_sa ib_uverbs ib_umad mlx4_ib mlx4_core ib_mthca ib_mad ib_core ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables x_tables nfsd exportfs nfs lockd fscache nfs_acl auth_rpcgss sunrpc ipv6 scsi_dh_emc dm_round_robin dm_multipath iTCO_wdt i2c_i801 i2c_core igb ioatdma iTCO_vendor_support dca raid0 lpfc usb_storage scsi_transport_fc scsi_tgt [last unloaded: mlx4_core]
Pid: 3571, comm: nfsd Tainted: G      D W  2.6.32.9-21.fc12.Bull.6.x86_64 #1
Call Trace:
  [<ffffffff81050af0>] warn_slowpath_common+0x7c/0x94
  [<ffffffff81050b1c>] warn_slowpath_null+0x14/0x16
  [<ffffffff81222cca>] kref_get+0x23/0x2d
  [<ffffffffa01d0a90>] svc_xprt_get+0x12/0x14 [sunrpc]
  [<ffffffffa01d1903>] svc_recv+0x2db/0x78a [sunrpc]
  [<ffffffff8104b2ef>] ? default_wake_function+0x0/0x14
  [<ffffffffa02a1898>] nfsd+0xac/0x13f [nfsd]
  [<ffffffffa02a17ec>] ? nfsd+0x0/0x13f [nfsd]
  [<ffffffff8106ee0e>] kthread+0x7f/0x87
  [<ffffffff8100cd6a>] child_rip+0xa/0x20
  [<ffffffff8106ed8f>] ? kthread+0x0/0x87
  [<ffffffff8100cd60>] ? child_rip+0x0/0x20

When you can see the messages like this, the guilty task is already over...

> Doh.  Wait, when you say "has not been corrected on 2.6.36-rc3", do you
> mean you've actually *seen* the problem occur on 2.6.36-rc3?

We do not really use more advanced kernel than the 2.6.32 in a great number.
Just some test configurations up to the 2.6.36-rc6...
I have not seen this problem on recent kernels.

I'm not sure that I can really follow your explication.

I have got two reasons why I think my patch is good.

1. There are several code sequences where just after calling "svc_xprt_enqueue()",
    we drop "kref", i.e. we do not delegate the access right. Therefore "kref"
    should be increased by "svc_xprt_enqueue()". See:

svc_revisit()
{
...
	svc_xprt_enqueue(xprt);
	svc_xprt_put(xprt);
}

svc_xprt_release()
{
...
	svc_reserve(rqstp, 0):
		...
		svc_xprt_enqueue(xprt);
	svc_xprt_put(xprt);
}

svc_check_conn_limits()
{
...
			svc_xprt_enqueue(xprt);
			svc_xprt_put(xprt);
}

svc_age_temp_xprts()
{
...
		svc_xprt_enqueue(xprt);
		svc_xprt_put(xprt);
}

2. Increasing "kref" by "svc_recv()" is too late: by the time you can increase
    "kref", the structure may have already been destroyed.

As "svc_xprt_enqueue()" has not been modified since, I deduce that my patch is
correct for the 2.6.36-rc kernels, too.

Thanks.

Zoltan Menyhart
