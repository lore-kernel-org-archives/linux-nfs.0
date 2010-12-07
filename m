Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29270 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752489Ab0LGVlj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Dec 2010 16:41:39 -0500
Subject: Re: oops in nfs_flush_incompatible (and possible fix?)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20101206145743.4464c79d@tlielax.poochiereds.net>
References: <20101206145743.4464c79d@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Dec 2010 16:41:22 -0500
Message-ID: <1291758082.3049.42.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-12-06 at 14:57 -0500, Jeff Layton wrote:
> Hi Trond,
> 
> I've got a RH bug opened by one of our partners against the RHEL5.6
> development kernel. That kernel got a backported version of the
> lock_context patches that you merged not too long ago. I'm trying to
> get permission to add you to the BZ so you can have a look for yourself
> too.
> 
> Long story short, they seem to get a reproducible oops like this when
> testing under heavy load:
> 
> Unable to handle kernel NULL pointer dereference at 0000000000000020 RIP:
> [<ffffffff88856222>] :nfs:nfs_flush_incompatible+0x6d/0xd1
> PGD 7d9bc2067 PUD 7d9bbf067 PMD 0
> Oops: 0000 [1] SMP
> last sysfs file: /devices/system/cpu/cpu125/cpufreq/scaling_setspeed
> CPU 126
> Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler tun nfs fscache
> nfs_acl ebtable_nat ebtables ipt_MASQUERADE iptable_nat ip_nat bridge
> autofs4 hidp rfcomm l2cap bluetooth lockd sunrpc acpi_cpufreq freq_table
> mperf ip_conntrack_netbios_ns ipt_REJECT xt_state ip_conntrack nfnetlink
> iptable_filter ip_tables ip6t_REJECT xt_tcpudp ip6table_filter ip6_tables
> x_tables be2iscsi ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr
> iscsi_tcp bnx2i cnic ipv6 xfrm_nalgo crypto_api uio cxgb3i cxgb3 8021q
> libiscsi_tcp libiscsi2 scsi_transport_iscsi2 scsi_transport_iscsi loop
> dm_multipath scsi_dh video backlight sbs power_meter hwmon i2c_ec dell_wmi
> wmi button battery asus_acpi acpi_memhotplug ac parport_pc lp parport
> ksm(U) kvm_intel(U) kvm(U) joydev sg tpm_tis i2c_i801 tpm cdc_ether pcspkr
> i7core_edac ide_cd i2c_core edac_mc usbnet tpm_bios cdrom bnx2 dm_raid45
> dm_message dm_region_hash dm_mem_cache dm_snapshot dm_zero dm_mirror
> dm_log dm_mod ata_piix libata shpchp mptsas mptscsih mptbase
> scsi_transport_sas sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd
> Pid: 21273, comm: snake.exe Tainted: G      2.6.18-229.el5 #1
> RIP: 0010:[<ffffffff88856222>]  [<ffffffff88856222>]
> :nfs:nfs_flush_incompatible+0x6d/0xd1
> RSP: 0018:ffff810a3daddb48  EFLAGS: 00010246
> RAX: 0000000000000000 RBX: ffff8101a4c05c40 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff8101d27f3ac8
> RBP: 0000000000000000 R08: 0000000000000000 R09: ffff810a3daddc80
> R10: ffff8106896a7c00 R11: 0000000000000048 R12: ffff810a833ebb78
> R13: ffff811213f3f6f0 R14: ffff8110c0a1c9c0 R15: 0000000000000001
> FS:  00002b6188e086e0(0000) GS:ffff811e7f78c940(0000)
> knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000020 CR3: 00000007d9bc7000 CR4: 00000000000026e0
> Process snake.exe (pid: 21273, threadinfo ffff810a3dadc000, task
> ffff8107d9b24100)
> Stack:  ffff810a833ebb78 000000000000007e ffff81102e769e80
> 0000000000000000
> 00000000000014ac ffffffff8884b101 ffff810a3daddc80 0000007e00000000
> ffff811213f3f800 ffffffff8886b8e0 000000000000007e 00000000000014ac
> Call Trace:
> [<ffffffff8884b101>] :nfs:nfs_write_begin+0x65/0xf8
> [<ffffffff8000fda3>] generic_file_buffered_write+0x14b/0x675
> [<ffffffff80062ff0>] thread_return+0x62/0xfe
> [<ffffffff800166e8>] __generic_file_aio_write_nolock+0x369/0x3b6
> [<ffffffff80063c57>] __mutex_lock_slowpath+0x68/0x9b
> [<ffffffff8002187e>] generic_file_aio_write+0x65/0xc1
> [<ffffffff8884b805>] :nfs:nfs_file_write+0xd8/0x14f
> [<ffffffff80018338>] do_sync_write+0xc7/0x104
> [<ffffffff800a2896>] autoremove_wake_function+0x0/0x2e
> [<ffffffff8005a4c5>] hrtimer_cancel+0xc/0x16
> [<ffffffff80016af0>] vfs_write+0xce/0x174
> [<ffffffff800173a8>] sys_write+0x45/0x6e
> [<ffffffff8005d28d>] tracesys+0xd5/0xe0
> 
> Code: 48 8b 50 20 65 48 8b 04 25 00 00 00 00 48 3b 90 98 05 00 00
> RIP  [<ffffffff88856222>] :nfs:nfs_flush_incompatible+0x6d/0xd1
> RSP <ffff810a3daddb48>
> CR2: 0000000000000020
> <0>Kernel panic - not syncing: Fatal exception
> 
> 
> The problem seems to be that the req->wb_lock_context is NULL so it
> dies dereferencing that pointer in nfs_flush_incompatible. The original
> kernel they tested didn't have the check for a NULL return from
> nfs_get_lock_context. I fixed that however and they still saw the bug.
> 
> At this point, I'm thinking this is a race that might be fixed by the
> following patch. These bare calls to nfs_clear_request look suspicious
> to me, given that we're not checking the refcount on the request before
> freeing fields in it. I haven't tested the patch yet, but I think it
> looks correct.
> 
> Thoughts?
> 
> -----------------------[snip]---------------------------
> 
> nfs: remove extraneous and problematic calls to nfs_clear_request
> 
> When a nfs_page is freed, nfs_free_request is called which also calls
> nfs_clear_request to clean out the lock and open contexts and free the
> pagecache page.
> 
> However, a couple of places in the nfs code call nfs_clear_request
> themselves. What happens here if the refcount on the request is still high?
> We'll be releasing contexts and freeing pointers while the request is
> possibly still in use.
> 
> Remove those bare calls to nfs_clear_context. That should only be done when
> the request is being freed.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/read.c  |    1 -
>  fs/nfs/write.c |    1 -
>  2 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
> index e4b62c6..aedcaa7 100644
> --- a/fs/nfs/read.c
> +++ b/fs/nfs/read.c
> @@ -152,7 +152,6 @@ static void nfs_readpage_release(struct nfs_page *req)
>  			(long long)NFS_FILEID(req->wb_context->path.dentry->d_inode),
>  			req->wb_bytes,
>  			(long long)req_offset(req));
> -	nfs_clear_request(req);
>  	nfs_release_request(req);
>  }
>  
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 4c14c17..c41a435 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -422,7 +422,6 @@ static void nfs_inode_remove_request(struct nfs_page *req)
>  		iput(inode);
>  	} else
>  		spin_unlock(&inode->i_lock);
> -	nfs_clear_request(req);
>  	nfs_release_request(req);
>  }
>  

I've been racking my brain for days now trying to remember why we clear
the request in these cases. I think it was only about ensuring that we
could throw the page out of the cache using invalidate_inode_pages()
(and there is a comment about that in early 2.4.x kernels).

As far as I can see, there no longer appear to be any side effects to
deferring releasing the page or open_contexts but I'm still a bit
nervous about doing so.
Can we therefore please give it a good week of pounding upon before I
pass it on to Linus?

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

