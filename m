Return-Path: <SRS0=aRlV=NH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48A6DC46475
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Oct 2018 13:23:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E697120828
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Oct 2018 13:23:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qboySBrY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E697120828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728576AbeJ0WEq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 18:04:46 -0400
Received: from bombadil.infradead.org ([198.137.202.133]:48518 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728320AbeJ0WEq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 18:04:46 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=8ahizoSDIQuEqUoKaCICOj6n7evKYCMP/g+23S5bwyY=; b=qboySBrYB4SHdt5EU7AIsstkb
        aG0RwbS7QIj7vfeTNzHvJmu/VZ+hDHw6XeKels9ve3EUHTE9SHIEP0yU8V+FYBxf4ErrHJY0NWbWZ
        7z7yTRvrPRW2zgdtNo3vkfZ40WtIJBTxAkPE9SpzngzcOQwPiseT16PTo5j5u/ZLzLdyjulTzdTjV
        rlPUcQCJJgb9R3a8gjJxP6i8W9BmTn1inTLDkiAFhJpZ1l2hJrxp2Lz/cIz4Tzjy1fjMkZGledWvs
        4FakimVWcEGYb5AMxiWu/L42j8YrfF7B8cizX0KwFPq0pB9dGK0J1STB4Gk+OyXdl+XnOLlVXugSh
        LFpxa6C8A==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gGOZ1-0004SF-FP; Sat, 27 Oct 2018 13:23:39 +0000
Date:   Sat, 27 Oct 2018 06:23:39 -0700
From:   Matthew Wilcox <willy@infradead.org>
To:     Dave Chinner <david@fromorbit.com>
Cc:     Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: Re: [PATCH 1/1] man-page: copy_file_range(2) allow for cross-device
 copies
Message-ID: <20181027132339.GZ25444@bombadil.infradead.org>
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
 <20181026201057.36899-3-olga.kornievskaia@gmail.com>
 <20181027091240.GK6311@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181027091240.GK6311@dastard>
User-Agent: Mutt/1.9.2 (2017-12-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Oct 27, 2018 at 08:12:40PM +1100, Dave Chinner wrote:
> > @@ -131,7 +132,8 @@ There is not enough space on the target filesystem to complete the copy.
> >  .B EXDEV
> >  The files referred to by
> >  .IR file_in " and " file_out
> > -are not on the same mounted filesystem.
> > +are not on the same mounted filesystem when the kernel does not support
> > +cross device file copy.
> 
> Kernel can support cross device file copy, the filesystem may not.
> 
> EXDEV
> 	One of the files specified by file_in and file_out are on a
> 	filesystem that does not support cross device copies.

I mentioned this in my last review, and Olga pointed out that one of
the changes in this patch means the kernel will do the copy using
do_splice_direct if the filesystem doesn't support cross-device copying.
We should keep this error documented for those on old kernels, but the
kernel will never return -EXDEV any more.
