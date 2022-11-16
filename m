Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BEBFC43217
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Nov 2022 16:08:52 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233556AbiKPQIv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 16 Nov 2022 11:08:51 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47590 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233487AbiKPQIu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Nov 2022 11:08:50 -0500
Received: from bombadil.infradead.org (bombadil.infradead.org [IPv6:2607:7c80:54:3::133])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A3E364C267;
        Wed, 16 Nov 2022 08:08:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=; b=r4Ks2w33s4LaCQZykR6NYGApBw
        LYAOtoPfhiAIYFawVu61S2twH4HUT5fblqFn8hAPZTpmiBt6eDbrFRWHN9w8XGjzsVxS+ovFEjsZ/
        Mmddq7hTaj6tCsLdrJyiQmBjrK+qjstRuoSONx9Z4ztBniSguxgOiuOy6oaJw0b/ZHuCmnAeMxS9V
        dk90sb3D/af/j0HGuWoXGyudq3jE6pRTsRes0HSpsy5qML6fe05skxJ48cgyKuVeHWKvEyeTPj3eb
        tVaSbW6xTKQpwqw+Qg5MhHbtQItNUPckym4rlaAdYLEi6nJ5XHqndufRSMB/CNOXIAizbJBsa/8GG
        aVP5dLwQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.94.2 #2 (Red Hat Linux))
        id 1ovKy1-005iEO-0I; Wed, 16 Nov 2022 16:08:49 +0000
Date:   Wed, 16 Nov 2022 08:08:48 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Jeff Layton <jlayton@kernel.org>
Cc:     linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        chuck.lever@oracle.com, viro@zeniv.linux.org.uk, hch@lst.de,
        Xiubo Li <xiubli@redhat.com>
Subject: Re: [PATCH 2/7] ceph: use locks_inode_context helper
Message-ID: <Y3ULEGqCNu4B2KHc@infradead.org>
References: <20221116151726.129217-1-jlayton@kernel.org>
 <20221116151726.129217-3-jlayton@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20221116151726.129217-3-jlayton@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
