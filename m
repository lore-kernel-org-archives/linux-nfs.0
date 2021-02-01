Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13D50C433DB
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Feb 2021 12:22:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id CA26C64E96
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Feb 2021 12:22:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229545AbhBAMWv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 1 Feb 2021 07:22:51 -0500
Received: from verein.lst.de ([213.95.11.211]:40973 "EHLO verein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229524AbhBAMWu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 1 Feb 2021 07:22:50 -0500
Received: by verein.lst.de (Postfix, from userid 2407)
        id CCB7C6736F; Mon,  1 Feb 2021 13:22:04 +0100 (CET)
Date:   Mon, 1 Feb 2021 13:22:04 +0100
From:   Christoph Hellwig <hch@lst.de>
To:     Matthew Wilcox <willy@infradead.org>
Cc:     Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
        Song Liu <song@kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>,
        Chao Yu <chao@kernel.org>,
        Philipp Reisner <philipp.reisner@linbit.com>,
        Lars Ellenberg <lars.ellenberg@linbit.com>,
        Coly Li <colyli@suse.de>, Mike Snitzer <snitzer@redhat.com>,
        Josef Bacik <josef@toxicpanda.com>,
        David Sterba <dsterba@suse.com>,
        Damien Le Moal <damien.lemoal@wdc.com>,
        Naohiro Aota <naohiro.aota@wdc.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ryusuke Konishi <konishi.ryusuke@gmail.com>,
        linux-nilfs@vger.kernel.org, dm-devel@redhat.com,
        linux-f2fs-devel@lists.sourceforge.net,
        linux-block@vger.kernel.org, drbd-dev@lists.linbit.com,
        linux-bcache@vger.kernel.org, linux-raid@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 04/17] block: split bio_kmalloc from bio_alloc_bioset
Message-ID: <20210201122204.GA22727@lst.de>
References: <20210126145247.1964410-1-hch@lst.de> <20210126145247.1964410-5-hch@lst.de> <20210130035646.GH308988@casper.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210130035646.GH308988@casper.infradead.org>
User-Agent: Mutt/1.5.17 (2007-11-01)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Jan 30, 2021 at 03:56:46AM +0000, Matthew Wilcox wrote:
> On Tue, Jan 26, 2021 at 03:52:34PM +0100, Christoph Hellwig wrote:
> > bio_kmalloc shares almost no logic with the bio_set based fast path
> > in bio_alloc_bioset.  Split it into an entirely separate implementation.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > ---
> >  block/bio.c         | 167 ++++++++++++++++++++++----------------------
> >  include/linux/bio.h |   6 +-
> >  2 files changed, 86 insertions(+), 87 deletions(-)
> 
> This patch causes current linux-next to OOM for me when running xfstests
> after about ten minutes.  Haven't looked into why yet, this is just the
> results of a git bisect.

I've run tests on linux-next all weekend and could not reproduce
the issue.  Can you share your .config?
