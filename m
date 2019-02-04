Return-Path: <SRS0=dgFe=QL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EF56C282C4
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 14:32:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5BEF82083B
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 14:32:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hHLt9Be/"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726826AbfBDOcl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Feb 2019 09:32:41 -0500
Received: from bombadil.infradead.org ([198.137.202.133]:37494 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726789AbfBDOcl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2019 09:32:41 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=/31eQ+JjiOpWQpwXTnBMvDznM/XKqSPICv3mUD0iCYw=; b=hHLt9Be/ml8FaF7sVM/67f9fC
        /W2DnkDxes5m2y/E78bSQWqwtYbZl5XzJ6dSZ2b/bV9B8AbuuwLibm6/STDpM1sKyYMcaXLwq0TAg
        H/KDvb5SbQQiOasJTYvz1J96AxNuvbmEq6WP3BJsBLQeFhWr0wNz0Jr1LYRFblT4H6zZFNiezse1m
        JX81eO+/wHtzhvdAMXWw6nJhq1zyGAgXjZZgB0zqJWbqRWPUIuWgLSsiJO/kLDcKWsHzV5AfNL21H
        qNWRXBujUKhz9fKdz5AFrY2PAX4ivoE8NK0y/Mq/IC92zGWp7OzE7bRsi/94x0Ul3uMtAgkGttnBF
        xXrLz1Tfw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gqfId-0004DB-P2; Mon, 04 Feb 2019 14:32:39 +0000
Date:   Mon, 4 Feb 2019 06:32:39 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        simo@redhat.com
Subject: Re: [PATCH RFC 04/10] SUNRPC: Add common byte-swapped RPC header
 constants
Message-ID: <20190204143239.GA15081@infradead.org>
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
 <20190201195747.11389.75164.stgit@manet.1015granger.net>
 <20190202170258.GA14074@infradead.org>
 <52468C38-9E9C-49A7-B44B-2BE302A33145@oracle.com>
 <20190204075336.GA28337@infradead.org>
 <0EB44600-7CF7-45C3-A1AB-75B76EFA1546@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0EB44600-7CF7-45C3-A1AB-75B76EFA1546@oracle.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Feb 04, 2019 at 09:16:54AM -0500, Chuck Lever wrote:
> They are. The problem is that we are byte-swapping the incoming wire
> data and then comparing to CPU-endian constants in some hot paths.
> It's better to leave the incoming data alone and compare to a pre-
> byte-swapped constant. This patch adds some of these constants that
> were missing, in preparation for fixing the hot paths.
> 
> That is apparently not clear from the patch description, so I will
> endeavor to improve it.

Why do we need new enums / #defines for that?

Just replace:

	if (beXX_to_cpu(pkt->field) == SOME_CONSTANT)

with

	if (pkt->field == cpu_to_be32(SOME_CONSTANT))

and we are done.  The latter is a pretty common pattern through
the kernel.
