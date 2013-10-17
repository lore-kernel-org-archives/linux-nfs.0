Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:34672 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755007Ab3JQOVG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 10:21:06 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Fix NULL dereference in recovery path
Date: Thu, 17 Oct 2013 14:21:04 +0000
Message-ID: <D7AFB465-CFB1-4BCF-ACD4-8E45B4D15960@netapp.com>
References: <1381188833-3728-1-git-send-email-dros@netapp.com>
 <1381954731.17178.28.camel@leira.trondhjem.org>
In-Reply-To: <1381954731.17178.28.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


-dros

On Oct 16, 2013, at 4:18 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2013-10-07 at 19:33 -0400, Weston Andros Adamson wrote:
>> _nfs4_opendata_reclaim_to_nfs4_state doesn't expect to see a cached
>> open CLAIM_PREVIOUS, but this can happen. An example is when there are
>> RDWR openers and RDONLY openers on a delegation stateid. The recovery
>> path will first try an open CLAIM_PREVIOUS for the RDWR openers, this
>> marks the delegation as not needing RECLAIM anymore, so the open
>> CLAIM_PREVIOUS for the RDONLY openers will not actually send an rpc.
>> 
>> The NULL dereference is due to _nfs4_opendata_reclaim_to_nfs4_state
>> returning PTR_ERR(rpc_status) when !rpc_done. When the open is
>> cached, rpc_done == 0 and rpc_status == 0, thus
>> _nfs4_opendata_reclaim_to_nfs4_state returns NULL - this is unexpected
>> by callers of nfs4_opendata_to_nfs4_state().
>> 
>> This can be reproduced easily by opening the same file two times on an
>> NFSv4.0 mount with delegations enabled, once as RDONLY and once as RDWR then
>> sleeping for a long time.  While the files are held open, kick off state
>> recovery and this NULL dereference will be hit every time.
>> 
>> An example OOPS:
>> 
>> [   65.003602] BUG: unable to handle kernel NULL pointer dereference at 00000000
>> 00000030
>> [   65.005312] IP: [<ffffffffa037d6ee>] __nfs4_close+0x1e/0x160 [nfsv4]
>> [   65.006820] PGD 7b0ea067 PUD 791ff067 PMD 0
>> [   65.008075] Oops: 0000 [#1] SMP
>> [   65.008802] Modules linked in: rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache
>> snd_ens1371 gameport nfsd snd_rawmidi snd_ac97_codec ac97_bus btusb snd_seq snd
>> _seq_device snd_pcm ppdev bluetooth auth_rpcgss coretemp snd_page_alloc crc32_pc
>> lmul crc32c_intel ghash_clmulni_intel microcode rfkill nfs_acl vmw_balloon serio
>> _raw snd_timer lockd parport_pc e1000 snd soundcore parport i2c_piix4 shpchp vmw
>> _vmci sunrpc ata_generic mperf pata_acpi mptspi vmwgfx ttm scsi_transport_spi dr
>> m mptscsih mptbase i2c_core
>> [   65.018684] CPU: 0 PID: 473 Comm: 192.168.10.85-m Not tainted 3.11.2-201.fc19
>> .x86_64 #1
>> [   65.020113] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop
>> Reference Platform, BIOS 6.00 07/31/2013
>> [   65.022012] task: ffff88003707e320 ti: ffff88007b906000 task.ti: ffff88007b906000
>> [   65.023414] RIP: 0010:[<ffffffffa037d6ee>]  [<ffffffffa037d6ee>] __nfs4_close+0x1e/0x160 [nfsv4]
>> [   65.025079] RSP: 0018:ffff88007b907d10  EFLAGS: 00010246
>> [   65.026042] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
>> [   65.027321] RDX: 0000000000000050 RSI: 0000000000000001 RDI: 0000000000000000
>> [   65.028691] RBP: ffff88007b907d38 R08: 0000000000016f60 R09: 0000000000000000
>> [   65.029990] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000001
>> [   65.031295] R13: 0000000000000050 R14: 0000000000000000 R15: 0000000000000001
>> [   65.032527] FS:  0000000000000000(0000) GS:ffff88007f600000(0000) knlGS:0000000000000000
>> [   65.033981] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [   65.035177] CR2: 0000000000000030 CR3: 000000007b27f000 CR4: 00000000000407f0
>> [   65.036568] Stack:
>> [   65.037011]  0000000000000000 0000000000000001 ffff88007b907d90 ffff88007a880220
>> [   65.038472]  ffff88007b768de8 ffff88007b907d48 ffffffffa037e4a5 ffff88007b907d80
>> [   65.039935]  ffffffffa036a6c8 ffff880037020e40 ffff88007a880000 ffff880037020e40
>> [   65.041468] Call Trace:
>> [   65.042050]  [<ffffffffa037e4a5>] nfs4_close_state+0x15/0x20 [nfsv4]
>> [   65.043209]  [<ffffffffa036a6c8>] nfs4_open_recover_helper+0x148/0x1f0 [nfsv4]
>> [   65.044529]  [<ffffffffa036a886>] nfs4_open_recover+0x116/0x150 [nfsv4]
>> [   65.045730]  [<ffffffffa036d98d>] nfs4_open_reclaim+0xad/0x150 [nfsv4]
>> [   65.046905]  [<ffffffffa037d979>] nfs4_do_reclaim+0x149/0x5f0 [nfsv4]
>> [   65.048071]  [<ffffffffa037e1dc>] nfs4_run_state_manager+0x3bc/0x670 [nfsv4]
>> [   65.049436]  [<ffffffffa037de20>] ? nfs4_do_reclaim+0x5f0/0x5f0 [nfsv4]
>> [   65.050686]  [<ffffffffa037de20>] ? nfs4_do_reclaim+0x5f0/0x5f0 [nfsv4]
>> [   65.051943]  [<ffffffff81088640>] kthread+0xc0/0xd0
>> [   65.052831]  [<ffffffff81088580>] ? insert_kthread_work+0x40/0x40
>> [   65.054697]  [<ffffffff8165686c>] ret_from_fork+0x7c/0xb0
>> [   65.056396]  [<ffffffff81088580>] ? insert_kthread_work+0x40/0x40
>> [   65.058208] Code: 5c 41 5d 5d c3 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55 48 89 e5 41 57 41 89 f7 41 56 41 89 ce 41 55 41 89 d5 41 54 53 48 89 fb <4c> 8b 67 30 f0 41 ff 44 24 44 49 8d 7c 24 40 e8 0e 0a 2d e1 44
>> [   65.065225] RIP  [<ffffffffa037d6ee>] __nfs4_close+0x1e/0x160 [nfsv4]
>> [   65.067175]  RSP <ffff88007b907d10>
>> [   65.068570] CR2: 0000000000000030
>> [   65.070098] ---[ end trace 0d1fe4f5c7dd6f8b ]---
>> 
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> fs/nfs/nfs4proc.c | 25 ++++++++++++++++++++-----
>> 1 file changed, 20 insertions(+), 5 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index d2b4845..58658db 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -1316,16 +1316,27 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
>> 	struct inode *inode = data->state->inode;
>> 	struct nfs4_state *state = data->state;
>> 	int ret;
>> +	bool cached_open = false;
>> 
>> 	if (!data->rpc_done) {
>> -		ret = data->rpc_status;
>> -		goto err;
>> +		if (data->rpc_status) {
>> +			ret = data->rpc_status;
>> +			goto err;
>> +		} else
>> +			/*
>> +			 * This is a cached open from an earlier operation
>> +			 * of the current state recovery event so there is
>> +			 * no need to update or check anything, just lookup
>> +			 * the open state.
>> +			 */
>> +			cached_open = true;
>> 	}
>> 
>> 	ret = -ESTALE;
>> -	if (!(data->f_attr.valid & NFS_ATTR_FATTR_TYPE) ||
>> -	    !(data->f_attr.valid & NFS_ATTR_FATTR_FILEID) ||
>> -	    !(data->f_attr.valid & NFS_ATTR_FATTR_CHANGE))
>> +	if (!cached_open &&
>> +	    (!(data->f_attr.valid & NFS_ATTR_FATTR_TYPE) ||
>> +	     !(data->f_attr.valid & NFS_ATTR_FATTR_FILEID) ||
>> +	     !(data->f_attr.valid & NFS_ATTR_FATTR_CHANGE)))
>> 		goto err;
>> 
>> 	ret = -ENOMEM;
>> @@ -1333,6 +1344,9 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
>> 	if (state == NULL)
>> 		goto err;
>> 
>> +	if (cached_open)
>> +		goto out;
>> +
>> 	ret = nfs_refresh_inode(inode, &data->f_attr);
>> 	if (ret)
>> 		goto err;
>> @@ -1344,6 +1358,7 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
>> 	update_open_stateid(state, &data->o_res.stateid, NULL,
>> 			    data->o_arg.fmode);
>> 
>> +out:
>> 	return state;
>> err:
>> 	return ERR_PTR(ret);
> 
> OK. Looking at what _nfs4_opendata_reclaim_to_nfs4_state is supposed to
> do, there appear to be several more problems.
> 
>     1. Why are we calling nfs4_get_open_state? We already have a value
>        for state, and all we want to do is to update it (and bump the
>        reference counter).
>     2. Why do we care about whether or not the GETATTR succeeded? We
>        just did an open by filehandle.
>     3. Don't we have a state reference leak when nfs_refresh_inode
>        fails?

Interesting questions, I'll need to look at this code path a bit more and get back to you.

-dros

> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

