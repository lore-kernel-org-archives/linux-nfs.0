Return-Path: <SRS0=j4kQ=A7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C1BBC433E0
	for <linux-nfs@archiver.kernel.org>; Mon, 20 Jul 2020 14:12:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id F04A820B1F
	for <linux-nfs@archiver.kernel.org>; Mon, 20 Jul 2020 14:12:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="CCihwot2"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726095AbgGTOM6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 20 Jul 2020 10:12:58 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:53750 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725934AbgGTOM6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jul 2020 10:12:58 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3B357C061794
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2020 07:12:56 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 714038768; Mon, 20 Jul 2020 10:12:55 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 714038768
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1595254375;
        bh=tOp2GC5dEnoPiXY4E7v82/PQH5kc63mmSarJkbNcd5Q=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=CCihwot2g7u4xdSoa8Kr2NddsKGWtGCyXKu/epoNjgeV7kPEFrt/P/LqqjTJC1Bkp
         2somJGmCB5IlE2BI/BecqFXghfLWR75xYKkexwJGcqZ0xVqtpsix0QmlAwIaCc15m/
         KzaWWFkQOQYNL4SJFSC6rkVUTr73Ti1pmYP3U6ic=
Date:   Mon, 20 Jul 2020 10:12:55 -0400
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "ltp@lists.linux.it" <ltp@lists.linux.it>,
        "pvorel@suse.cz" <pvorel@suse.cz>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "alexey.kodanev@oracle.com" <alexey.kodanev@oracle.com>,
        "yangx.jy@cn.fujitsu.com" <yangx.jy@cn.fujitsu.com>
Subject: Re: [RFC PATCH 1/1] Remove nfsv4
Message-ID: <20200720141255.GA25707@fieldses.org>
References: <20200720091449.19813-1-pvorel@suse.cz>
 <ffb5cd64d5d65b762bdc85b6044b7fdc526d27cb.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ffb5cd64d5d65b762bdc85b6044b7fdc526d27cb.camel@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Jul 20, 2020 at 01:32:09PM +0000, Trond Myklebust wrote:
> On Mon, 2020-07-20 at 11:14 +0200, Petr Vorel wrote:
> > Reasons to drop:
> > * outdated tests (from 2005)
> > * not used (NFS kernel maintainers use pynfs [1])
> > * written in Python (we support C and shell, see [2])
> > 
> > [1] http://git.linux-nfs.org/?p=bfields/pynfs.git;a=summary
> > [2] https://github.com/linux-test-project/ltp/issues/547
> > 
> 
> Unlike pynfs, these tests run on a real NFS client, and were designed
> to test client implementations, as well as the servers.
> 
> So if they get dropped from ltp, then we will have to figure out some
> other way of continuing to maintain them.

Just for fun, I grepped through old mail to see if I could find any
cases of these tests being used.  I found one, in which Chuck reports an
nfslock01 failure.  Looks like it did find a real bug, which we fixed:

	https://lore.kernel.org/r/8DF85CB6-5FEB-4A25-9715-C9808F37A4B1@oracle.com
	https://lore.kernel.org/r/20160807185024.11705.10864.stgit@klimt.1015granger.net

--b.
