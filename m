Return-Path: <SRS0=3CSe=OO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F0BBC04EB9
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 21:30:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E9E9A213A2
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 21:30:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="j1pA0bgX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9E9A213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728138AbeLEVaC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 5 Dec 2018 16:30:02 -0500
Received: from bombadil.infradead.org ([198.137.202.133]:43384 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727309AbeLEVaB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Dec 2018 16:30:01 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=C5F/HJE1PBG9N9gpAe9ettEQDNk5SzFKGiCNYBkhmlk=; b=j1pA0bgXQekjRvv9ve3+AFaJs
        AxwWBsSMEiI9WdH/W76h032JTU+ZDO90N6YkhubkNg4RrLpdYfMo/5UuchG4KWZbaoeYytd5TD2a/
        yb0M/yWo3wng62PTDs9WBWJmgeF1kHTXCmqr3hPSSRQRrqLXbbtcUVlhTLO6feephw1jG2Y808tcV
        fOq7WqRMaXuNBoCCKExfuN8TmHYhzJeBufrAK+Qz12CLqSe/x8gZpCFoCnSgToX57fjfcv4QcJOWE
        qf6//iY8tGraRykVRw4zPV4xgAkDbEIg8mz2JYHKEpoCcZWn5o8UIb0TXR0wYJc6UlXf9ervU5MIg
        ucx1K3FBQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gUek4-00074d-6n; Wed, 05 Dec 2018 21:30:00 +0000
Date:   Wed, 5 Dec 2018 13:30:00 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Dave Chinner <david@fromorbit.com>
Cc:     Christoph Hellwig <hch@infradead.org>,
        Amir Goldstein <amir73il@gmail.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-xfs <linux-xfs@vger.kernel.org>,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        overlayfs <linux-unionfs@vger.kernel.org>,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org
Subject: Re: [PATCH 01/11] vfs: copy_file_range source range over EOF should
 fail
Message-ID: <20181205213000.GA27133@infradead.org>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-2-david@fromorbit.com>
 <CAOQ4uxhOQY8M5rbgHKREN5qpeDGHv0-xK3r37Lj6XfqFoE4qjg@mail.gmail.com>
 <20181204151332.GA32245@infradead.org>
 <20181204212948.GO6311@dastard>
 <20181205141252.GB21109@infradead.org>
 <20181205210824.GT6311@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181205210824.GT6311@dastard>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Dec 06, 2018 at 08:08:24AM +1100, Dave Chinner wrote:
> On Wed, Dec 05, 2018 at 06:12:52AM -0800, Christoph Hellwig wrote:
> > > Realistically, though, I think an attempt to read beyond EOF for the
> > > copy should result in behaviour like read() (i.e. return 0 bytes),
> > > not EINVAL. The existing behaviour needs to change, though.
> > 
> > I agree with this statement.  So we don't we implement these semantics?
> 
> No, we don't.

Sorry - I was rushing that sentence out.  It should have been:

So why don't we implement these semantics?

> 
> I will rework the patch series to make attempts to copy beyond the
> end of the source file return 0 to indicate that there is no more
> data to copy rather than return an error.

Great, thanks!
