Return-Path: <SRS0=RSPU=QN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC6A7C169C4
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 20:06:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C06F3217F9
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 20:06:05 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726691AbfBFUGF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Feb 2019 15:06:05 -0500
Received: from fieldses.org ([173.255.197.46]:54298 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726401AbfBFUGF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Feb 2019 15:06:05 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 88EB91CE7; Wed,  6 Feb 2019 15:06:04 -0500 (EST)
Date:   Wed, 6 Feb 2019 15:06:04 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1 0/2] Two small clean-ups for v5.1
Message-ID: <20190206200604.GA26258@fieldses.org>
References: <20190206170018.27481.32275.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190206170018.27481.32275.stgit@klimt.1015granger.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Feb 06, 2019 at 12:00:46PM -0500, Chuck Lever wrote:
> Hi Bruce-
> 
> Please consider these two commits for the v5.1 merge window.

Thanks, applying.--b.

> 
> ---
> 
> Chuck Lever (2):
>       svcrdma: Squelch compiler warning when SUNRPC_DEBUG is disabled
>       svcrdma: Remove syslog warnings in work completion handlers
> 
> 
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    9 +--------
>  net/sunrpc/xprtrdma/svc_rdma_rw.c        |   11 +----------
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    4 ----
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    9 +++------
>  4 files changed, 5 insertions(+), 28 deletions(-)
> 
> --
> Chuck Lever
