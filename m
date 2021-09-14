Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A5FFC433EF
	for <linux-nfs@archiver.kernel.org>; Tue, 14 Sep 2021 20:23:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 58A9B61164
	for <linux-nfs@archiver.kernel.org>; Tue, 14 Sep 2021 20:23:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234740AbhINUZF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 14 Sep 2021 16:25:05 -0400
Received: from outgoing-auth-1.mit.edu ([18.9.28.11]:35788 "EHLO
        outgoing.mit.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S234340AbhINUYn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Sep 2021 16:24:43 -0400
Received: from cwcc.thunk.org (pool-72-74-133-215.bstnma.fios.verizon.net [72.74.133.215])
        (authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
        by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id 18EKMujD020560
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
        Tue, 14 Sep 2021 16:22:57 -0400
Received: by cwcc.thunk.org (Postfix, from userid 15806)
        id 97AD815C3424; Tue, 14 Sep 2021 16:22:56 -0400 (EDT)
Date:   Tue, 14 Sep 2021 16:22:56 -0400
From:   "Theodore Ts'o" <tytso@mit.edu>
To:     Muchun Song <songmuchun@bytedance.com>
Cc:     willy@infradead.org, akpm@linux-foundation.org, hannes@cmpxchg.org,
        mhocko@kernel.org, vdavydov.dev@gmail.com, shakeelb@google.com,
        guro@fb.com, shy828301@gmail.com, alexs@kernel.org,
        richard.weiyang@gmail.com, david@fromorbit.com,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        zhengqi.arch@bytedance.com, duanxiongchun@bytedance.com,
        fam.zheng@bytedance.com, smuchun@gmail.com
Subject: Re: [PATCH v3 00/76] Optimize list lru memory consumption
Message-ID: <YUEEoAUBaN7J0ch3@mit.edu>
References: <20210914072938.6440-1-songmuchun@bytedance.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210914072938.6440-1-songmuchun@bytedance.com>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Sep 14, 2021 at 03:28:22PM +0800, Muchun Song wrote:
> So we have to convert to new API for all filesystems, which is done in
> one patch. Some filesystems are easy to convert (just replace
> kmem_cache_alloc() to alloc_inode_sb()), while other filesystems need to
> do more work.

From what I can tell, three are 54 file systems for which it was a
trivial one-line change, and two (f2fs and nfs42) that were a tad bit
more complex.

> In order to make it easy for maintainers of different
> filesystems to review their own maintained part, I split the patch into
> patches which are per-filesystem in this version. I am not sure if this
> is a good idea, because there is going to be more commits.

What I'd actually suggest is that you combine all of the trivial file
system changes into a single commit, and keep the two more complex
changes for f2fs and nfs42 in separate commits.

Acked-by: Theodore Ts'o <tytso@mit.edu>

... for the ext4 related change.

						- Ted
						
