Return-Path: <SRS0=Q61g=BB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E96D5C433DF
	for <linux-nfs@archiver.kernel.org>; Wed, 22 Jul 2020 14:11:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B07E920709
	for <linux-nfs@archiver.kernel.org>; Wed, 22 Jul 2020 14:11:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="AJXMzsgB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727825AbgGVOLZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 22 Jul 2020 10:11:25 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48668 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726973AbgGVOLZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jul 2020 10:11:25 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id E1EFAC0619DC
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2020 07:11:24 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 1AA13876B; Wed, 22 Jul 2020 10:11:24 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 1AA13876B
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1595427084;
        bh=kp5ieLlSgXf2H6hGaNQIRISvfrl8r/TifTVbnsXTlxw=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=AJXMzsgBxdCl4fqAEhE+7Mch3L7ooiCfPUOn1KGxoKsASH/1DK0zdZg+NkM7c2hUf
         mK+vAgyv9VgKinAL71yjKe5F3xiiCpHcO6VwlyL3+xXFzF0eKJscFiAidCQzxh1+i2
         U7Xo1uuUgzLxc1+rd7G139Nsr3U3k8DfHYpAkBuU=
Date:   Wed, 22 Jul 2020 10:11:24 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH] generic currentstateid test of should not require
 pnfs-aware session
Message-ID: <20200722141124.GB28219@fieldses.org>
References: <20200721191628.16970-1-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200721191628.16970-1-tigran.mkrtchyan@desy.de>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Jul 21, 2020 at 09:16:28PM +0200, Tigran Mkrtchyan wrote:
> CSID8 doesn't depend on pnfs capability of a server, thus should not
> create pnfs-aware session.

Thanks!--b.

> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  nfs4.1/server41tests/st_current_stateid.py | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/nfs4.1/server41tests/st_current_stateid.py b/nfs4.1/server41tests/st_current_stateid.py
> index 8882e96..6480ae9 100644
> --- a/nfs4.1/server41tests/st_current_stateid.py
> +++ b/nfs4.1/server41tests/st_current_stateid.py
> @@ -164,7 +164,7 @@ def testOpenSetattr(t, env):
>      CODE: CSID8
>      """
>      size = 8
> -    sess = env.c1.new_pnfs_client_session(env.testname(t))
> +    sess = env.c1.new_client_session(env.testname(t))
>  
>      open_op = open_create_file_op(sess, env.testname(t), open_create=OPEN4_CREATE)
>      res = sess.compound( open_op +
> -- 
> 2.26.2
