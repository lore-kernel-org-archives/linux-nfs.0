Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 220C4C4332F
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Nov 2022 09:00:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232151AbiKOJAI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 15 Nov 2022 04:00:08 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33728 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229664AbiKOJAG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Nov 2022 04:00:06 -0500
Received: from bombadil.infradead.org (bombadil.infradead.org [IPv6:2607:7c80:54:3::133])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 2E96B6578;
        Tue, 15 Nov 2022 01:00:05 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=70wOmkh8d4B1DUWzEWWtU+Sq0btacFoBTBMqgMJC8io=; b=yvrwTcDiCDBJgYNS3lBRJ7DXFg
        VVRn+4llyz8lYutVgRn5B5OxpOzSPMLPJv+NsFspPYWH5YXBuxsm35zJBfnAcqmJDjcYfbU6YfbeW
        gG3BK5jRZoUqS2XPjoe685v980GhqtTJyjxyHKZfQnWymSQHSmvLW8LZmMHA6O9rl/o5067YnMv/k
        qkhqnh0ilVRrnlNNVMTDGOV9SFRnsU47Fl/MxctGT1LBU+2nyogJFLnwvk+boYhPZToRPfMn6bwqs
        hOpzLY0gtrkWKTwYk3O1h039MXcDdoAFdM8txOU7ZwempzMncipwbcvmMiScgbZRmLo3N5Df72Mu0
        AHvQcr+Q==;
Received: from hch by bombadil.infradead.org with local (Exim 4.94.2 #2 (Red Hat Linux))
        id 1ournX-0096RB-6x; Tue, 15 Nov 2022 09:00:03 +0000
Date:   Tue, 15 Nov 2022 01:00:03 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Jeff Layton <jlayton@kernel.org>
Cc:     chuck.lever@oracle.com, linux-fsdevel@vger.kernel.org,
        trond.myklebust@hammerspace.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] filelock: remove redundant filp arg from
 vfs_cancel_lock
Message-ID: <Y3NVE9pcvQXaIBi1@infradead.org>
References: <20221114150240.198648-1-jlayton@kernel.org>
 <20221114150240.198648-4-jlayton@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20221114150240.198648-4-jlayton@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Same nitpick once more :)

Otherwise:

Reviewed-by: Christoph Hellwig <hch@lst.de>
