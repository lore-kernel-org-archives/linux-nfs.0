Return-Path: <SRS0=v/uS=QM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1065C282D7
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 21:31:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6CB31217D6
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 21:31:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727232AbfBEVbs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Feb 2019 16:31:48 -0500
Received: from fieldses.org ([173.255.197.46]:53126 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726062AbfBEVbs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Feb 2019 16:31:48 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 23E1B1CE6; Tue,  5 Feb 2019 16:31:48 -0500 (EST)
Date:   Tue, 5 Feb 2019 16:31:48 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Donald Buczek <buczek@molgen.mpg.de>
Cc:     stable@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4.14 0/2] Two nfsd4 fixes for 4.14 longterm
Message-ID: <20190205213148.GA16660@fieldses.org>
References: <20190205100141.25304-1-buczek@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190205100141.25304-1-buczek@molgen.mpg.de>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

ACK to both, thanks.--b.

On Tue, Feb 05, 2019 at 11:01:39AM +0100, Donald Buczek wrote:
> Please include the upstream patches
> 
>     *  commit 085def3ade52 ("nfsd4: fix cached replies to solo SEQUENCE
> compounds")
>     *  commit 53da6a53e1d4 ("nfsd4: catch some false session retries")
> 
> into longterm kernel 4.14.
> 
> Because these patches went upstream in 4.15, they are already
> included in longterm 4.19 and stable.
> 
> A nfsd4 server failure, where the server sends unrelated replies
> to client requests containing only SEQUENCE operations has been
> experienced with kernel version 4.14.87 [1]. Because the client
> retries endlessly, this completely breaks the nfs mount.
> 
> A backport of these patches has been suggested by the patch
> author J. Bruce Fields. [1]
> 
> Only limited testing has been done (running a single server with
> 4.14.96 and these two patches for a week and generating some high
> load on it). It can not be proven by testing, that the patches
> really fix the experienced problem. However, as the patches are
> part of upstream and stable kernels for over a year
> they should be a save pick.
> 
> Backport note: Only line numbers updated.
> 
> [1] https://bugzilla.kernel.org/show_bug.cgi?id=202435
> 
> J. Bruce Fields (2):
>   nfsd4: fix cached replies to solo SEQUENCE compounds
>   nfsd4: catch some false session retries
> 
>  fs/nfsd/nfs4state.c | 57 ++++++++++++++++++++++++++++++++++++++++-----
>  fs/nfsd/state.h     |  2 ++
>  fs/nfsd/xdr4.h      | 13 +++++++++--
>  3 files changed, 64 insertions(+), 8 deletions(-)
> 
> -- 
> 2.20.0
