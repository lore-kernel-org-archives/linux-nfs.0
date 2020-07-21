Return-Path: <SRS0=ojZM=BA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 156FFC433DF
	for <linux-nfs@archiver.kernel.org>; Tue, 21 Jul 2020 09:31:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E0A0A2070A
	for <linux-nfs@archiver.kernel.org>; Tue, 21 Jul 2020 09:31:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726769AbgGUJbS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 21 Jul 2020 05:31:18 -0400
Received: from mx2.suse.de ([195.135.220.15]:58148 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725984AbgGUJbS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 21 Jul 2020 05:31:18 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.221.27])
        by mx2.suse.de (Postfix) with ESMTP id 950C4B875;
        Tue, 21 Jul 2020 09:31:23 +0000 (UTC)
Date:   Tue, 21 Jul 2020 11:31:15 +0200
From:   Petr Vorel <pvorel@suse.cz>
To:     Christoph Hellwig <hch@infradead.org>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        "ltp@lists.linux.it" <ltp@lists.linux.it>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "alexey.kodanev@oracle.com" <alexey.kodanev@oracle.com>,
        "yangx.jy@cn.fujitsu.com" <yangx.jy@cn.fujitsu.com>,
        Cyril Hrubis <chrubis@suse.cz>, Yong Sun <yosun@suse.com>
Subject: Re: [RFC PATCH 1/1] Remove nfsv4
Message-ID: <20200721093115.GB1164@dell5510>
Reply-To: Petr Vorel <pvorel@suse.cz>
References: <20200720091449.19813-1-pvorel@suse.cz>
 <ffb5cd64d5d65b762bdc85b6044b7fdc526d27cb.camel@hammerspace.com>
 <20200720151742.GA16973@infradead.org>
 <20200720181658.GA32123@dell5510>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200720181658.GA32123@dell5510>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Christoph,

> > On Mon, Jul 20, 2020 at 01:32:09PM +0000, Trond Myklebust wrote:
> > > On Mon, 2020-07-20 at 11:14 +0200, Petr Vorel wrote:
> > > > Reasons to drop:
> > > > * outdated tests (from 2005)
> > > > * not used (NFS kernel maintainers use pynfs [1])
> > > > * written in Python (we support C and shell, see [2])

> > > > [1] http://git.linux-nfs.org/?p=bfields/pynfs.git;a=summary
> > > > [2] https://github.com/linux-test-project/ltp/issues/547


> > > Unlike pynfs, these tests run on a real NFS client, and were designed
> > > to test client implementations, as well as the servers.

> > > So if they get dropped from ltp, then we will have to figure out some
> > > other way of continuing to maintain them.

> > NFS tests using the kernel sound like a prime candidate for xfstests.
> In the past Yong Sun moved some ext4 related tests from LTP to xfstests.
> LTP has various NFS related tests. IMHO more important than where these tests
> should be is if anybody has a deeper look into them an cleanup them / rewrite
> them from scratch.

Although xfstests sounds like a natural choice, atm there are quite a lot NFS
tests in LTP. xfstests contain only single NFS test.

IMHO it's a choice of anybody who rewrites these tests whether he tries to put
them to LTP or into xfstests. If it were me I'd probably keep them in LTP,
because I prefer LTP framework capabilities.

Kind regards,
Petr
