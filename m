Return-Path: <SRS0=OjhL=OU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 481D2C07E85
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 14:02:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 04C442084A
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 14:02:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qYxzC/Hr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04C442084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726687AbeLKOCo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 11 Dec 2018 09:02:44 -0500
Received: from bombadil.infradead.org ([198.137.202.133]:35796 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726350AbeLKOCo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2018 09:02:44 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=EQiVUkaZONlrMtZy8ywggDvRO0zym7dKxsR2zgl4hus=; b=qYxzC/HrSuosZHrEow7CxLop0
        6XxnQOT3WaZwdjBNEH2yqaVbh9HYTfhySamehyUGPL+DVvwbr6cCUl11ESe3VPskvQf9vBvyOZysT
        EOZTCdkjTKinLB9g6WOn7U7zouosxqS4AmYSe2Mfj3y2GF4+1D07jhnOLyhKN3322xESDv7QYWPky
        JP2lC4868oMAJt+ySjQpSgsKh2D90TisRSBq7IHD4QxOu1IkxcSlye3Lcuh0h4r4jHUhcatpblj/W
        EXi1Zt6y+ByU119a3ydAuyhQXBhD3CcBO1LbO+QIgB5EA0u4wgjO/aDS+xFwJaHzsf+Jn8h232Xx4
        3SYqrXO9g==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gWicV-0001NO-12; Tue, 11 Dec 2018 14:02:43 +0000
Date:   Tue, 11 Dec 2018 06:02:42 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     anna.schumaker@netapp.com, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 05/24] xprtrdma: Reduce max_frwr_depth
Message-ID: <20181211140242.GC30471@infradead.org>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
 <20181210162945.4198.24714.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181210162945.4198.24714.stgit@manet.1015granger.net>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 10, 2018 at 11:29:45AM -0500, Chuck Lever wrote:
> Some devices advertise a large max_fast_reg_page_list_len
> capability, but perform optimally when MRs are significantly smaller
> than that depth -- probably when the MR itself is no larger than a
> page.
> 
> By default, the RDMA R/W core API uses max_sge_rd as the maximum
> page depth for MRs. For some devices, the value of max_sge_rd is
> 1, which is also not optimal. Thus, when max_sge_rd is larger than
> 1, use that value. Otherwise use the value of the
> max_fast_reg_page_list_len attribute.
> 
> I've tested this with a couple of devices, and it reproducibly
> improves the throughput of large I/Os by several percent.

Can you list which devices for reference in the changelog?
