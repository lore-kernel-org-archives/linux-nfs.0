Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 697F6C432BE
	for <linux-nfs@archiver.kernel.org>; Fri, 27 Aug 2021 15:16:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 4E2B660E90
	for <linux-nfs@archiver.kernel.org>; Fri, 27 Aug 2021 15:16:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S245383AbhH0PRg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 27 Aug 2021 11:17:36 -0400
Received: from verein.lst.de ([213.95.11.211]:34270 "EHLO verein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S234186AbhH0PRf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 27 Aug 2021 11:17:35 -0400
Received: by verein.lst.de (Postfix, from userid 2407)
        id 8260267373; Fri, 27 Aug 2021 17:16:44 +0200 (CEST)
Date:   Fri, 27 Aug 2021 17:16:44 +0200
From:   Christoph Hellwig <hch@lst.de>
To:     NeilBrown <neilb@suse.de>
Cc:     "Darrick J. Wong" <darrick.wong@oracle.com>,
        Christoph Hellwig <hch@lst.de>,
        David Howells <dhowells@redhat.com>,
        torvalds@linux-foundation.org, trond.myklebust@primarydata.com,
        linux-nfs@vger.kernel.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Don't block writes to swap-files with ETXTBSY.
Message-ID: <20210827151644.GB19199@lst.de>
References: <162993585927.7591.10174443410031404560@noble.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <162993585927.7591.10174443410031404560@noble.neil.brown.name>
User-Agent: Mutt/1.5.17 (2007-11-01)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Aug 26, 2021 at 09:57:39AM +1000, NeilBrown wrote:
> 
> Commit dc617f29dbe5 ("vfs: don't allow writes to swap files")
> broke swap-over-NFS as it introduced an ETXTBSY error when NFS tries to
> swap-out using ->direct_IO().
> 
> There is no sound justification for this error.  File permissions are
> sufficient to stop non-root users from writing to a swap file, and root
> must always be cautious not to do anything dangerous.
> 
> These checks effectively provide a mandatory write lock on swap, and
> mandatory locks are not supported in Linux.
> 
> So remove all the checks that return ETXTBSY when attempts are made to
> write to swap.

Swap files are not just any files and do need a mandatory write lock
as they are part of the kernel VM and writing to them will mess up
the kernel badly.  David Howells actually has sent various patches
to fix swap over NFS in the last weeks.
