Return-Path: <SRS0=XA/Y=QT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10823C282C4
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 18:52:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DA8C0222BE
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 18:52:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728460AbfBLSwj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Feb 2019 13:52:39 -0500
Received: from mx1.redhat.com ([209.132.183.28]:34922 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727348AbfBLSwj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Feb 2019 13:52:39 -0500
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 181BAC070474;
        Tue, 12 Feb 2019 18:52:39 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-112-2.rdu2.redhat.com [10.10.112.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 0E4C85D9D1;
        Tue, 12 Feb 2019 18:52:37 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] NFS: Don't use page_file_mapping after removing the
 page
Date:   Tue, 12 Feb 2019 13:52:36 -0500
Message-ID: <D1443158-8840-4D21-8215-68B96138F45C@redhat.com>
In-Reply-To: <5eb439e690e72e3a69ad0a5bb48827c7e5ce32a8.1549451324.git.bcodding@redhat.com>
References: <5eb439e690e72e3a69ad0a5bb48827c7e5ce32a8.1549451324.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 12 Feb 2019 18:52:39 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond and Anna,

I want to bump this.  The problem we created is easier to hit now than 
the problem we were fixing, so something should be done for 5.0 if 
possible.

Ben

On 6 Feb 2019, at 6:09, Benjamin Coddington wrote:

> If nfs_page_async_flush() removes the page from the mapping, then we 
> can't
> use page_file_mapping() on it as nfs_updatepate() is wont to do when
> receiving an error.  Instead, push the mapping to the stack before the 
> page
> is possibly truncated.
>
> Fixes: 8fc75bed96bb ("NFS: Fix up return value on fatal errors in 
> nfs_page_async_flush()")
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/write.c | 11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
>
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index f12cb31a41e5..d09c9f878141 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -238,9 +238,9 @@ static void nfs_grow_file(struct page *page, 
> unsigned int offset, unsigned int c
>  }
>
>  /* A writeback failed: mark the page as bad, and invalidate the page 
> cache */
> -static void nfs_set_pageerror(struct page *page)
> +static void nfs_set_pageerror(struct address_space *mapping)
>  {
> -	nfs_zap_mapping(page_file_mapping(page)->host, 
> page_file_mapping(page));
> +	nfs_zap_mapping(mapping->host, mapping);
>  }
>
>  /*
> @@ -994,7 +994,7 @@ static void nfs_write_completion(struct 
> nfs_pgio_header *hdr)
>  		nfs_list_remove_request(req);
>  		if (test_bit(NFS_IOHDR_ERROR, &hdr->flags) &&
>  		    (hdr->good_bytes < bytes)) {
> -			nfs_set_pageerror(req->wb_page);
> +			nfs_set_pageerror(page_file_mapping(req->wb_page));
>  			nfs_context_set_write_error(req->wb_context, hdr->error);
>  			goto remove_req;
>  		}
> @@ -1348,7 +1348,8 @@ int nfs_updatepage(struct file *file, struct 
> page *page,
>  		unsigned int offset, unsigned int count)
>  {
>  	struct nfs_open_context *ctx = nfs_file_open_context(file);
> -	struct inode	*inode = page_file_mapping(page)->host;
> +	struct address_space *mapping = page_file_mapping(page);
> +	struct inode	*inode = mapping->host;
>  	int		status = 0;
>
>  	nfs_inc_stats(inode, NFSIOS_VFSUPDATEPAGE);
> @@ -1366,7 +1367,7 @@ int nfs_updatepage(struct file *file, struct 
> page *page,
>
>  	status = nfs_writepage_setup(ctx, page, offset, count);
>  	if (status < 0)
> -		nfs_set_pageerror(page);
> +		nfs_set_pageerror(mapping);
>  	else
>  		__set_page_dirty_nobuffers(page);
>  out:
> -- 
> 2.14.3
