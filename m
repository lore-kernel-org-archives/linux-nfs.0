Return-Path: <SRS0=hL3P=2J=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F492C43603
	for <linux-nfs@archiver.kernel.org>; Thu, 19 Dec 2019 22:44:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 420F224676
	for <linux-nfs@archiver.kernel.org>; Thu, 19 Dec 2019 22:44:30 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726930AbfLSWo3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 19 Dec 2019 17:44:29 -0500
Received: from fieldses.org ([173.255.197.46]:38786 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726818AbfLSWo3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Dec 2019 17:44:29 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 705AB1C7C; Thu, 19 Dec 2019 17:44:29 -0500 (EST)
Date:   Thu, 19 Dec 2019 17:44:29 -0500
To:     Dave Chinner <david@fromorbit.com>
Cc:     Trond Myklebust <trondmy@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: Clone should commit src file metadata too
Message-ID: <20191219224429.GE12026@fieldses.org>
References: <20191218195723.395277-1-trond.myklebust@hammerspace.com>
 <20191218211251.GX19213@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191218211251.GX19213@dread.disaster.area>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Dec 19, 2019 at 08:12:51AM +1100, Dave Chinner wrote:
> On Wed, Dec 18, 2019 at 02:57:23PM -0500, Trond Myklebust wrote:
> > vfs_clone_file_range() can modify the metadata on the source file too,
> > so we need to commit that to stable storage as well.
> > 
> > Reported-by: Dave Chinner <david@fromorbit.com>
> > Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> 
> Looks ok to me now.
> 
> Acked-by: Dave Chinner <dchinner@redhat.com>

Thanks!  Applying for 5.6, with Dave's ACK.--b.
