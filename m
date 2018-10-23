Return-Path: <SRS0=j1eS=ND=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0F1CC67863
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 15:40:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 784C720671
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 15:40:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JipypI9k"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 784C720671
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728188AbeJXAE0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Oct 2018 20:04:26 -0400
Received: from bombadil.infradead.org ([198.137.202.133]:55726 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726970AbeJXAE0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2018 20:04:26 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=Den93AqRNmZa0ee3NUl/zQqkoRfFYDyJgm96KyeIvjU=; b=JipypI9kkgbV8z69631CPP1Nf
        tZCvbYjBcCAxLuA+aMetRXJGmOT2A/GT+wFGyMjJG0MkYIp4OP4k0YuxZ+H7cnPplW+2DInCqTyTt
        q5/oeYl+tXl7c/ahbAAFnaIyCMg/HmRnf3KA9gnHemaJ14fkvtWCS3Wi0I5Tmc9DVpNFNfvCDSzYF
        KeU2Nuk9fPQ0sIAlS6rCQOQk/E8WgFO3o455//CofZ2q4mYCRgKdzXt85ecB2Lg1Zs5Z/x68Z59y1
        nKdfo0N6BsnFEEvivke+YPqXU4oqfaTo/sq07I6xvUWIZFQ7y+URGRWcd5MKGYtAAgkK7ZAUJFAqp
        20lNo4ktw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gEynI-0007rm-3J; Tue, 23 Oct 2018 15:40:32 +0000
Date:   Tue, 23 Oct 2018 08:40:31 -0700
From:   Matthew Wilcox <willy@infradead.org>
To:     Frank Sorenson <sorenson@redhat.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] NFS: change sign of nfs_fh length
Message-ID: <20181023154031.GF20085@bombadil.infradead.org>
References: <85517ec3-e3d4-1bf3-8eea-cb274face1a7@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <85517ec3-e3d4-1bf3-8eea-cb274face1a7@redhat.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Oct 23, 2018 at 10:34:57AM -0500, Frank Sorenson wrote:
> 
> The filehandle has a length which is defined as a 32-bit
> "unsigned integer".  Change sign of the length appropriately.
> 
> Signed-off-by: Frank Sorenson <sorenson@redhat.com>

Is this a cleanup or does it fix a user-visible bug?
