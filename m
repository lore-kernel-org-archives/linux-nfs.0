Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53255 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755948Ab2CEROz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 12:14:55 -0500
Message-ID: <4F54F48C.2090703@netapp.com>
Date: Mon, 05 Mar 2012 12:14:52 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/11] NFSv4: Simplify the struct nfs4_stateid
References: <1330902183-18879-1-git-send-email-Trond.Myklebust@netapp.com> <1330902183-18879-2-git-send-email-Trond.Myklebust@netapp.com> <1330902183-18879-3-git-send-email-Trond.Myklebust@netapp.com> <1330902183-18879-4-git-send-email-Trond.Myklebust@netapp.com> <1330902183-18879-5-git-send-email-Trond.Myklebust@netapp.com> <1330902183-18879-6-git-send-email-Trond.Myklebust@netapp.com> <1330902183-18879-7-git-send-email-Trond.Myklebust@netapp.com> <1330902183-18879-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330902183-18879-8-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I just finished bisecting an oops to this patch, does v2 fix the problem?  I hit it while running the special tests over v4.  I was able to compile after these patches, so that's a step forward!

- Bryan

The oops:

[   18.396379] general protection fault: 0000 [#1] PREEMPT SMP 
[   18.396996] CPU 0 
[   18.397116] Modules linked in: nfs nfs_acl auth_rpcgss fscache lockd sunrpc ext4 crc16 jbd2 mbcache virtio_balloon snd_hda_intel snd_hda_codec psmouse pcspkr serio_raw evdev snd_hwdep snd_pcm snd_page_alloc snd_timer snd soundcore i2c_piix4 i2c_core floppy button processor btrfs crc32c libcrc32c zlib_deflate sr_mod cdrom pata_acpi ata_piix uhci_hcd libata usbcore usb_common scsi_mod virtio_net virtio_pci virtio_blk virtio_ring virtio
[   18.399678] 
[   18.399678] Pid: 650, comm: nfsv4.0-svc Not tainted 3.3.0-rc2-MODULES+ #14 Bochs Bochs
[   18.399678] RIP: 0010:[<ffffffffa041cedd>]  [<ffffffffa041cedd>] nfs4_callback_compound+0x37d/0x550 [nfs]
[   18.399678] RSP: 0018:ffff88003cb33d50  EFLAGS: 00010246
[   18.399678] RAX: 0000000000000000 RBX: 0000bd9c00000067 RCX: 0000000000000000
[   18.399678] RDX: ffff88003cb33e00 RSI: ffff88003ba84000 RDI: ffff88003ba86000
[   18.399678] RBP: ffff88003cb33e50 R08: 0000000000000000 R09: ffff88003ba8601a
[   18.399678] R10: ffff88003cb33fd8 R11: 0000000000000000 R12: 0000000000000004
[   18.399678] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
[   18.399678] FS:  0000000000000000(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
[   18.399678] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   18.399678] CR2: 00007f35163bdf40 CR3: 000000003cbc2000 CR4: 00000000000006f0
[   18.399678] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   18.399678] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   18.399678] Process nfsv4.0-svc (pid: 650, threadinfo ffff88003cb32000, task ffff88003c81aac0)
[   18.399678] Stack:
[   18.399678]  ffff88003cb33d60 ffff88003b8a6000 ffff88003c934024 ffff88003c93401c
[   18.399678]  ffff88003ba86000 ffff88003ba84000 0000000100000000 ffffffffa042c300
[   18.399678]  ffff88003bb4d080 ffff88003b8a6190 ffff88003bb4d080 ffff88003b8a6190
[   18.399678] Call Trace:
[   18.399678]  [<ffffffffa0368f83>] svc_process+0x763/0x850 [sunrpc]
[   18.399678]  [<ffffffffa041c3f6>] nfs4_callback_svc+0x56/0xb0 [nfs]
[   18.399678]  [<ffffffffa041c3a0>] ? param_set_portnr+0x60/0x60 [nfs]
[   18.399678]  [<ffffffff810732e3>] kthread+0x93/0xa0
[   18.399678]  [<ffffffff8144ec24>] kernel_thread_helper+0x4/0x10
[   18.399678]  [<ffffffff81073250>] ? kthread_freezable_should_stop+0x70/0x70
[   18.399678]  [<ffffffff8144ec20>] ? gs_change+0x13/0x13
[   18.399678] Code: ff 48 8b bd 08 ff ff ff ff 93 88 c2 42 a0 85 c0 41 89 c6 0f 85 1d ff ff ff 48 8d 55 b0 48 8b b5 28 ff ff ff 48 8b bd 20 ff ff ff <ff> 93 80 c2 42 a0 41 89 c6 e9 fd fe ff ff 0f 1f 44 00 00 48 85 
[   18.399678] RIP  [<ffffffffa041cedd>] nfs4_callback_compound+0x37d/0x550 [nfs]
[   18.399678]  RSP <ffff88003cb33d50>
[   18.425320] ---[ end trace 1f4aaa30a0f6d27f ]---


