Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5C8CC74A5B
	for <linux-nfs@archiver.kernel.org>; Thu, 30 Mar 2023 05:45:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229773AbjC3FpK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 30 Mar 2023 01:45:10 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47986 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229500AbjC3FpK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Mar 2023 01:45:10 -0400
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A1EAF1BE4;
        Wed, 29 Mar 2023 22:45:08 -0700 (PDT)
Received: by verein.lst.de (Postfix, from userid 2407)
        id D3FEB68D07; Thu, 30 Mar 2023 07:45:03 +0200 (CEST)
Date:   Thu, 30 Mar 2023 07:45:02 +0200
From:   Christoph Hellwig <hch@lst.de>
To:     Christian Brauner <brauner@kernel.org>
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna@kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Christoph Hellwig <hch@lst.de>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfs: use vfs setgid helper
Message-ID: <20230330054502.GA8051@lst.de>
References: <20230313-fs-nfs-setgid-v2-1-9a59f436cfc0@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20230313-fs-nfs-setgid-v2-1-9a59f436cfc0@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
