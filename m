Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F235BECDE46
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 21:26:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 990502085B
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 21:26:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="b91wp133"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 990502085B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727662AbeJ0GFK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 02:05:10 -0400
Received: from bombadil.infradead.org ([198.137.202.133]:52740 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726496AbeJ0GFK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 02:05:10 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=VQp6Ontqn+atHnWr6zl1DzCqY1Qkk+MFufSENmBS8ZQ=; b=b91wp133IyboH1hJ2kiujWRbG
        hOMIPF3iJQ837yO2bbToiUnYSh/oULtu2N5ZmQ2OioJjYDyEn5Mnr9RDuuKd/OfemhEzJ2pR2tsRE
        C7epiVsJpToHlg/wZ4PNyG5ySM06QtVobXlH1yubnzWFpGeBDOG4DfevTNa8gSlxZNx771a49iPyI
        +s2VYPkbgOue7puGH6y2exs0PGUTaiQvS0wzYXwClkdn0XrW6lbeelP+1v2iPiu4Kmf4Tp2wILDCO
        u8aJkAWnQFk62jyyQ9wexlCSMq0vSZL9Llwbs2xWsm8j6FYrBQsa9CSEBZqP1AGjPGX3Rjhj+x8by
        o97n+950w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gG9cl-00064W-8d; Fri, 26 Oct 2018 21:26:31 +0000
Date:   Fri, 26 Oct 2018 14:26:31 -0700
From:   Matthew Wilcox <willy@infradead.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: Re: [PATCH v4 02/11] VFS: copy_file_range check validity of input
 source offset
Message-ID: <20181026212631.GY25444@bombadil.infradead.org>
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
 <20181026201057.36899-4-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181026201057.36899-4-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 26, 2018 at 04:10:48PM -0400, Olga Kornievskaia wrote:
> +++ b/fs/read_write.c
> @@ -1594,6 +1594,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  		}
>  	}
>  
> +	if (pos_in >= i_size_read(inode_in))
> +		return -EINVAL;
> +
>  	if (file_out->f_op->copy_file_range) {
>  		ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
>  						      pos_out, len, flags);

Is this the right place to check this?  Surely we should be checking for
this before calling clone_file_range()?
