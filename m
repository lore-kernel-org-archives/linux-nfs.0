Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f65.google.com ([209.85.192.65]:35832 "EHLO
	mail-qg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbcFDT5e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Jun 2016 15:57:34 -0400
Received: by mail-qg0-f65.google.com with SMTP id t106so4043946qgt.2
        for <linux-nfs@vger.kernel.org>; Sat, 04 Jun 2016 12:57:34 -0700 (PDT)
Message-ID: <1465070251.26749.4.camel@poochiereds.net>
Subject: Re: [PATCH] nfs4: Fix potential use after free of state in
 nfs4_do_reclaim.
From: Jeff Layton <jlayton@poochiereds.net>
To: green@linuxhacker.ru, Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: Olga Kornievskaia <kolga@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Sat, 04 Jun 2016 15:57:31 -0400
In-Reply-To: <1465057313-2582381-1-git-send-email-green@linuxhacker.ru>
References: <DF4A1130-84CD-4083-92B4-6DEA2D633753@linuxhacker.ru>
	 <1465057313-2582381-1-git-send-email-green@linuxhacker.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2016-06-04 at 12:21 -0400, green@linuxhacker.ru wrote:
> From: Oleg Drokin <green@linuxhacker.ru>
> 
> Commit e8d975e73e5f ("fixing infinite OPEN loop in 4.0 stateid recovery")
> introduced access to state after it was just potentially freed by
> nfs4_put_open_state leading to a random data corruption somewhere.
> 
> BUG: unable to handle kernel paging request at ffff88004941ee40
> IP: [] nfs4_do_reclaim+0x461/0x740
> PGD 3501067 PUD 3504067 PMD 6ff37067 PTE 800000004941e060
> Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
> Modules linked in: loop rpcsec_gss_krb5 acpi_cpufreq tpm_tis joydev i2c_piix4 pcspkr tpm virtio_console nfsd ttm drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops floppy serio_raw virtio_blk drm
> CPU: 6 PID: 2161 Comm: 192.168.10.253- Not tainted 4.7.0-rc1-vm-nfs+ #112
> Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> task: ffff8800463dcd00 ti: ffff88003ff48000 task.ti: ffff88003ff48000
> RIP: 0010:[]  [] nfs4_do_reclaim+0x461/0x740
> RSP: 0018:ffff88003ff4bd68  EFLAGS: 00010246
> RAX: 0000000000000000 RBX: ffffffff81a49900 RCX: 00000000000000e8
> RDX: 00000000000000e8 RSI: ffff8800418b9930 RDI: ffff880040c96c88
> RBP: ffff88003ff4bdf8 R08: 0000000000000001 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000000 R12: ffff880040c96c98
> R13: ffff88004941ee20 R14: ffff88004941ee40 R15: ffff88004941ee00
> FS:  0000000000000000(0000) GS:ffff88006d000000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: ffff88004941ee40 CR3: 0000000060b0b000 CR4: 00000000000006e0
> Stack:
>  ffffffff813baad5 ffff8800463dcd00 ffff880000000001 ffffffff810e6b68
>  ffff880043ddbc88 ffff8800418b9800 ffff8800418b98c8 ffff88004941ee48
>  ffff880040c96c90 ffff880040c96c00 ffff880040c96c20 ffff880040c96c40
> Call Trace:
>  [] ? nfs4_do_reclaim+0x35/0x740
>  [] ? trace_hardirqs_on_caller+0x128/0x1b0
>  [] nfs4_run_state_manager+0x5ed/0xa40
>  [] ? nfs4_do_reclaim+0x740/0x740
>  [] ? nfs4_do_reclaim+0x740/0x740
>  [] kthread+0x101/0x120
>  [] ? trace_hardirqs_on_caller+0x128/0x1b0
>  [] ret_from_fork+0x1f/0x40
>  [] ? kthread_create_on_node+0x250/0x250
> Code: 65 80 4c 8b b5 78 ff ff ff e8 fc 88 4c 00 48 8b 7d 88 e8 13 67 d2 ff 49 8b 47 40 a8 02 0f 84 d3 01 00 00 4c 89 ff e8 7f f9 ff ff  41 80 26 7f 48 8b 7d c8 e8 b1 84 4c 00 e9 39 fd ff ff 3d e6
> RIP  [] nfs4_do_reclaim+0x461/0x740
>  RSP 
> CR2: ffff88004941ee40
> 
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> ---
>  fs/nfs/nfs4state.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 9679f47..834b875 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1488,9 +1488,9 @@ restart:
>  					}
>  					spin_unlock(&state->state_lock);
>  				}
> -				nfs4_put_open_state(state);
>  				clear_bit(NFS_STATE_RECLAIM_NOGRACE,
>  					&state->flags);
> +				nfs4_put_open_state(state);
>  				spin_lock(&sp->so_lock);
>  				goto restart;
>  			}

Nice catch.

Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
