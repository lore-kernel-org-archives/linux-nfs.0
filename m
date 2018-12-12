Return-Path: <SRS0=XDbB=OV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98C18C04EB8
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 07:18:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5102420851
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 07:18:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="c5AJQAo9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5102420851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726434AbeLLHSo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 02:18:44 -0500
Received: from bombadil.infradead.org ([198.137.202.133]:43370 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726253AbeLLHSo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2018 02:18:44 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=tII+gt63TctK3zy0ShKbBViEju78k5DAJVJth/mKCSU=; b=c5AJQAo9F1A930LMWFcuU8DE+
        P7t5987as9fJR65T3mCCw7iUVfIfYc7VG8hiPx+Ra4jPoyZV5ox5N1OolBB2kli/rizYoGxFngnlo
        /2Pn7Prq/+VsYDUGnE16CVAlDFeqfW2WOBTVP+96gdC4Te2nxNpgKgTWQwOjXQL6LN/A0tJMTvMiY
        A622a2Xneu95zS1YrWtQk0RQXEH9DDPNaNWuouftVPx6tDEb2iceqHuBbT07y++WKbl6rO+g5PG8e
        5P/kugWoBYASVpjve6huS2uc8grk4hEWygmba72Fp2Qy/MGkCEWir3XxYn1HTk0x4AWu9u22KN2Sp
        kJwnooFSQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gWyn4-0006ga-SH; Wed, 12 Dec 2018 07:18:42 +0000
Date:   Tue, 11 Dec 2018 23:18:42 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 05/24] xprtrdma: Reduce max_frwr_depth
Message-ID: <20181212071842.GB23247@infradead.org>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
 <20181210162945.4198.24714.stgit@manet.1015granger.net>
 <20181211140242.GC30471@infradead.org>
 <69E69F06-4B3C-4C91-9412-3E7FE14C2ADA@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <69E69F06-4B3C-4C91-9412-3E7FE14C2ADA@oracle.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Dec 11, 2018 at 10:30:24AM -0500, Chuck Lever wrote:
> 
> 
> > On Dec 11, 2018, at 9:02 AM, Christoph Hellwig <hch@infradead.org> wrote:
> > 
> > On Mon, Dec 10, 2018 at 11:29:45AM -0500, Chuck Lever wrote:
> >> Some devices advertise a large max_fast_reg_page_list_len
> >> capability, but perform optimally when MRs are significantly smaller
> >> than that depth -- probably when the MR itself is no larger than a
> >> page.
> >> 
> >> By default, the RDMA R/W core API uses max_sge_rd as the maximum
> >> page depth for MRs. For some devices, the value of max_sge_rd is
> >> 1, which is also not optimal. Thus, when max_sge_rd is larger than
> >> 1, use that value. Otherwise use the value of the
> >> max_fast_reg_page_list_len attribute.
> >> 
> >> I've tested this with a couple of devices, and it reproducibly
> >> improves the throughput of large I/Os by several percent.
> > 
> > Can you list which devices for reference in the changelog?
> 
> I have only three devices here. I can't make an exhaustive list.

Just list the onces you've tested.