On 03/04/2012 06:03 PM, Trond Myklebust wrote:

> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/nfs4_fs.h     |    4 ++--
>  fs/nfs/nfs4proc.c    |    8 ++++----
>  fs/nfs/nfs4state.c   |    4 ++--
>  fs/nfs/nfs4xdr.c     |    6 +++---
>  fs/nfs/pnfs.c        |   10 +++++-----
>  include/linux/nfs4.h |    7 ++-----
>  6 files changed, 18 insertions(+), 21 deletions(-)
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index f4cafab..4b4e48b 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -349,12 +349,12 @@ extern struct svc_version nfs4_callback_version4;
>  
>  static inline void nfs4_stateid_copy(nfs4_stateid *dst, const nfs4_stateid *src)
>  {
> -	memcpy(dst->data, src->data, sizeof(dst->data));
> +	memcpy(dst, src, sizeof(*dst));
>  }
>  
>  static inline bool nfs4_stateid_match(const nfs4_stateid *dst, const nfs4_stateid *src)
>  {
> -	return memcmp(dst->data, src->data, sizeof(dst->data)) == 0;
> +	return memcmp(dst, src, sizeof(*dst)) == 0;
>  }
>  
>  #else
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 3e65766..5d90dc8 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -6257,13 +6257,13 @@ static int nfs41_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
>  static bool nfs41_match_stateid(const nfs4_stateid *s1,
>  		const nfs4_stateid *s2)
>  {
> -	if (memcmp(s1->stateid.other, s2->stateid.other,
> -		   sizeof(s1->stateid.other)) != 0)
> +	if (memcmp(s1->other, s2->other,
> +		   sizeof(s1->other)) != 0)
>  		return false;
>  
> -	if (s1->stateid.seqid == s2->stateid.seqid)
> +	if (s1->seqid == s2->seqid)
>  		return true;
> -	if (s1->stateid.seqid == 0 || s1->stateid.seqid == 0)
> +	if (s1->seqid == 0 || s1->seqid == 0)
>  		return true;
>  
>  	return false;
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 41e2b44..0b17ccc 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1215,8 +1215,8 @@ restart:
>  				 * Open state on this file cannot be recovered
>  				 * All we can do is revert to using the zero stateid.
>  				 */
> -				memset(state->stateid.data, 0,
> -					sizeof(state->stateid.data));
> +				memset(&state->stateid, 0,
> +					sizeof(state->stateid));
>  				/* Mark the file as being 'closed' */
>  				state->state = 0;
>  				break;
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 38736dc..76ef986 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -930,7 +930,7 @@ static void encode_nops(struct compound_hdr *hdr)
>  
>  static void encode_nfs4_stateid(struct xdr_stream *xdr, const nfs4_stateid *stateid)
>  {
> -	encode_opaque_fixed(xdr, stateid->data, NFS4_STATEID_SIZE);
> +	encode_opaque_fixed(xdr, stateid, NFS4_STATEID_SIZE);
>  }
>  
>  static void encode_nfs4_verifier(struct xdr_stream *xdr, const nfs4_verifier *verf)
> @@ -1548,7 +1548,7 @@ static void encode_open_stateid(struct xdr_stream *xdr, const struct nfs_open_co
>  	if (ctx->state != NULL) {
>  		nfs4_select_rw_stateid(&stateid, ctx->state, l_ctx->lockowner, l_ctx->pid);
>  		if (zero_seqid)
> -			stateid.stateid.seqid = 0;
> +			stateid.seqid = 0;
>  		encode_nfs4_stateid(xdr, &stateid);
>  	} else
>  		encode_nfs4_stateid(xdr, &zero_stateid);
> @@ -4237,7 +4237,7 @@ static int decode_opaque_fixed(struct xdr_stream *xdr, void *buf, size_t len)
>  
>  static int decode_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
>  {
> -	return decode_opaque_fixed(xdr, stateid->data, NFS4_STATEID_SIZE);
> +	return decode_opaque_fixed(xdr, stateid, NFS4_STATEID_SIZE);
>  }
>  
>  static int decode_close(struct xdr_stream *xdr, struct nfs_closeres *res)
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index c190e9c..6f1c1e3 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -496,12 +496,12 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
>  {
>  	u32 oldseq, newseq;
>  
> -	oldseq = be32_to_cpu(lo->plh_stateid.stateid.seqid);
> -	newseq = be32_to_cpu(new->stateid.seqid);
> +	oldseq = be32_to_cpu(lo->plh_stateid.seqid);
> +	newseq = be32_to_cpu(new->seqid);
>  	if ((int)(newseq - oldseq) > 0) {
>  		nfs4_stateid_copy(&lo->plh_stateid, new);
>  		if (update_barrier) {
> -			u32 new_barrier = be32_to_cpu(new->stateid.seqid);
> +			u32 new_barrier = be32_to_cpu(new->seqid);
>  
>  			if ((int)(new_barrier - lo->plh_barrier))
>  				lo->plh_barrier = new_barrier;
> @@ -525,7 +525,7 @@ pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid,
>  			int lget)
>  {
>  	if ((stateid) &&
> -	    (int)(lo->plh_barrier - be32_to_cpu(stateid->stateid.seqid)) >= 0)
> +	    (int)(lo->plh_barrier - be32_to_cpu(stateid->seqid)) >= 0)
>  		return true;
>  	return lo->plh_block_lgets ||
>  		test_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags) ||
> @@ -759,7 +759,7 @@ bool pnfs_roc_drain(struct inode *ino, u32 *barrier)
>  		}
>  	if (!found) {
>  		struct pnfs_layout_hdr *lo = nfsi->layout;
> -		u32 current_seqid = be32_to_cpu(lo->plh_stateid.stateid.seqid);
> +		u32 current_seqid = be32_to_cpu(lo->plh_stateid.seqid);
>  
>  		/* Since close does not return a layout stateid for use as
>  		 * a barrier, we choose the worst-case barrier.
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 32345c2..834df8b 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -183,15 +183,12 @@ struct nfs4_acl {
>  
>  typedef struct { char data[NFS4_VERIFIER_SIZE]; } nfs4_verifier;
>  
> -struct nfs41_stateid {
> +struct nfs_stateid4 {
>  	__be32 seqid;
>  	char other[NFS4_STATEID_OTHER_SIZE];
>  } __attribute__ ((packed));
>  
> -typedef union {
> -	char data[NFS4_STATEID_SIZE];
> -	struct nfs41_stateid stateid;
> -} nfs4_stateid;
> +typedef struct nfs_stateid4 nfs4_stateid;
>  
>  enum nfs_opnum4 {
>  	OP_ACCESS = 3,


