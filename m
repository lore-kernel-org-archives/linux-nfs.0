Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1D77C83F11
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Aug 2023 09:25:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229497AbjH1JZX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 28 Aug 2023 05:25:23 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:43318 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230248AbjH1JZG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Aug 2023 05:25:06 -0400
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 127A0118
        for <linux-nfs@vger.kernel.org>; Mon, 28 Aug 2023 02:25:00 -0700 (PDT)
Received: by verein.lst.de (Postfix, from userid 2407)
        id 771796732D; Mon, 28 Aug 2023 11:24:56 +0200 (CEST)
Date:   Mon, 28 Aug 2023 11:24:56 +0200
From:   Christoph Hellwig <hch@lst.de>
To:     Chuck Lever <cel@kernel.org>
Cc:     linux-nfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
        Tom Haynes <loghyr@gmail.com>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFSD: da_addr_body missing in some GETDEVICEINFO
 replies
Message-ID: <20230828092456.GA31142@lst.de>
References: <169219563023.7562.16862946984900949137.stgit@bazille.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <169219563023.7562.16862946984900949137.stgit@bazille.1015granger.net>
User-Agent: Mutt/1.5.17 (2007-11-01)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
