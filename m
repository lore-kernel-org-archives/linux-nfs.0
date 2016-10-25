Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:37278 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756293AbcJYAyG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Oct 2016 20:54:06 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] sunrpc: fix some missing rq_rbuffer assignments
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1477355603-28642-1-git-send-email-jlayton@redhat.com>
Date: Mon, 24 Oct 2016 20:53:59 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>, guaneryu@gmail.com
Message-Id: <0556F824-45A6-4180-B1E9-D829CD7CEF81@oracle.com>
References: <1477355603-28642-1-git-send-email-jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 24, 2016, at 8:33 PM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> We've been seeing some crashes in testing that look like this:
> 
> BUG: unable to handle kernel NULL pointer dereference at           (null)
> IP: [<ffffffff8135ce99>] memcpy_orig+0x29/0x110
> PGD 212ca2067 PUD 212ca3067 PMD 0
> Oops: 0002 [#1] SMP
> Modules linked in: rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache ppdev parport_pc i2c_piix4 sg parport i2c_core virtio_balloon pcspkr acpi_cpufreq nfsd auth_rpcgss nfs_acl lockd grace sunrpc ip_tables xfs libcrc32c sd_mod ata_generic pata_acpi virtio_scsi 8139too ata_piix libata 8139cp mii virtio_pci floppy virtio_ring serio_raw virtio
> CPU: 1 PID: 1540 Comm: nfsd Not tainted 4.9.0-rc1 #39
> Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2007
> task: ffff88020d7ed200 task.stack: ffff880211838000
> RIP: 0010:[<ffffffff8135ce99>]  [<ffffffff8135ce99>] memcpy_orig+0x29/0x110
> RSP: 0018:ffff88021183bdd0  EFLAGS: 00010206
> RAX: 0000000000000000 RBX: ffff88020d7fa000 RCX: 000000f400000000
> RDX: 0000000000000014 RSI: ffff880212927020 RDI: 0000000000000000
> RBP: ffff88021183be30 R08: 01000000ef896996 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000000 R12: ffff880211704ca8
> R13: ffff88021473f000 R14: 00000000ef896996 R15: ffff880211704800
> FS:  0000000000000000(0000) GS:ffff88021fc80000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000000 CR3: 0000000212ca1000 CR4: 00000000000006e0
> Stack:
> ffffffffa01ea087 ffffffff63400001 ffff880215145e00 ffff880211bacd00
> ffff88021473f2b8 0000000000000004 00000000d0679d67 ffff880211bacd00
> ffff88020d7fa000 ffff88021473f000 0000000000000000 ffff88020d7faa30
> Call Trace:
> [<ffffffffa01ea087>] ? svc_tcp_recvfrom+0x5a7/0x790 [sunrpc]
> [<ffffffffa01f84d8>] svc_recv+0xad8/0xbd0 [sunrpc]
> [<ffffffffa0262d5e>] nfsd+0xde/0x160 [nfsd]
> [<ffffffffa0262c80>] ? nfsd_destroy+0x60/0x60 [nfsd]
> [<ffffffff810a9418>] kthread+0xd8/0xf0
> [<ffffffff816dbdbf>] ret_from_fork+0x1f/0x40
> [<ffffffff810a9340>] ? kthread_park+0x60/0x60
> Code: 00 00 48 89 f8 48 83 fa 20 72 7e 40 38 fe 7c 35 48 83 ea 20 48 83 ea 20 4c 8b 06 4c 8b 4e 08 4c 8b 56 10 4c 8b 5e 18 48 8d 76 20 <4c> 89 07 4c 89 4f 08 4c 89 57 10 4c 89 5f 18 48 8d 7f 20 73 d4
> RIP  [<ffffffff8135ce99>] memcpy_orig+0x29/0x110
> RSP <ffff88021183bdd0>
> CR2: 0000000000000000
> 
> Both Bruce and Eryu ran a bisect here and found that the problematic
> patch was 68778945e46 (SUNRPC: Separate buffer pointers for RPC Call and
> Reply messages).
> 
> That patch changed rpc_xdr_encode to use a new rq_rbuffer pointer to
> set up the receive buffer, but didn't change all of the necessary
> codepaths to set it properly. In particular the backchannel setup was
> missing.
> 
> We need to set rq_rbuffer whenever rq_buffer is set. Ensure that it is.
> 
> Cc: Chuck Lever <chuck.lever@oracle.com>

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Chuck Lever <chuck.lever@oracle.com>


> Reported-by: Eryu Guan <guaneryu@gmail.com>
> Reported-by: J. Bruce Fields <bfields@fieldses.org>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> net/sunrpc/xprtrdma/svc_rdma_backchannel.c | 1 +
> net/sunrpc/xprtsock.c                      | 1 +
> 2 files changed, 2 insertions(+)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> index 2d8545c34095..fc4535ead7c2 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> @@ -182,6 +182,7 @@ xprt_rdma_bc_allocate(struct rpc_task *task)
> 		return -ENOMEM;
> 
> 	rqst->rq_buffer = page_address(page);
> +	rqst->rq_rbuffer = (char *)rqst->rq_buffer + rqst->rq_callsize;
> 	return 0;
> }
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 0137af1c0916..e01c825bc683 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -2563,6 +2563,7 @@ static int bc_malloc(struct rpc_task *task)
> 	buf->len = PAGE_SIZE;
> 
> 	rqst->rq_buffer = buf->data;
> +	rqst->rq_rbuffer = (char *)rqst->rq_buffer + rqst->rq_callsize;
> 	return 0;
> }
> 
> -- 
> 2.7.4
> 

--
Chuck Lever



