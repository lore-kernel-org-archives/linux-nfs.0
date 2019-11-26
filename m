Return-Path: <SRS0=F8lJ=ZS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EA82C432C0
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Nov 2019 16:38:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5E8212080F
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Nov 2019 16:38:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728521AbfKZQix (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Nov 2019 11:38:53 -0500
Received: from smtprelay0181.hostedemail.com ([216.40.44.181]:41130 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1725995AbfKZQix (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Nov 2019 11:38:53 -0500
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
        by smtprelay05.hostedemail.com (Postfix) with ESMTP id 6652118028E8F;
        Tue, 26 Nov 2019 16:38:52 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: order07_302b770f34016
X-Filterd-Recvd-Size: 1486
Received: from XPS-9350.home (unknown [47.151.135.224])
        (Authenticated sender: joe@perches.com)
        by omf06.hostedemail.com (Postfix) with ESMTPA;
        Tue, 26 Nov 2019 16:38:50 +0000 (UTC)
Message-ID: <99648842d1cfaaabd7178fe55e8f287a87e18a6a.camel@perches.com>
Subject: Re: [PATCH] net: sunrpc:  replace 0 with NULL
From:   Joe Perches <joe@perches.com>
To:     Jules Irenge <jbi.octave@gmail.com>,
        trond.myklebust@hammerspace.com
Cc:     anna.schumaker@netapp.com, davem@davemloft.net,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date:   Tue, 26 Nov 2019 08:38:24 -0800
In-Reply-To: <20191125225239.384343-1-jbi.octave@gmail.com>
References: <20191125225239.384343-1-jbi.octave@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.34.1-2 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 2019-11-25 at 22:52 +0000, Jules Irenge wrote:
> Replace 0 with NULL to fix warning detected by sparse tool.
> warning: Using plain integer as NULL pointer
[]
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
[]
> @@ -614,7 +614,7 @@ xs_read_stream_reply(struct sock_xprt *transport, struct msghdr *msg, int flags)
>  static ssize_t
>  xs_read_stream(struct sock_xprt *transport, int flags)
>  {
> -	struct msghdr msg = { 0 };
> +	struct msghdr msg = { NULL };

Rather than depending on the first member to be a pointer
perhaps better to use the equivalent

	struct msghdr msg = {};


