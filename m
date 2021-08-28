Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 409ADC4320E
	for <linux-nfs@archiver.kernel.org>; Sat, 28 Aug 2021 07:10:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 229CB6108D
	for <linux-nfs@archiver.kernel.org>; Sat, 28 Aug 2021 07:10:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233356AbhH1HLI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 28 Aug 2021 03:11:08 -0400
Received: from verein.lst.de ([213.95.11.211]:35859 "EHLO verein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S233348AbhH1HLI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 28 Aug 2021 03:11:08 -0400
Received: by verein.lst.de (Postfix, from userid 2407)
        id 8E5E267373; Sat, 28 Aug 2021 09:10:14 +0200 (CEST)
Date:   Sat, 28 Aug 2021 09:10:14 +0200
From:   Christoph Hellwig <hch@lst.de>
To:     NeilBrown <neilb@suse.de>
Cc:     Christoph Hellwig <hch@lst.de>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        David Howells <dhowells@redhat.com>,
        torvalds@linux-foundation.org, trond.myklebust@primarydata.com,
        linux-nfs@vger.kernel.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Don't block writes to swap-files with ETXTBSY.
Message-ID: <20210828071014.GA31677@lst.de>
References: <20210827151644.GB19199@lst.de> <163010581548.7591.7557563272768619093@noble.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <163010581548.7591.7557563272768619093@noble.neil.brown.name>
User-Agent: Mutt/1.5.17 (2007-11-01)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Aug 28, 2021 at 09:10:15AM +1000, NeilBrown wrote:
> There are lots of different things root can do which will mess up the
> kernel badly.  The backing-store can still be changed through some other
> means.
> Do you have a particular threat or risk scenario other than "root might
> get careless"?

No, it is just that scenario.  But one that is much easier to trigger
than more convoluted ways for a root user to trigger damage through
device files, and one that can't be prevented through LSMs or the
capability system.
