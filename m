Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:38306 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932536Ab2GLOLw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jul 2012 10:11:52 -0400
Message-ID: <4FFEDB17.5050001@panasas.com>
Date: Thu, 12 Jul 2012 17:11:35 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
CC: Benny Halevy <bhalevy@tonian.com>, Peng Tao <bergwolf@gmail.com>
Subject: Re: [RFC 0/5] CRASHFIX: pnfs-obj: NONE-RPC LD must not call rpc_restart_call_prepare()
References: <4FD1CEA8.3090105@panasas.com>
In-Reply-To: <4FD1CEA8.3090105@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/08/2012 01:06 PM, Boaz Harrosh wrote:

> 
> NONE-RPC layout-Drivers call nfs_writeback_done() as part
> of their completion of IO. (through pnfs_ld_write_done())
> 
> Inside nfs_writeback_done() there is code that does:
> 
> 	else if (resp->count < argp->count) {
> 		...
> 
> 		/* This a short write! */
> 		nfs_inc_stats(inode, NFSIOS_SHORTWRITE);
> 
> 		... /* Prepare the remainder */
> 
> 		rpc_restart_call_prepare(task);
> 	}
> 
> But for none-rpc LDs (objects, blocks) there is no task->tk_ops
> and this code will crash.
> 

<snip>

Trond hi

Sorry for the late response I was sick (at Hospital and was away)

I must push these fixes to Linus ASAP I want to push them tomorrow.
They are for 3.5-rc7 and CC to stable@.

I would love to also push the objlayout patches as one push as well.
Please give me your blessing and ACK so I can do this.

I have done a small rebase over 3.5-rc5 and a few cleanups mainly
Peng's comment about ZERO_PAGE.

You can see the pending push request here:
http://git.open-osd.org/gitweb.cgi?p=linux-open-osd.git;a=shortlog;h=refs/heads/for-linus

These are the list of patches:

ore: Fix NFS crash by supporting any unaligned RAID IO
ore: Remove support of partial IO request (NFS crash)
ore: Unlock r4w pages in exact reverse order of locking

	These above are ORE patches that actually fix the NFS CRASH

pnfs-obj: don't leak objio_state if ore_write/read ...

	This above is an important mem leak in the error case

pnfs-obj: Fix __r4w_get_page when offset is beyond ...
NFS41: add pg_layout_private to nfs_pageio_descriptor
pnfs-obj: Better IO pattern in case of unaligned offset  for-linus

	I would also love to push these 3 please advise

Please look into this ASAP, as we are so late already because of my
absence. If you'll inspect them carefully you will see that other then
the fix they are low risk. And I have tested them extensively.

(I pushed it to linux-next and will let it cook for 48 hours)

Thanks for your help
Boaz
