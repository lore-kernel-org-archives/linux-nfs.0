Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08CDFC433EF
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Jul 2022 03:51:25 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234074AbiGSDvY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Jul 2022 23:51:24 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47034 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234591AbiGSDvX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jul 2022 23:51:23 -0400
Received: from bombadil.infradead.org (bombadil.infradead.org [IPv6:2607:7c80:54:3::133])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id E90D5205F2
        for <linux-nfs@vger.kernel.org>; Mon, 18 Jul 2022 20:51:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=AnAKQm9c1bhE8eKQOc22LDbcGLp39bywtQ6FYYfMQI0=; b=E6LnowBmtXINHeYw1P/30rHTRx
        QyHc4sDBRErOhoFmgM+8afkQVp2ThbhB1PhY8tHJWfRC8SFpFTcZ/F6W+LCzP+LPMcAoKPPnqd5H7
        eC+R9YXMW7IeErYn0+6TBs+wrvmM22pDl4RYkclgmDKNGGQW6m2iChI3bh8QkA+OiyFyULN8a452O
        AvhXChUCtCH75suXxXDLW6oaJHbHt2csz2XdTDk1RAISNULXhb+ENeVEgbNIIb2IRzclUsTfthKyd
        P1czsSeXooNjpNKG0p1rTSXHfVmwusuzH0ziunyTkHbnKt+ZMSmMQYrLR/8NPauydE70f7BYd0lSt
        sCET88SA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.94.2 #2 (Red Hat Linux))
        id 1oDeGT-004aB7-So; Tue, 19 Jul 2022 03:51:17 +0000
Date:   Mon, 18 Jul 2022 20:51:17 -0700
From:   Christoph Hellwig <hch@infradead.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Remove CONFIG_SUNRPC_GSS_MODULE
Message-ID: <YtYqNZCazm64S/Di@infradead.org>
References: <165815281251.8395.9611588593452344848.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <165815281251.8395.9611588593452344848.stgit@klimt.1015granger.net>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Jul 18, 2022 at 10:00:12AM -0400, Chuck Lever wrote:
> Clean up: I cannot find CONFIG_SUNRPC_GSS_MODULE anywhere.

CONFIG_SUNRPC_GSS_MODULE is set if SUNRPC_GSS is built as a module.
CONFIG_*_MODULE is Kconfig-generated magic.
