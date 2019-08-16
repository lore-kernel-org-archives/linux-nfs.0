Return-Path: <SRS0=x+rs=WM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99A33C3A59E
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Aug 2019 16:06:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7BE6D2173B
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Aug 2019 16:06:52 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727352AbfHPQGv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 16 Aug 2019 12:06:51 -0400
Received: from fieldses.org ([173.255.197.46]:35722 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727300AbfHPQGv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Aug 2019 12:06:51 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 234D21E67; Fri, 16 Aug 2019 12:06:51 -0400 (EDT)
Date:   Fri, 16 Aug 2019 12:06:51 -0400
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH v1 0/2] NFS/RDMA-related NFSD patches for -next
Message-ID: <20190816160651.GB4234@fieldses.org>
References: <156390950940.6811.3316103129070572088.stgit@seurat29.1015granger.net>
 <BFF3E871-D4B1-4692-A39B-B693BFE85899@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BFF3E871-D4B1-4692-A39B-B693BFE85899@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Aug 06, 2019 at 11:55:29AM -0400, Chuck Lever wrote:
> Would you consider these for v5.4?

Apologies, I can't find these in my mail anywhere, for some
reason--would you mind resending?

--b.

> 
> 
> > On Jul 23, 2019, at 3:20 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> > 
> > Hi-
> > 
> > Two server side patches for NFSD. Both are minor.
> > 
> > ---
> > 
> > Chuck Lever (2):
> >      svcrdma: Remove svc_rdma_wq
> >      svcrdma: Use llist for managing cache of recv_ctxts
> > 
> > 
> > include/linux/sunrpc/svc_rdma.h          |    6 +++---
> > net/sunrpc/xprtrdma/svc_rdma.c           |    7 -------
> > net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   24 ++++++++++--------------
> > net/sunrpc/xprtrdma/svc_rdma_transport.c |    6 +++---
> > 4 files changed, 16 insertions(+), 27 deletions(-)
> > 
> > --
> > Chuck Lever
