Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:47423 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752154Ab2FMN6K convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jun 2012 09:58:10 -0400
Received: by pbbrp8 with SMTP id rp8so2325527pbb.19
        for <linux-nfs@vger.kernel.org>; Wed, 13 Jun 2012 06:58:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FD1CEA8.3090105@panasas.com>
References: <4FD1CEA8.3090105@panasas.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Wed, 13 Jun 2012 21:57:49 +0800
Message-ID: <CA+a=Yy7cOTYjCSk2uN1WwXJc=1V-EOoiVxy2JYQaKQAftg7f_w@mail.gmail.com>
Subject: Re: [RFC 0/5] CRASHFIX: pnfs-obj: NONE-RPC LD must not call rpc_restart_call_prepare()
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        Benny Halevy <bhalevy@tonian.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 8, 2012 at 6:06 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>
> NONE-RPC layout-Drivers call nfs_writeback_done() as part
> of their completion of IO. (through pnfs_ld_write_done())
>
> Inside nfs_writeback_done() there is code that does:
>
>        else if (resp->count < argp->count) {
>                ...
>
>                /* This a short write! */
>                nfs_inc_stats(inode, NFSIOS_SHORTWRITE);
>
>                ... /* Prepare the remainder */
>
>                rpc_restart_call_prepare(task);
>        }
>
> But for none-rpc LDs (objects, blocks) there is no task->tk_ops
> and this code will crash.
>
> The same code exists in read.c::nfs_readpage_result_common() with
> same crash.
>
> Therefor: NONE-RPC LDs *must not* call pnfs_ld_read/write_done with
> partial/short IO. Either complete everything or fail everything and
> IO will be resubmitted through MDS.
>
> Below are a set of patches that fix this problem for objects
> layout, blocks maintainer should check that code does not allow a short
> IO as well.
>
> The Fix is much easier at the LD level then at NFS-Core. Though it
> could be fixed there, I do not think it is worth it. I will submit a
> comment that warns for this. Certainly NFS-Core changes could not
> be so simple as below to be candidates for @Stable
>
Thanks for reporting this. I didn't realize it in the first place either.

However, blocks read/write is implemented to fail any short IO and set
pnfs_error to resend it through mds, except for the case of reading
beyond eof. So I don't think blocks will crash the same case. I will
double check with more tests though.

Cheers,
Tao

> These where lightly tested and are submitted for review. I will conduct
> heavy testing and will put them in linux-next only next week.
>
> Here are the list of patches:
>
> [PATCH 1/6] ore: Fix NFS crash by supporting any unaligned RAID IO
> [PATCH 2/6] ore: Remove support of partial IO request (NFS crash)
> [PATCH 3/6] pnfs-obj: Fix __r4w_get_page in the case of offset beyond i_size
>
>        These 3 completely plug the crash above, and are destined
>        for Stable@
>
>        Trond please ACK the 3rd patch since I want to push this
>        through my tree, as these are for ore mostly.
>        (Please also review all of them, watch my back)
>
> [PATCH 4/6] pnfs-obj: don't leak objio_state if ore_write/read fails.
>
>        A memory leak found on the way, in the error case.
>        Should it be for Stable@ ?
>
> [PATCH 4/5] NFS41: add pg_layout_private to nfs_pageio_descriptor
>
>        This is the patch by Peng Tao <bergwolf@gmail.com> which is
>        needed for below fix. Minus the has_moreio flag.
>
> [PATCH 5/5] pnfs-obj: Better IO pattern in case of unaligned offset
>
>        Though this patch is an optimization it fixes a very bad
>        IO pattern. Please consider for the 3.5-rcX Kernel and
>        don't postpone to 3.6 Merge window. If possible
>
> Thanks for any review
> Boaz



-- 
Thanks,
Tao
