Return-Path: <SRS0=bKkf=3L=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D58C4C2D0DB
	for <linux-nfs@archiver.kernel.org>; Wed, 22 Jan 2020 17:04:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B3BCA21569
	for <linux-nfs@archiver.kernel.org>; Wed, 22 Jan 2020 17:04:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726871AbgAVREC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 22 Jan 2020 12:04:02 -0500
Received: from fieldses.org ([173.255.197.46]:38416 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725883AbgAVREC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 22 Jan 2020 12:04:02 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id EC9AF1C89; Wed, 22 Jan 2020 12:04:01 -0500 (EST)
Date:   Wed, 22 Jan 2020 12:04:01 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@gmail.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/9] Fix error reporting for NFS writes
Message-ID: <20200122170401.GA3720@fieldses.org>
References: <20200106184037.563557-1-trond.myklebust@hammerspace.com>
 <20200122152751.GD2654@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200122152751.GD2654@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Jan 22, 2020 at 10:27:51AM -0500, bfields wrote:
> By the way, anyone know how to handle quoted-printable patches?
> 
> For some reason, git-am seems to deal with them, but git-apply doesn't.
> So it's fine until there's some minor conflict.

(Ended up running them through "tcucodec quote -d".  Maybe there's some
more obvious solution.)

--b.
