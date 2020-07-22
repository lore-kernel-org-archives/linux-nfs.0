Return-Path: <SRS0=Q61g=BB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5099BC433E1
	for <linux-nfs@archiver.kernel.org>; Wed, 22 Jul 2020 13:58:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 15B0A20771
	for <linux-nfs@archiver.kernel.org>; Wed, 22 Jul 2020 13:58:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="rcyuRj6y"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731994AbgGVN6l (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 22 Jul 2020 09:58:41 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46704 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727825AbgGVN6k (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jul 2020 09:58:40 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id DA5A2C0619DC
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2020 06:58:40 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id B549FABE; Wed, 22 Jul 2020 09:58:39 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org B549FABE
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1595426319;
        bh=lQoibhjBNmDpCkga6l+ITXrhVQpKfleTVRZKosYXYm4=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=rcyuRj6yXGRcjjeWwcp7rUu5cDYzE2KhoCI+3OCOp4AMtfpiuZBt2v3aPpUXgDY+9
         F/gXWcrWAkvZJc0/axbQWkdChDeVG8038AXWEHdx9dTUV9BriFYGb8v+wAdeYhcwH8
         i0vnEEGno3LowPtIG6B8oZ2OowvW8Jh56vEBs0s8=
Date:   Wed, 22 Jul 2020 09:58:39 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs41client: fix raising an error when pnfs test hits
 non pnfs server
Message-ID: <20200722135839.GA28219@fieldses.org>
References: <20200721194358.18132-1-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200721194358.18132-1-tigran.mkrtchyan@desy.de>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Jul 21, 2020 at 09:43:58PM +0200, Tigran Mkrtchyan wrote:
> fail function is not defined

It's used elsewhere, e.g. st_sequence.py, I think we just need an
import.

> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  nfs4.1/nfs4client.py | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
> index f06d9c5..3d55f96 100644
> --- a/nfs4.1/nfs4client.py
> +++ b/nfs4.1/nfs4client.py
> @@ -1,7 +1,7 @@
>  import use_local # HACK so don't have to rebuild constantly
>  import rpc.rpc as rpc
>  import nfs4lib
> -from nfs4lib import NFS4Error, NFS4Replay, inc_u32
> +from nfs4lib import NFS4Error, NFS4Replay, inc_u32, UnexpectedCompoundRes
>  from xdrdef.nfs4_type import *
>  from xdrdef.nfs4_const import *
>  from xdrdef.sctrl_pack import SCTRLPacker, SCTRLUnpacker
> @@ -331,7 +331,7 @@ class NFS4Client(rpc.Client, rpc.Server):
>          # Make sure E_ID returns MDS capabilities
>          c = self.new_client(name, flags=flags)
>          if not c.flags & EXCHGID4_FLAG_USE_PNFS_MDS:
> -            fail("Server can not be used as pnfs metadata server")
> +            raise UnexpectedCompoundRes("Server can not be used as pnfs metadata server")
>          s = c.create_session(sec=sec)
>          s.compound([op4.reclaim_complete(FALSE)])
>          return s
> -- 
> 2.26.2
