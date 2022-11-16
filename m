Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65CFAC4332F
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Nov 2022 16:09:46 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233988AbiKPQJm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 16 Nov 2022 11:09:42 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48274 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234075AbiKPQJa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Nov 2022 11:09:30 -0500
Received: from bombadil.infradead.org (bombadil.infradead.org [IPv6:2607:7c80:54:3::133])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id F1D112AE7;
        Wed, 16 Nov 2022 08:09:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=; b=rhp+5uxA93KTOaibmx/wyCIC+j
        /gKpMdoIXmAdmLJjncabkrA2O3hTR0luJoUN9quk5uHe6+P3j8faj5xgb1P+iX/wA+FsM5ikZSG6K
        0PGCwTkJDzlxoPNbPxJRWZxjOLJeGs9rFWB6vuaxQUINaSlCpLHk3ROp2Kjw5n7A8O6wAC6mIXDBl
        LabBhEd4RsPO5hG8UJBGYJyK/yOBDoqfyNh2aF2uEkorGeYcM/B6BlGWYauQYL985CQaViVxgt3Wm
        JJ1opfaTqp/JeQgON2v9BZfXBQTUuJDHCxdDFoDTHonAUMf+C1alp1v7cRn4t64M6t4XxmCVIsQMU
        kxrPqMPg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.94.2 #2 (Red Hat Linux))
        id 1ovKyd-005iYv-Dx; Wed, 16 Nov 2022 16:09:27 +0000
Date:   Wed, 16 Nov 2022 08:09:27 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Jeff Layton <jlayton@kernel.org>
Cc:     linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        chuck.lever@oracle.com, viro@zeniv.linux.org.uk, hch@lst.de,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna@kernel.org>
Subject: Re: [PATCH 5/7] lockd: use locks_inode_context helper
Message-ID: <Y3ULNwiXSyVso5Af@infradead.org>
References: <20221116151726.129217-1-jlayton@kernel.org>
 <20221116151726.129217-6-jlayton@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20221116151726.129217-6-jlayton@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
