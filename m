Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19AB8C433ED
	for <linux-nfs@archiver.kernel.org>; Wed, 14 Apr 2021 17:05:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id DCC4A61154
	for <linux-nfs@archiver.kernel.org>; Wed, 14 Apr 2021 17:05:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1345450AbhDNRFn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 14 Apr 2021 13:05:43 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40382 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232447AbhDNRFm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Apr 2021 13:05:42 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id DE353C061574
        for <linux-nfs@vger.kernel.org>; Wed, 14 Apr 2021 10:05:20 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 77145724A; Wed, 14 Apr 2021 13:05:19 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 77145724A
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1618419919;
        bh=mizE6SgB/DvvRtCs6xfXRrKrtpZq/oxFMl3wuIT+xAE=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=AcSfVs+A5QecE19bDlcYm0NaOWxffTyoEQ8xBHOj1QTpQD7Aeya3xUpZYaoxbAnAU
         OqBmZtAh/I67vOf+8AM6/jggKdf7Y+Ngy54BxAQY7SA2QTkiVxHrVGSRMcowH5/liz
         ecxVwZqEwe+51R0AqaDC0jS9ZY49iDGQWP1VWJNM=
Date:   Wed, 14 Apr 2021 13:05:19 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     trondmy@kernel.org
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        Olga Kornievskaia <kolga@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFSv42: Don't force attribute revalidation of the
 copy offload source
Message-ID: <20210414170519.GD16800@fieldses.org>
References: <20210414143138.15192-1-trondmy@kernel.org>
 <20210414143138.15192-2-trondmy@kernel.org>
 <20210414144033.GC16800@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210414144033.GC16800@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Apr 14, 2021 at 10:40:33AM -0400, bfields wrote:
> Thanks!  Testing....

... and, test results back with these two patches applied, looks good!

--b.

> 
> --b.
> 
> On Wed, Apr 14, 2021 at 10:31:38AM -0400, trondmy@kernel.org wrote:
> > From: Trond Myklebust <trond.myklebust@hammerspace.com>
> > 
> > When a copy offload is performed, we do not expect the source file to
> > change other than perhaps to see the atime be updated.
> > 
> > Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> > ---
> >  fs/nfs/nfs42proc.c | 7 +------
> >  1 file changed, 1 insertion(+), 6 deletions(-)
> > 
> > diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> > index 3875120ef3ef..a24349512ffe 100644
> > --- a/fs/nfs/nfs42proc.c
> > +++ b/fs/nfs/nfs42proc.c
> > @@ -390,12 +390,7 @@ static ssize_t _nfs42_proc_copy(struct file *src,
> >  	}
> >  
> >  	nfs42_copy_dest_done(dst_inode, pos_dst, res->write_res.count);
> > -
> > -	spin_lock(&src_inode->i_lock);
> > -	nfs_set_cache_invalid(src_inode, NFS_INO_REVAL_PAGECACHE |
> > -						 NFS_INO_REVAL_FORCED |
> > -						 NFS_INO_INVALID_ATIME);
> > -	spin_unlock(&src_inode->i_lock);
> > +	nfs_invalidate_atime(src_inode);
> >  	status = res->write_res.count;
> >  out:
> >  	if (args->sync)
> > -- 
> > 2.30.2
