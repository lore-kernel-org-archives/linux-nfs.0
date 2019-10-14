Return-Path: <SRS0=ZzIC=YH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 258CFC4CECE
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Oct 2019 22:34:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0CC7A2089C
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Oct 2019 22:34:00 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731986AbfJNWdv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 14 Oct 2019 18:33:51 -0400
Received: from fieldses.org ([173.255.197.46]:34314 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730121AbfJNWdv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 14 Oct 2019 18:33:51 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 84B19BDB; Mon, 14 Oct 2019 18:33:50 -0400 (EDT)
Date:   Mon, 14 Oct 2019 18:33:50 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Markus Elfring <Markus.Elfring@web.de>
Cc:     linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org, Aditya Pakki <pakki001@umn.edu>,
        Kangjie Lu <kjlu@umn.edu>, Navid Emamdoost <emamd001@umn.edu>,
        Stephen McCamant <smccaman@umn.edu>
Subject: Re: SUNRPC: Checking a kmemdup() call in xdr_netobj_dup()
Message-ID: <20191014223350.GA19883@fieldses.org>
References: <9b5a5e63-2a24-ad79-20e2-4c01331ee041@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <9b5a5e63-2a24-ad79-20e2-4c01331ee041@web.de>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Oct 12, 2019 at 08:20:04PM +0200, Markus Elfring wrote:
> I tried another script for the semantic patch language out.
> This source code analysis approach points out that the implementation
> of the function “xdr_netobj_dup” contains still an unchecked call
> of the function “kmemdup”.
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/sunrpc/xdr.h?id=1c0cc5f1ae5ee5a6913704c0d75a6e99604ee30a#n167
> https://elixir.bootlin.com/linux/v5.4-rc2/source/include/linux/sunrpc/xdr.h#L167
> 
> How do you think about to improve it?

On a quick check--I see five xdr_netobj_dup callers, and all of them
check whether dst->data is NULL.

Sounds like a false positive for your tool?

--b.
