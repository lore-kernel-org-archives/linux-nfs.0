Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8111DC43219
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Jan 2021 17:56:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5DE4323B19
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Jan 2021 17:56:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729191AbhAVRuw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Jan 2021 12:50:52 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:34112 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729572AbhAVR2K (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jan 2021 12:28:10 -0500
Received: from casper.infradead.org (casper.infradead.org [IPv6:2001:8b0:10b:1236::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id DE192C061788;
        Fri, 22 Jan 2021 09:27:29 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
        References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=vAJdIdPf3yEtzmSe6B+0eCjFw8FraS3Umh4zIgDybO8=; b=nxeakDgI0eTo4KH3ZYtmn/AYjg
        ErptlKXAqRBFGaJDTXvmPIJJMOP5Eytq3Ej82Ke04vOrVHjiK1jgFHJnPN3ySVfMCBAdPFML/DDF9
        OZ0EkkQ8VlfNj2M3KTeIRwxHJM5y3IxIXpcAPDKcvNCeZIoLWbFCak228RFttZeqsgjnvzwTVeoWH
        ySUPvsgPpO66Woj74fNvO/qWxDE1FY2TcAiLqfVfIwTX/HQ+ntvvL7T6qRVJuTxLxkQT4gDewCt2W
        1iAVhUeeWSkU9rAT/h6wlygGscp4IRkKIEgA2zMgKvp6g+DDB0MtQulQ37Y5TKxjCMvYDwwan8aW6
        vXCs9q6g==;
Received: from hch by casper.infradead.org with local (Exim 4.94 #2 (Red Hat Linux))
        id 1l30Ct-00112k-VX; Fri, 22 Jan 2021 17:26:54 +0000
Date:   Fri, 22 Jan 2021 17:26:47 +0000
From:   Christoph Hellwig <hch@infradead.org>
To:     Tom Talpey <tom@talpey.com>
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH v1 2/2] svcrdma: DMA-sync the receive buffer in
 svc_rdma_recvfrom()
Message-ID: <20210122172647.GA241302@infradead.org>
References: <161126216710.8979.7145432546367265892.stgit@klimt.1015granger.net>
 <161126239239.8979.7995314438640511469.stgit@klimt.1015granger.net>
 <75a4edc8-791c-b98e-b943-0ebff8aa4b16@talpey.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <75a4edc8-791c-b98e-b943-0ebff8aa4b16@talpey.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by casper.infradead.org. See http://www.infradead.org/rpr.html
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Jan 22, 2021 at 09:37:02AM -0500, Tom Talpey wrote:
> Is there an asynchronous version of ib_dma_sync?

No.  These routines basically compile down to cache writeback and/or
invalidate instructions without much logic around them.
