Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18535C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 22:45:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E329421479
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 22:45:30 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728544AbfACWpa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 17:45:30 -0500
Received: from fieldses.org ([173.255.197.46]:39704 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728419AbfACWpa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Jan 2019 17:45:30 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id BDCE31E67; Thu,  3 Jan 2019 17:45:29 -0500 (EST)
Date:   Thu, 3 Jan 2019 17:45:29 -0500
From:   J Bruce Fields <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Don't allow compiler optimisation of
 svc_xprt_release_slot()
Message-ID: <20190103224529.GA6907@fieldses.org>
References: <20190103141712.24381-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190103141712.24381-1-trond.myklebust@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Jan 03, 2019 at 09:17:12AM -0500, Trond Myklebust wrote:
> Use READ_ONCE() to tell the compiler to not optimse away the read of
> xprt->xpt_flags in svc_xprt_release_slot().

What exactly is the possible race here?  And why is a READ_ONCE()
sufficient, as opposed to some memory barriers?

I may need to shut myself in a room with memory-barriers.txt, I'm pretty
hazy on these things.

--b.

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
>  net/sunrpc/svc_xprt.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 51d36230b6e3..94d344325e22 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -363,9 +363,11 @@ static void svc_xprt_release_slot(struct svc_rqst *rqstp)
>  
>  static bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
>  {
> -	if (xprt->xpt_flags & ((1<<XPT_CONN)|(1<<XPT_CLOSE)))
> +	unsigned long xpt_flags = READ_ONCE(xprt->xpt_flags);
> +
> +	if (xpt_flags & (BIT(XPT_CONN) | BIT(XPT_CLOSE)))
>  		return true;
> -	if (xprt->xpt_flags & ((1<<XPT_DATA)|(1<<XPT_DEFERRED))) {
> +	if (xpt_flags & (BIT(XPT_DATA) | BIT(XPT_DEFERRED))) {
>  		if (xprt->xpt_ops->xpo_has_wspace(xprt) &&
>  		    svc_xprt_slots_in_range(xprt))
>  			return true;
> -- 
> 2.20.1
