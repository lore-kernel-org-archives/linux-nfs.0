Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B7BAC04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 18:53:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EA1BE208A3
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 18:53:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="gsgifdt/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA1BE208A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726042AbeLCSxK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 13:53:10 -0500
Received: from mail.kernel.org ([198.145.29.99]:60894 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725973AbeLCSxK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Dec 2018 13:53:10 -0500
Received: from gmail.com (unknown [104.132.1.85])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id E0B6720850;
        Mon,  3 Dec 2018 18:53:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1543863188;
        bh=qTtQoEAQMnRL2UxwLwNdoeClO9iiUNdc2TRBaQckeho=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=gsgifdt//G9ifsf4XKK2cGPMku3OsSypJU6QVfcOWV40ui6pRX5sS7JDp2MHSS5cM
         519xZl+vQMMB+nPeORpDI9rHR5QrHEDTbrM1eYZEDBCOlogxCHarVSAMQ1GtGgwDAx
         2Us507pJBgbAtIeFZJW7gs6ywwO0M8ys5ka/RDJc=
Date:   Mon, 3 Dec 2018 10:53:06 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     Dave Chinner <david@fromorbit.com>
Cc:     linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
        olga.kornievskaia@gmail.com, linux-nfs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: [PATCH 05/11] vfs: use inode_permission in copy_file_range()
Message-ID: <20181203185305.GA32539@gmail.com>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-6-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203083416.28978-6-david@fromorbit.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 03, 2018 at 07:34:10PM +1100, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Similar to FI_DEDUPERANGE, make copy_file_range() check that we have
> write permissions to the destination inode.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  mm/filemap.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 0a170425935b..876df5275514 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -3013,6 +3013,11 @@ int generic_copy_file_checks(struct file *file_in, loff_t pos_in,
>  	    (file_out->f_flags & O_APPEND))
>  		return -EBADF;
>  
> +	/* may sure we really are allowed to write to the destination inode */
> +	ret = inode_permission(inode_out, MAY_WRITE);
> +	if (ret < 0)
> +		return ret;
> +
>  	/* Ensure offsets don't wrap. */
>  	if (pos_in + count < pos_in || pos_out + count < pos_out)
>  		return -EOVERFLOW;
> -- 
> 2.19.1
> 

Why?  The file descriptor was already checked for write permission above:

       if (!(file_in->f_mode & FMODE_READ) ||
            !(file_out->f_mode & FMODE_WRITE) ||
            (file_out->f_flags & O_APPEND))
                return -EBADF;

Yes, that doesn't detect removing write permission from the *inode*, but write()
doesn't either.

- Eric
