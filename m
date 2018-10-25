Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04B6CC46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 22:17:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A48162083E
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 22:17:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="YGmaixkX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A48162083E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726787AbeJZGwY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 02:52:24 -0400
Received: from bombadil.infradead.org ([198.137.202.133]:59052 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726348AbeJZGwY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 02:52:24 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=BY/U/Md3dxJ9Vx0wF30vR1qdKP/gEq7DP5FkhrNFJxU=; b=YGmaixkXqvJ+6zr5+Og+3R0+2
        HFYmd/mWuzxTf48sznCAkRgx9gz8lTfohVJ4Lv60CO1IsamJRkbN70swhFCQ2XkbURhuxb0oKDJRR
        8B8/OAoAj64m6P3wgR7eCaMNFOFEK31f4SuXQdx9AVSFf6Lcd9GNfd2iZ1fdzXZAIcWjhM1oe0GfP
        XaQjfCu45vU8z2KA1FKjHqk13IeCz4OwkcwFdCO8t4cdVSI8jLNoaQmi+coNo9tA6ROVV1+mDb1vJ
        0VsNbhec47jaVfJlSwZdcCRtWUSBn0MNhgK8D5MDYu+4Ge8AZdgRrDRoqGAK6vi2anEp5jnF8WAZy
        Gp8NScrhA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gFnwu-0001KC-JH; Thu, 25 Oct 2018 22:17:52 +0000
Date:   Thu, 25 Oct 2018 15:17:52 -0700
From:   Matthew Wilcox <willy@infradead.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: Re: [PATCH v3 01/11] VFS move cross device copy_file_range() check
 into filesystems
Message-ID: <20181025221752.GM25444@bombadil.infradead.org>
References: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
 <20181025215147.36248-2-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181025215147.36248-2-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Oct 25, 2018 at 05:51:36PM -0400, Olga Kornievskaia wrote:
> +--
> +[mandatory]
> +	->copy_file_range() may now be passed files which belong to two
> +	different superblocks of the same file system type or which belong
> +	to two different filesystems types all together. As before, the
> +        destination's copy_file_range() is the function which is called.
> +	If it cannot copy ranges from the source, it should return -EXDEV.

Something weird happened to the indentation here?

> +++ b/Documentation/filesystems/vfs.txt
> @@ -1,5 +1,6 @@
>  
>  	      Overview of the Linux Virtual File System
> +- [fs] nfs: Don't let readdirplus revalidate an inode that was marked as stale (Benjamin Coddington) [1429514 1416532]
>  
>  	Original author: Richard Gooch <rgooch@atnf.csiro.au>
>  

This stray change slipped in.

> @@ -958,7 +959,10 @@ otherwise noted.
>  
>    fallocate: called by the VFS to preallocate blocks or punch a hole.
>  
> -  copy_file_range: called by the copy_file_range(2) system call.
> +  copy_file_range: called by copy_file_range(2) system call. This method
> +		   works on two file descriptors that might reside on
> +		   different superblocks which might belong to file systems
> +		   of different types.

I don't think you need this change at all.

The actual code looks good.
