Return-Path: <SRS0=HAHT=O6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EEF5C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 01:00:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5BD34218FE
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 01:00:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731233AbeLUBAH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Dec 2018 20:00:07 -0500
Received: from fieldses.org ([173.255.197.46]:49254 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729428AbeLUBAH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Dec 2018 20:00:07 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 258BB1C96; Thu, 20 Dec 2018 20:00:07 -0500 (EST)
Date:   Thu, 20 Dec 2018 20:00:07 -0500
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "vvs@virtuozzo.com" <vvs@virtuozzo.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "khorenko@virtuozzo.com" <khorenko@virtuozzo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "eshatokhin@virtuozzo.com" <eshatokhin@virtuozzo.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "jlayton@kernel.org" <jlayton@kernel.org>
Subject: Re: [PATCH 1/4] nfs: use-after-free in svc_process_common()
Message-ID: <20181221010007.GA10196@fieldses.org>
References: <134cf19c-e698-abed-02de-1659f9a5d4fb@virtuozzo.com>
 <20181217215026.GA8564@fieldses.org>
 <cb8d51ae-2745-58ca-8b4d-86c7a4bd2ffe@virtuozzo.com>
 <67f477b704d34b369f0530891a219f383f964001.camel@hammerspace.com>
 <4d878140-02c0-e306-fee6-1573d9fdecf2@virtuozzo.com>
 <068f1741afc54367853a2e4501fd95c2ab12a989.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <068f1741afc54367853a2e4501fd95c2ab12a989.camel@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Dec 18, 2018 at 02:55:15PM +0000, Trond Myklebust wrote:
> No. We don't care about xpt_flags for the back channel because there is
> no "server transport". The actual transport is stored in the 'struct
> rpc_rqst', and is the struct rpc_xprt corresponding to the client
> socket or RDMA channel.
> 
> IOW: All we really need in svc_process_common() is to be able to run
> rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(), and that can be passed
> either as a pointer to the struct svc_xprt_ops itself.

For what it's worth, I'd rather get rid of that op--it's an awfully
roundabout way just to do "svc_putnl(resv, 0);" in the tcp case.

--b.
