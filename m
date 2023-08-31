Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACDC2C83F12
	for <linux-nfs@archiver.kernel.org>; Thu, 31 Aug 2023 13:32:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S238063AbjHaNcf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 31 Aug 2023 09:32:35 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:34338 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S237683AbjHaNce (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Aug 2023 09:32:34 -0400
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 2ABD0E4F;
        Thu, 31 Aug 2023 06:32:32 -0700 (PDT)
Received: by verein.lst.de (Postfix, from userid 2407)
        id E3F8468BEB; Thu, 31 Aug 2023 15:32:27 +0200 (CEST)
Date:   Thu, 31 Aug 2023 15:32:27 +0200
From:   Christoph Hellwig <hch@lst.de>
To:     Jeff Layton <jlayton@kernel.org>
Cc:     Christoph Hellwig <hch@lst.de>, brauner@kernel.org,
        trond.myklebust@hammerspace.com, anna@kernel.org, jack@suse.cz,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] NFS: switch back to using kill_anon_super
Message-ID: <20230831133227.GB12262@lst.de>
References: <20230831052940.256193-1-hch@lst.de> <2f121ee5b7fad547ac833a5e0e986866d1177e21.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2f121ee5b7fad547ac833a5e0e986866d1177e21.camel@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Aug 31, 2023 at 09:29:14AM -0400, Jeff Layton wrote:
> Nice. Long overdue. This also might explain why ceph was once this way
> before we changed it here:
> 
>     470a5c77eac0 ceph: use kill_anon_super helper

Yes, that looks like the same workaround for bdi lifetimes.
