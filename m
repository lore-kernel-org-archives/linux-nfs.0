Return-Path: <SRS0=OjhL=OU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9B7DC07E85
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 14:00:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B0B8A2082F
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 14:00:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="KJ9qVqBx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0B8A2082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726576AbeLKOAG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 11 Dec 2018 09:00:06 -0500
Received: from bombadil.infradead.org ([198.137.202.133]:33770 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726203AbeLKOAG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2018 09:00:06 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=5byMBESa39w7j+DIIgkJzb/YYHCtQy02yHWJ6dmUmhQ=; b=KJ9qVqBx8yTLrxuBZ5rB3RsdJ
        WXVJQ/4WCf//c12OtUfkm9ff0Eib/DGLQ2AuCZIVc5+uzaUuis25zSteCGh+ItqoMerlOT/rQ2Z8M
        x12mNgmPorVVMt/c09P38ILrhVTp1FJ6WMHwz9IqDRpbRp/FceeUEvVH2MixpuhWn18S2lPDebf5G
        AbgglGy1W89eE2kNX0u5wcCCe8Uj4STVd5w32MWcazG7NECaKQ8uyrJOgOj/u/ymanly/2DDprGgj
        sfyh/HtARh5IA1VOfMJSQjx5lUHmW20jLvMcpQ9N1x6wyWOihCObILpEkVYE9fXb5CSbLX4TS9gdV
        l2QWqc3Rw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gWiZx-0000CQ-CT; Tue, 11 Dec 2018 14:00:05 +0000
Date:   Tue, 11 Dec 2018 06:00:05 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     anna.schumaker@netapp.com, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 02/24] IB/rxe: IB_WR_REG_MR does not capture MR's iova
 field
Message-ID: <20181211140005.GA30471@infradead.org>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
 <20181210162929.4198.19503.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181210162929.4198.19503.stgit@manet.1015granger.net>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Shouldn't this go in through the rdma tree?
