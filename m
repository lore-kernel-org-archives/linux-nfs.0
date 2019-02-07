Return-Path: <SRS0=BC+Y=QO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01A47C282C2
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Feb 2019 13:37:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C99F3206DD
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Feb 2019 13:37:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727080AbfBGNhR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Feb 2019 08:37:17 -0500
Received: from mx1.redhat.com ([209.132.183.28]:44910 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727061AbfBGNhR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 Feb 2019 08:37:17 -0500
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 24C8489ADA;
        Thu,  7 Feb 2019 13:37:16 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-112-2.rdu2.redhat.com [10.10.112.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 069D0104811A;
        Thu,  7 Feb 2019 13:37:13 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Kazuo Ito" <ito_kazuo_g3@lab.ntt.co.jp>
Cc:     "Trond Myklebust" <trond.myklebust@hammerspace.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org,
        "Ryusuke Konishi" <konishi.ryusuke@lab.ntt.co.jp>,
        watanabe.hiroyuki@lab.ntt.co.jp
Subject: Re: [PATCH] pNFS: Avoid read-modify-write for page-aligned full page
 write
Date:   Thu, 07 Feb 2019 08:37:12 -0500
Message-ID: <5905EB17-75B9-494A-B608-F135D6330F49@redhat.com>
In-Reply-To: <37261782-eebb-b9c5-a480-7ced59b3703f@lab.ntt.co.jp>
References: <37261782-eebb-b9c5-a480-7ced59b3703f@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 07 Feb 2019 13:37:16 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 7 Feb 2019, at 3:12, Kazuo Ito wrote:

> As the block and SCSI layouts can only read/write fixed-length
> blocks, we must perform read-modify-write when data to be written is
> not aligned to a block boundary or smaller than the block size.
> (612aa983a0410 pnfs: add flag to force read-modify-write in 
> ->write_begin)
>
> The current code tries to see if we have to do read-modify-write
> on block-oriented pNFS layouts by just checking !PageUptodate(page),
> but the same condition also applies for overwriting of any uncached
> potions of existing files, making such operations excessively slow
> even if it is block-aligned.
>
> The change does not affect the optimization for modify-write-read
> cases (38c73044f5f4d NFS: read-modify-write page updating),
> because partial update of !PageUptodate() pages can only happen
> in layouts that can do arbitrary length read/write and never
> in block-based ones.
>
> Testing results:
>
> We ran fio on one of the pNFS clients running 4.20 kernel
> (vanilla and patched) in this configuration to read/write/overwrite
> files on the storage array, exported as pnfs share by the server.
>
>  pNFS clients ---1G Ethernet--- pNFS server
>  (HP DL360 G8)                  (HP DL360 G8)
>        |                              |
>        |                              |
>        +------8G Fiber Channel--------+
>                      |
>                Storage Array
>                  (HP P6350)
>
> Throughput of overwrite (both buffered and O_SYNC) is noticeably
> improved.
>
> Ops.     |block size|   Throughput   |
>          |  (KiB)   |    (MiB/s)     |
>          |          |  4.20 | patched|
> ---------+----------+----------------+
> buffered |         4|  21.3 |  233   |
> overwrite|        32|  22.2 |  254   |
>          |       512|  22.4 |  258   |
> ---------+----------+----------------+
> O_SYNC   |         4|   3.84|    4.68|
> overwrite|        32|  12.2 |   32.9 |
>          |       512|  18.5 |  151   |
> ---------+----------+----------------+
>
> Read and write (buffered and O_SYNC) by the same client remain 
> unchanged
> by the patch either negatively or positively, as they should do.
>
> Ops.     |block size|   Throughput   |
>          |  (KiB)   |    (MiB/s)     |
>          |          |  4.20 | patched|
> ---------+----------+----------------+
> read     |         4| 548   |  551   |
>          |        32| 547   |  552   |
>          |       512| 548   |  549   |
> ---------+----------+----------------+
> buffered |         4| 237   |  243   |
> write    |        32| 261   |  267   |
>          |       512| 265   |  271   |
> ---------+----------+----------------+
> O_SYNC   |         4|   0.46|    0.46|
> write    |        32|   3.60|    3.61|
>          |       512| 105   |  108   |
> ---------+----------+----------------+
>
> Signed-off-by: Kazuo Ito <ito_kazuo_g3@lab.ntt.co.jp>
> Tested-by: Hiroyuki Watabane <watanabe.hiroyuki@lab.ntt.co.jp>
>
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 29553fdba8af..e80954c96ec1 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -276,6 +276,12 @@ EXPORT_SYMBOL_GPL(nfs_file_fsync);
>   * then a modify/write/read cycle when writing to a page in the
>   * page cache.
>   *
> + * Some pNFS layout drivers can only read/write at a certain block
> + * granularity like all block devices and therefore we must perform
> + * read/modify/write whenever a page hasn't read yet and the data
> + * to be written there is not aligned to a block boundary and/or
> + * smaller than the block size.
> + *
>   * The modify/write/read cycle may occur if a page is read before
>   * being completely filled by the writer.  In this situation, the
>   * page must be completely written to stable storage on the server
> @@ -299,8 +305,10 @@ static int nfs_want_read_modify_write(struct file 
> *file, struct page *page,
>  	unsigned int end = offset + len;
>
>  	if (pnfs_ld_read_whole_page(file->f_mapping->host)) {
> -		if (!PageUptodate(page))
> -			return 1;
> +		if (!PageUptodate(page)) {
> +			if (pglen && (end < pglen || offset))
> +				return 1;
> +		}
>  		return 0;
>  	}

This looks right.  I think that a static inline bool 
nfs_write_covers_page,
or full_page_write or similar might make sense here, as we do the same 
test
just below, and would make the code easier to quickly understand.

Reviewed-by: Benjamin Coddington <bcodding@redhat.com>

Ben
