Return-Path: <SRS0=WqcA=WP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62E6FC3A5A0
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Aug 2019 15:01:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 382FF206BB
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Aug 2019 15:01:59 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726211AbfHSPB6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Aug 2019 11:01:58 -0400
Received: from fieldses.org ([173.255.197.46]:39080 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726168AbfHSPB6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Aug 2019 11:01:58 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 164EC1E19; Mon, 19 Aug 2019 11:01:58 -0400 (EDT)
Date:   Mon, 19 Aug 2019 11:01:58 -0400
To:     Trond Myklebust <trondmy@gmail.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 00/16] Cache open file descriptors in knfsd
Message-ID: <20190819150158.GB18075@fieldses.org>
References: <20190818181859.8458-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190818181859.8458-1-trond.myklebust@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, Aug 18, 2019 at 02:18:43PM -0400, Trond Myklebust wrote:
> v2:
> - Fix a double semicolon in fs/nfsd/filecache.c
> - Adjust changelog for "nfsd: rip out the raparms cache" as per Chuck's
>   request.

Thanks, replaced the series in my -next branch with this version.

--b.
