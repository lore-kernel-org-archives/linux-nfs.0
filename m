Return-Path: <SRS0=BUwe=NB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B9F1ECDE43
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 14:29:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 026AA20869
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 14:29:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="inrbdeYH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 026AA20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727771AbeJUWno (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 21 Oct 2018 18:43:44 -0400
Received: from mail.kernel.org ([198.145.29.99]:50776 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727266AbeJUWno (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 21 Oct 2018 18:43:44 -0400
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id EE6812083E;
        Sun, 21 Oct 2018 14:29:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1540132152;
        bh=De7qwRsOQMzN/kMaIR/7qJ79FiRsni1Ch/gdwVrlZ5c=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=inrbdeYHCNm1834RLGnfoLkQzsiYOdOznkvQg03cAB4+TUGuwwNKTWV3CDD8h7uNw
         HzXJVfqQ5cGgrE/wQeXze008CqHz90KMJrsmlxqwVwHPoHYpR2/M4wG2qmC/zi9M9J
         Ces5GxInPww4AWxoeaMe5+XXpgPlzl8rWNNd9gmM=
Message-ID: <fc9619bee3e27d6756ecff9ae143c646d2567b62.camel@kernel.org>
Subject: Re: [PATCH v1 01/11] fs: Don't copy beyond the end of the file
From:   Jeff Layton <jlayton@kernel.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        trondmy@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Date:   Sun, 21 Oct 2018 10:29:10 -0400
In-Reply-To: <20181019152932.32462-2-olga.kornievskaia@gmail.com>
References: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
         <20181019152932.32462-2-olga.kornievskaia@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2018-10-19 at 11:29 -0400, Olga Kornievskaia wrote:
> From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> ---
>  fs/read_write.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 39b4a21..c60790f 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1570,6 +1570,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  	if (unlikely(ret))
>  		return ret;
>  
> +	if (pos_in >= i_size_read(inode_in))
> +		return -EINVAL;
> +
>  	if (!(file_in->f_mode & FMODE_READ) ||
>  	    !(file_out->f_mode & FMODE_WRITE) ||
>  	    (file_out->f_flags & O_APPEND))

The patch description could use a bit more fleshing-out. The
copy_file_range manpage says:

       EINVAL Requested range extends beyond the end of the source file; or the flags argument is not 0.

So I guess this is intended to satisfy that requirement? If so,
i_size_read is just going to return whatever is in inode->isize. 

Could a copy_file_range call end up getting issued to copy from a file
that is already open on a range that it doesn't know about yet? i.e.
where the inode cache has not yet been updated.

It seems like that could on network filesystems (like NFS). Would this
be better handled in ->copy_file_range instead, where the driver could
make a better determination of the file size?
-- 
Jeff Layton <jlayton@kernel.org>

