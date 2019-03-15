Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78D0FC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 18:11:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5788E2186A
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 18:11:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727266AbfCOSLr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 14:11:47 -0400
Received: from fieldses.org ([173.255.197.46]:33746 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727267AbfCOSLr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Mar 2019 14:11:47 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id A2AAA1CB3; Fri, 15 Mar 2019 14:11:46 -0400 (EDT)
Date:   Fri, 15 Mar 2019 14:11:46 -0400
To:     Jeff Layton <jlayton@kernel.org>
Cc:     bfields@fieldses.net, linux-nfs@vger.kernel.org
Subject: Re: [pynfs PATCH] nfs4.1: clean up the session and client created in
 Environment.init()
Message-ID: <20190315181146.GA13347@fieldses.org>
References: <20190314185641.1048-1-jlayton@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190314185641.1048-1-jlayton@kernel.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Mar 14, 2019 at 02:56:41PM -0400, Jeff Layton wrote:
> Once we've returned from this function the session and client will be
> abandoned on the server. Clean them up since we're finished with them
> at this point.

Thanks, applied.--b.

> 
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  nfs4.1/server41tests/environment.py | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
> index 0ce6943b19a5..bdfd52d3a171 100644
> --- a/nfs4.1/server41tests/environment.py
> +++ b/nfs4.1/server41tests/environment.py
> @@ -156,6 +156,8 @@ class Environment(testmod.Environment):
>          # Make sure it is empty
>          clean_dir(sess, self.opts.home)
>          sess.c.null()
> +        self.clean_sessions()
> +        self.clean_clients()
>  
>      def _maketree(self, sess):
>          """Make test tree"""
> -- 
> 2.20.1
