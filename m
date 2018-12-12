Return-Path: <SRS0=XDbB=OV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03BD1C04EB8
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 07:18:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A6C2320851
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 07:18:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="eVGRm5id"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6C2320851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726317AbeLLHSZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 02:18:25 -0500
Received: from bombadil.infradead.org ([198.137.202.133]:41760 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726242AbeLLHSY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2018 02:18:24 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=aZIv/kMoUV/ID7aeKeeDi9NchfyvaAjSlTGCRNzYU3o=; b=eVGRm5id6Fqwyht+bvlojuc78
        RvE0ECQZwuIv5Ya9Q/AeMoclE2yZzayMWt0iFCzAmWcDj1Df8k/LKqNrr29m5w7qOCZFS0QECpyBP
        wmC5CFCzBFLQPBP1Cu4MoJ2PtToLYs3tAAf4MW2JS3gZORYqzd4qSJumlgDEpJrYnr2lTz/Y5xakD
        Dnb900lv0KuWY2l4W9/esEd17JcCwDFEQFPB0qG9KmL4UuG+uKLXC7cVw9nyzhg+4tzh+RJAqTk/V
        KFpEBcMm8ar4C2/GloCS1uTO7bqSNx4o6umefFTtmb+7QO2BDCZQuDxD56PUocYVNrfahStwRV2P8
        IvYDEGt9Q==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gWyml-0006OT-Ke; Wed, 12 Dec 2018 07:18:23 +0000
Date:   Tue, 11 Dec 2018 23:18:23 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 03/24] xprtrdma: Remove support for FMR memory
 registration
Message-ID: <20181212071823.GA23247@infradead.org>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
 <20181210162934.4198.90529.stgit@manet.1015granger.net>
 <20181211140208.GB30471@infradead.org>
 <F6E2B610-D386-45AC-B93B-906B61E22542@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F6E2B610-D386-45AC-B93B-906B61E22542@oracle.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Dec 11, 2018 at 10:29:10AM -0500, Chuck Lever wrote:
> 
> 
> > On Dec 11, 2018, at 9:02 AM, Christoph Hellwig <hch@infradead.org> wrote:
> > 
> > Can we also kill off rpcrdma_memreg_ops now?  Indirect calls are
> > suprisingly expensive, especially in our post-spectre world, and
> > xprtrdma always seemed a little odd with this supper generic
> > abstraction.
> 
> Yep, I'm considering replacing those indirect calls.
> 
> However, note that the RPC layer is full of them too, as is the
> DMA operations that are used by xprtrdma. I'm not sure it will make
> much of a difference.

I've posted a series to remove them for the DMA fast path, and every
indirect calls adds additional cost.
