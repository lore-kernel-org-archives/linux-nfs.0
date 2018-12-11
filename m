Return-Path: <SRS0=OjhL=OU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12ED7C07E85
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 14:02:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C94602084A
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 14:02:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="D7PMndIO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C94602084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726454AbeLKOCL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 11 Dec 2018 09:02:11 -0500
Received: from bombadil.infradead.org ([198.137.202.133]:35778 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726350AbeLKOCK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2018 09:02:10 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=uyTi6/3U5lfuUl+rBMOCJh40kAn4z4JqTwzTW23qkZ8=; b=D7PMndIO+CTSNUeKbFj2qNBvS
        p8GQvYaqemXXS6zvSPBZSa6GAImHa9p4vE8exgsfa9nwdC8l6WiBE7tUOtcGQBAx9NGs6ubdIvbX3
        4s445yzJP6tSoebhRGwe2LKJuQeUew9sVsLvwtRBSiVNKg3iqiXJE7iOJ9cMgo1KlVnmBz9ov4kka
        +95Bo4On7MxlfT18X7D6gxlCKgzWU8b2gqTlypnD7/imeXodKy8AgoE9hAWQO5esJ839X5X/OMYEE
        BUqWEqFXalE1qyLYtNOrx5EwZBueSZSxE+gBa724CuYuOA9uaOt0P320nBjQ5PXhTUJ8AcbE+B+B+
        O9AvOAX6Q==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gWibw-0001LO-OO; Tue, 11 Dec 2018 14:02:08 +0000
Date:   Tue, 11 Dec 2018 06:02:08 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     anna.schumaker@netapp.com, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 03/24] xprtrdma: Remove support for FMR memory
 registration
Message-ID: <20181211140208.GB30471@infradead.org>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
 <20181210162934.4198.90529.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181210162934.4198.90529.stgit@manet.1015granger.net>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Can we also kill off rpcrdma_memreg_ops now?  Indirect calls are
suprisingly expensive, especially in our post-spectre world, and
xprtrdma always seemed a little odd with this supper generic
abstraction.
