Return-Path: <SRS0=3CSe=OO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBBADC04EBF
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 14:09:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B0DAC2082B
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 14:09:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JyDg2fie"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0DAC2082B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727135AbeLEOJ0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 5 Dec 2018 09:09:26 -0500
Received: from bombadil.infradead.org ([198.137.202.133]:56798 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727025AbeLEOJ0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Dec 2018 09:09:26 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=VkCOEQBSuHOqt4sK2WMTNkLjYV9HncFkvIQj4UTIWB4=; b=JyDg2fieHhencKGABs1NI9KVN
        EL9xYvt1/nbtOuJRROBKGWGXhh7YJ5aJUFkeH34jVkHGzn6cK3qR6n2kocJWYda+Mg1ghwvrMRaxm
        SB63dCldc3eZWaQJxhKC0cvIRLunUdTGPD0IfT5VUzJi+d1Mvo1/rWN39jibQ5LG+rnREX41UQP7J
        8+3sGR+y9XdQ/QRY3XzWR5Bxf3E3mOBrundaqvdhAUeQlO+QvlLJoOIl4CcUzuaqDX1P5QvLo5pBC
        JUZyCqWnfLxIEIA1Q27w5HKUi2h8n1eGDSzZcrF86RXCPzm5evGzMPBNUu8NRTYoQYpNUd87LbQIh
        rsDI6Nvsw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gUXri-0006JP-15; Wed, 05 Dec 2018 14:09:26 +0000
Date:   Wed, 5 Dec 2018 06:09:25 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Dave Chinner <david@fromorbit.com>
Cc:     Christoph Hellwig <hch@infradead.org>,
        linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
        olga.kornievskaia@gmail.com, linux-nfs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: [PATCH 09/11] vfs: push copy_file_ranges -EXDEV checks down
Message-ID: <20181205140925.GA21109@infradead.org>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-10-david@fromorbit.com>
 <20181204154347.GA6925@infradead.org>
 <20181204221847.GQ6311@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204221847.GQ6311@dastard>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Dec 05, 2018 at 09:18:47AM +1100, Dave Chinner wrote:
> I'll drop it if you want, but then I'll just have to come back after
> all the NFS code is merged and do yet more cleanup work.

IFF we want these NFS "features" we'll have to get it right before
merging the code.  But even with that I'd rather fix the glaring
issues you are fixing in your first patches as a priority before
adding more features.  In other words:  don't worry about NFS, lets
get the existing code right before worrying about the next round
of potential issues.
