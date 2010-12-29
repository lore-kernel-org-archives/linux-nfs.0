Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49814 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753518Ab0L2S4V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Dec 2010 13:56:21 -0500
Date: Wed, 29 Dec 2010 13:56:09 -0500
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] nfsd4: implement secinfo_no_name
Message-ID: <20101229185609.GA12218@fieldses.org>
References: <1292612511-14203-1-git-send-email-bfields@redhat.com>
 <1292612511-14203-4-git-send-email-bfields@redhat.com>
 <4D183265.70608@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D183265.70608@cn.fujitsu.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Dec 27, 2010 at 02:29:57PM +0800, Mi Jinlong wrote:
> When testing this patch, oops appears.
> 
> We should implement a nfsd4_encode_secinfo_no_name() instead using 
> nfsd4_encode_secinfo(). 
> 
> With the following patch, kernel will run correctly.

Whoops, yes, you're correct.  I've applied your patch.  Thanks!

(What are you using for testing?)

--b.

> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs4xdr.c |   21 +++++++++++++++++----
>  1 files changed, 17 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index b543b24..437b462 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -2845,11 +2845,10 @@ nfsd4_encode_rename(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
>  }
>  
>  static __be32
> -nfsd4_encode_secinfo(struct nfsd4_compoundres *resp, __be32 nfserr,
> -		     struct nfsd4_secinfo *secinfo)
> +nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
> +			 __be32 nfserr,struct svc_export *exp)
>  {
>  	int i = 0;
> -	struct svc_export *exp = secinfo->si_exp;
>  	u32 nflavs;
>  	struct exp_flavor_info *flavs;
>  	struct exp_flavor_info def_flavs[2];
> @@ -2911,6 +2910,20 @@ out:
>  	return nfserr;
>  }
>  
> +static __be32
> +nfsd4_encode_secinfo(struct nfsd4_compoundres *resp, __be32 nfserr,
> +		     struct nfsd4_secinfo *secinfo)
> +{
> +	return nfsd4_do_encode_secinfo(resp, nfserr, secinfo->si_exp);
> +}
> +
> +static __be32
> +nfsd4_encode_secinfo_no_name(struct nfsd4_compoundres *resp, __be32 nfserr,
> +		     struct nfsd4_secinfo_no_name *secinfo)
> +{
> +	return nfsd4_do_encode_secinfo(resp, nfserr, secinfo->sin_exp);
> +}
> +
>  /*
>   * The SETATTR encode routine is special -- it always encodes a bitmap,
>   * regardless of the error status.
> @@ -3173,7 +3186,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
>  	[OP_LAYOUTCOMMIT]	= (nfsd4_enc)nfsd4_encode_noop,
>  	[OP_LAYOUTGET]		= (nfsd4_enc)nfsd4_encode_noop,
>  	[OP_LAYOUTRETURN]	= (nfsd4_enc)nfsd4_encode_noop,
> -	[OP_SECINFO_NO_NAME]	= (nfsd4_enc)nfsd4_encode_secinfo,
> +	[OP_SECINFO_NO_NAME]	= (nfsd4_enc)nfsd4_encode_secinfo_no_name,
>  	[OP_SEQUENCE]		= (nfsd4_enc)nfsd4_encode_sequence,
>  	[OP_SET_SSV]		= (nfsd4_enc)nfsd4_encode_noop,
>  	[OP_TEST_STATEID]	= (nfsd4_enc)nfsd4_encode_noop,
> -- 
> 1.7.3.3
> 
> ==========================================================================
> BUG: unable to handle kernel NULL pointer dereference at 00000044
> IP: [<e2bd239a>] nfsd4_encode_secinfo+0x1c/0x1c1 [nfsd]
> *pdpt = 000000001d59c001 *pde = 0000000000000000
> Oops: 0000 [#1] SMP
> last sysfs file: /sys/kernel/mm/ksm/run
> Modules linked in: ipt_MASQUERADE iptable_nat nf_nat bridge stp llc nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc ipv6 snd_ens1371 gameport snd_rawmidi snd_ac97_codec ac97_bus snd_seq snd_seq_device ppdev parport_pc snd_pcm snd_timer i2c_piix4 i2c_core snd soundcore snd_page_alloc pcnet32 mii parport microcode pcspkr BusLogic floppy [last unloaded: mperf]
> 
> Pid: 1285, comm: nfsd Not tainted 2.6.37-rc7+ #50 440BX Desktop Reference Platform/VMware Virtual Platform
> EIP: 0060:[<e2bd239a>] EFLAGS: 00010246 CPU: 0
> EIP is at nfsd4_encode_secinfo+0x1c/0x1c1 [nfsd]
> EAX: ddd30000 EBX: ddd30000 ECX: 00000000 EDX: 00000000
> ESI: ddbaba18 EDI: e2bd237e EBP: dd48befc ESP: dd48bec4
>  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> Process nfsd (pid: 1285, ti=dd48a000 task=dd9d3240 task.ti=dd48a000)
> Stack:
>  00000000 deb18198 db078ef8 0fd00000 db07f4c8 00000000 00000000 db07f4c8
>  de054600 dd48bef8 c04e17af ddd30000 ddbaba18 e2bd237e dd48bf1c e2bd1e2b
>  ddbaba20 e2bd0b0c ddb1c068 ddd30000 ddbaba18 e2bd0b0c dd48bf40 e2bd096c
> Call Trace:
>  [<c04e17af>] ? dput+0x36/0xfc
>  [<e2bd237e>] ? nfsd4_encode_secinfo+0x0/0x1c1 [nfsd]
>  [<e2bd1e2b>] ? nfsd4_encode_operation+0x56/0x11b [nfsd]
>  [<e2bd0b0c>] ? nfsd4_secinfo_no_name+0x0/0x4a [nfsd]
>  [<e2bd0b0c>] ? nfsd4_secinfo_no_name+0x0/0x4a [nfsd]
>  [<e2bd096c>] ? nfsd4_proc_compound+0x252/0x370 [nfsd]
>  [<e2bc42de>] ? nfsd_dispatch+0xd1/0x19d [nfsd]
>  [<e248912f>] ? svc_process_common+0x283/0x46c [sunrpc]
>  [<e24894dd>] ? svc_process+0xde/0xf1 [sunrpc]
>  [<e2bc47cf>] ? nfsd+0xd6/0x115 [nfsd]
>  [<e2bc46f9>] ? nfsd+0x0/0x115 [nfsd]
>  [<c0454d22>] ? kthread+0x62/0x67
>  [<c0454cc0>] ? kthread+0x0/0x67
>  [<c0409a3e>] ? kernel_thread_helper+0x6/0x10
> Code: 83 c0 04 89 01 31 c0 83 c4 14 5b 5e 5f 5d c3 55 89 e5 57 56 53 89 c3 83 ec 2c 85 d2 89 55 c8 8b 49 08 89 4d dc 0f 85 68 01 00 00 <8b> 41 44 85 c0 74 0b 83 c1 48 89 4d d4 89 45 d8 eb 4d 8b 55 dc
> EIP: [<e2bd239a>] nfsd4_encode_secinfo+0x1c/0x1c1 [nfsd] SS:ESP 0068:dd48bec4
> CR2: 0000000000000044
> ---[ end trace 9c31555ffcc1f3e8 ]---
> 
> thanks, 
> Mi Jinlong
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
