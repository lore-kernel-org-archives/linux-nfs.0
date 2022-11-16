Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3D89C433FE
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Nov 2022 16:09:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233843AbiKPQJG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 16 Nov 2022 11:09:06 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47890 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233880AbiKPQJB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Nov 2022 11:09:01 -0500
Received: from bombadil.infradead.org (bombadil.infradead.org [IPv6:2607:7c80:54:3::133])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 4F82A554EA;
        Wed, 16 Nov 2022 08:09:01 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=; b=NLpaHaJIc1e+zajO0KAeHEp9IS
        tW6HBPn9yRmkhDgXhugod45Wwu4MLokr8s2PFxdD1NrPEW9HWY0OR/RvUKIwJjeLXjRlAAPtGD7ht
        aEMHrDBBDpJS/ohTqdfHoPaS2ck84nE9PsRA3nBdWx+KN/3OPgl9Bw5LPmaUOX7Q3/lWKP8Dh+djO
        Sl6Q6KAjPvaVqb4D3OblXhPEhfNkHbKiiVy6RD70SYKXdMlM9RSp2Snp8omfDrNW+XOXfIjkda+Tm
        t9rQeozqgiFW9zF83Eo9GE51bpIZePYtbrq8B2WCozY1PoGimMJb/bMhIIfqobX8DrcLhU7ho0e+t
        QDBNBkew==;
Received: from hch by bombadil.infradead.org with local (Exim 4.94.2 #2 (Red Hat Linux))
        id 1ovKyC-005iKx-UM; Wed, 16 Nov 2022 16:09:00 +0000
Date:   Wed, 16 Nov 2022 08:09:00 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Jeff Layton <jlayton@kernel.org>
Cc:     linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        chuck.lever@oracle.com, viro@zeniv.linux.org.uk, hch@lst.de,
        Steve French <smfrench@samba.org>
Subject: Re: [PATCH 3/7] cifs: use locks_inode_context helper
Message-ID: <Y3ULHAs+S9TET8Nr@infradead.org>
References: <20221116151726.129217-1-jlayton@kernel.org>
 <20221116151726.129217-4-jlayton@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20221116151726.129217-4-jlayton@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
