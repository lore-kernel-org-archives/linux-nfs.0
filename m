Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78B3BC43334
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Jul 2022 14:42:31 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S239491AbiGSOma (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Jul 2022 10:42:30 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33114 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S239538AbiGSOmR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Jul 2022 10:42:17 -0400
Received: from bombadil.infradead.org (bombadil.infradead.org [IPv6:2607:7c80:54:3::133])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id F07892180
        for <linux-nfs@vger.kernel.org>; Tue, 19 Jul 2022 07:39:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=Az1tGMt7MF/bEwnhE54p42aeB7IPQXUSjVKzawi4SKE=; b=Fa2vIsBtwm2e60JLGwhLGuiDti
        dZVgb5DlsKTicdyeOqcoxUJBaekJS7G3gSTybOCpmAgmTFZ3vrRoH8lg/YLpdUOz+UKpmpnzdQWVM
        PXNxBqBszOf5BOLXXxoZ2FuPshnShvrB2mpt0e1f7ttqQ0cmAVn7DIKfBkSSwFKfKuJ1tNVVz3IcM
        Y4p48AZAkmY+DZ+COYYr4oTwwYx7UABNH5+/ZfgvXNqPTrOXIzd8UHqXfUdfcI40h6yUoYh61Q7vH
        peZr0GurTcG1mepjJOY/BUlOa0/1dSNlSYPqOyuc5GnGg+r9tVdPqp7NGD4QRZs8290Z1C5ZYzOfx
        e1F5urnw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.94.2 #2 (Red Hat Linux))
        id 1oDoNe-009jsd-Kd; Tue, 19 Jul 2022 14:39:22 +0000
Date:   Tue, 19 Jul 2022 07:39:22 -0700
From:   Christoph Hellwig <hch@infradead.org>
To:     Chuck Lever III <chuck.lever@oracle.com>
Cc:     Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Remove CONFIG_SUNRPC_GSS_MODULE
Message-ID: <YtbCGoJ7+ynzqqHX@infradead.org>
References: <165815281251.8395.9611588593452344848.stgit@klimt.1015granger.net>
 <YtYqNZCazm64S/Di@infradead.org>
 <4936C3D6-AE4B-4F7F-89D1-17CBF38A5CD5@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4936C3D6-AE4B-4F7F-89D1-17CBF38A5CD5@oracle.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Jul 19, 2022 at 01:27:51PM +0000, Chuck Lever III wrote:
> > CONFIG_SUNRPC_GSS_MODULE is set if SUNRPC_GSS is built as a module.
> > CONFIG_*_MODULE is Kconfig-generated magic.
> 
> I can drop this patch, but I still have questions (and I know you are
> just the messenger, you might not know the answers).
> 
> Where is this convention documented?
> 
> When would CONFIG_SUNRPC_GSS_MODULE be defined but CONFIG_SUNRPC_GSS isn't?

If .config has CONFIG_SUNRPC_GSS=y, CONFIG_SUNRPC_GSS is set, but
CONFIG_SUNRPC_GSS_MODULE is not.

If .config has CONFIG_SUNRPC_GSS=m, CONFIG_SUNRPC_GSS_MODULE is set,
but CONFIG_SUNRPC_GSS is not.

As Anna said these days we have the IS_ENABLED helper to mostly hide
this.

I have no idea if this is documented anywhere.
