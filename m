Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5DA0C433F5
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Feb 2022 08:52:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232381AbiBGIs6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 7 Feb 2022 03:48:58 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:35334 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S241538AbiBGIkd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Feb 2022 03:40:33 -0500
Received: from bombadil.infradead.org (bombadil.infradead.org [IPv6:2607:7c80:54:e::133])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 4B766C043181;
        Mon,  7 Feb 2022 00:40:33 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=; b=03wfvWQ2MzlBiCrO0YAhqTOrHW
        DVgu9ro63l9uZ4OQSpNAp+MjaQgtX026sT/BNQwhRxzyfgAxh8U1OeviH0htHYMqBEaZJ2ay8poiM
        38W/3NTc/VYJ9f6oC+Rfoa1o90J0EA8ALXLsDrh5Dee+v30HgA0KSj2oGJ6lYxo8qhEvEBLJUS5Lr
        V77ziPNpto9g5MWUcOzd8DmFzGJ9tzN1zWCfbaFG/QJV1gJuvPtU40t7rPKf0XtLavV2xQGrWeQUy
        0sgxB5DxS8J7gyodq6Hfx/spUpTyYmNqwjU+HsNpr+hFzPgDOblszvfQw1UWKr5uDRXGN36QKpFbz
        kaG1e+bQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.94.2 #2 (Red Hat Linux))
        id 1nGzZK-009OGr-0a; Mon, 07 Feb 2022 08:40:18 +0000
Date:   Mon, 7 Feb 2022 00:40:17 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     NeilBrown <neilb@suse.de>
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mark Hemment <markhemm@googlemail.com>,
        Christoph Hellwig <hch@infradead.org>,
        David Howells <dhowells@redhat.com>, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 09/21] MM: submit multipage write for SWP_FS_OPS
 swap-space
Message-ID: <YgDa8dKPUMFpLg0f@infradead.org>
References: <164420889455.29374.17958998143835612560.stgit@noble.brown>
 <164420916117.29374.17897957849434348102.stgit@noble.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <164420916117.29374.17897957849434348102.stgit@noble.brown>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
