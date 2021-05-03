Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.2 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 762F9C433B4
	for <linux-nfs@archiver.kernel.org>; Mon,  3 May 2021 17:59:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 3E8F361244
	for <linux-nfs@archiver.kernel.org>; Mon,  3 May 2021 17:59:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231285AbhECSAL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 May 2021 14:00:11 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40666 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231315AbhECSAL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 May 2021 14:00:11 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id F2238C06174A
        for <linux-nfs@vger.kernel.org>; Mon,  3 May 2021 10:59:17 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 1282B5047; Mon,  3 May 2021 13:59:17 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 1282B5047
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1620064757;
        bh=mdP85pDhSB/x0JuF8VExHb8lOHc2t2rWUOwEgU1ivD0=;
        h=Date:To:Cc:Subject:References:In-Reply-To:From:From;
        b=saSpGNPW4W/u2og8RiNI47Csx3+XttCzG0jx+Nw7TVmGJ62PCf5UDfrYuyzaD6KzA
         kNwO8VYuG/K+H0Splvlw0w6HI5g5fI1IzWX1m05pE3trq3EtSyYyQSN6zMHndDh2Md
         TTunfhwTCy/Gl767fyUh7XsHP4kfNbTNZC+vCIfQ=
Date:   Mon, 3 May 2021 13:59:17 -0400
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 00/29] server-side lockd XDR overhaul
Message-ID: <20210503175917.GA18779@fieldses.org>
References: <162005520101.23028.15766816408658851498.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <162005520101.23028.15766816408658851498.stgit@klimt.1015granger.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, May 03, 2021 at 11:22:47AM -0400, Chuck Lever wrote:
> Same approach as what has been done for NFSv2, NFSv3, and NFSv4: XDR
> decoding and encoding functions have been updated to use xdr_stream.
> This adopts common XDR infrastructure for these functions and makes
> constructing and parsing more secure and robust.

Nothing objectionable to me on a quick skim, but it doesn't build when I
apply to 5.12 (fs/lockd/svc.c:794:9: error: implicit declaration of
function ‘svcxdr_init_encode’).  Should I take it from a git tree?

--b.

> 
> ---
> 
> Chuck Lever (29):
>       lockd: Remove stale comments
>       lockd: Create a simplified .vs_dispatch method for NLM requests
>       lockd: Common NLM XDR helpers
>       lockd: Update the NLMv1 void argument decoder to use struct xdr_stream
>       lockd: Update the NLMv1 TEST arguments decoder to use struct xdr_stream
>       lockd: Update the NLMv1 LOCK arguments decoder to use struct xdr_stream
>       lockd: Update the NLMv1 CANCEL arguments decoder to use struct xdr_stream
>       lockd: Update the NLMv1 UNLOCK arguments decoder to use struct xdr_stream
>       lockd: Update the NLMv1 nlm_res arguments decoder to use struct xdr_stream
>       lockd: Update the NLMv1 SM_NOTIFY arguments decoder to use struct xdr_stream
>       lockd: Update the NLMv1 SHARE arguments decoder to use struct xdr_stream
>       lockd: Update the NLMv1 FREE_ALL arguments decoder to use struct xdr_stream
>       lockd: Update the NLMv1 void results encoder to use struct xdr_stream
>       lockd: Update the NLMv1 TEST results encoder to use struct xdr_stream
>       lockd: Update the NLMv1 nlm_res results encoder to use struct xdr_stream
>       lockd: Update the NLMv1 SHARE results encoder to use struct xdr_stream
>       lockd: Update the NLMv4 void arguments decoder to use struct xdr_stream
>       lockd: Update the NLMv4 TEST arguments decoder to use struct xdr_stream
>       lockd: Update the NLMv4 LOCK arguments decoder to use struct xdr_stream
>       lockd: Update the NLMv4 CANCEL arguments decoder to use struct xdr_stream
>       lockd: Update the NLMv4 UNLOCK arguments decoder to use struct xdr_stream
>       lockd: Update the NLMv4 nlm_res arguments decoder to use struct xdr_stream
>       lockd: Update the NLMv4 SM_NOTIFY arguments decoder to use struct xdr_stream
>       lockd: Update the NLMv4 SHARE arguments decoder to use struct xdr_stream
>       lockd: Update the NLMv4 FREE_ALL arguments decoder to use struct xdr_stream
>       lockd: Update the NLMv4 void results encoder to use struct xdr_stream
>       lockd: Update the NLMv4 TEST results encoder to use struct xdr_stream
>       lockd: Update the NLMv4 nlm_res results encoder to use struct xdr_stream
>       lockd: Update the NLMv4 SHARE results encoder to use struct xdr_stream
> 
> 
>  fs/lockd/svc.c             |  43 ++++
>  fs/lockd/svcxdr.h          | 151 ++++++++++++++
>  fs/lockd/xdr.c             | 402 ++++++++++++++++++------------------
>  fs/lockd/xdr4.c            | 403 +++++++++++++++++++------------------
>  include/linux/lockd/xdr.h  |   6 -
>  include/linux/lockd/xdr4.h |   7 +-
>  6 files changed, 610 insertions(+), 402 deletions(-)
>  create mode 100644 fs/lockd/svcxdr.h
> 
> --
> Chuck Lever
