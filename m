Return-Path: <SRS0=WZcR=NL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59D8AC0044C
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 16:54:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2968220830
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 16:54:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2968220830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729885AbeKABxU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 21:53:20 -0400
Received: from fieldses.org ([173.255.197.46]:54774 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729813AbeKABxU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 Oct 2018 21:53:20 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id A22AF3F3; Wed, 31 Oct 2018 12:54:30 -0400 (EDT)
Date:   Wed, 31 Oct 2018 12:54:30 -0400
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 01/13] fs: Don't copy beyond the end of the file
Message-ID: <20181031165430.GA3377@fieldses.org>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-2-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181019152905.32418-2-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 19, 2018 at 11:28:53AM -0400, Olga Kornievskaia wrote:
> From: Anna Schumaker <Anna.Schumaker@Netapp.com>

I have some idea we've had some discussion about this before, but if so
I've forgotten the conclusion.  Could we have more of a changelog?:

	- isn't there a race condition, or is there something preventing
	  the file size from changing here?
	- why are we doing this?  Does this change the behavior of
	  copy_file_range()?

--b.

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
> -- 
> 1.8.3.1
