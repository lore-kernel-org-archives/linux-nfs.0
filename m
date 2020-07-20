Return-Path: <SRS0=j4kQ=A7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 269F1C433DF
	for <linux-nfs@archiver.kernel.org>; Mon, 20 Jul 2020 14:36:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 0CEEB22B4D
	for <linux-nfs@archiver.kernel.org>; Mon, 20 Jul 2020 14:36:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726046AbgGTOgX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 20 Jul 2020 10:36:23 -0400
Received: from mx2.suse.de ([195.135.220.15]:51582 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725934AbgGTOgX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Jul 2020 10:36:23 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.221.27])
        by mx2.suse.de (Postfix) with ESMTP id 72241B82E;
        Mon, 20 Jul 2020 14:36:28 +0000 (UTC)
Date:   Mon, 20 Jul 2020 16:36:20 +0200
From:   Petr Vorel <pvorel@suse.cz>
To:     "bfields@fieldses.org" <bfields@fieldses.org>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        "ltp@lists.linux.it" <ltp@lists.linux.it>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "alexey.kodanev@oracle.com" <alexey.kodanev@oracle.com>,
        "yangx.jy@cn.fujitsu.com" <yangx.jy@cn.fujitsu.com>
Subject: Re: [RFC PATCH 1/1] Remove nfsv4
Message-ID: <20200720143620.GD21201@dell5510>
Reply-To: Petr Vorel <pvorel@suse.cz>
References: <20200720091449.19813-1-pvorel@suse.cz>
 <ffb5cd64d5d65b762bdc85b6044b7fdc526d27cb.camel@hammerspace.com>
 <20200720141255.GA25707@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200720141255.GA25707@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Bruce, Trond,

> On Mon, Jul 20, 2020 at 01:32:09PM +0000, Trond Myklebust wrote:
> > On Mon, 2020-07-20 at 11:14 +0200, Petr Vorel wrote:
> > > Reasons to drop:
> > > * outdated tests (from 2005)
> > > * not used (NFS kernel maintainers use pynfs [1])
> > > * written in Python (we support C and shell, see [2])

> > > [1] http://git.linux-nfs.org/?p=bfields/pynfs.git;a=summary
> > > [2] https://github.com/linux-test-project/ltp/issues/547


> > Unlike pynfs, these tests run on a real NFS client, and were designed
> > to test client implementations, as well as the servers.

> > So if they get dropped from ltp, then we will have to figure out some
> > other way of continuing to maintain them.

> Just for fun, I grepped through old mail to see if I could find any
> cases of these tests being used.  I found one, in which Chuck reports an
> nfslock01 failure.  Looks like it did find a real bug, which we fixed:

> 	https://lore.kernel.org/r/8DF85CB6-5FEB-4A25-9715-C9808F37A4B1@oracle.com
> 	https://lore.kernel.org/r/20160807185024.11705.10864.stgit@klimt.1015granger.net

Thanks for your explanation, this obviously justify these tests in LTP, unless
you want to move it to git.linux-nfs.org and maintain on your own.

Kind regards,
Petr
