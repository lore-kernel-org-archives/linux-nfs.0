Return-Path: <SRS0=LIrp=S3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25560C43219
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 15:34:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 54434205ED
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 15:34:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727814AbfDYPdk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Apr 2019 11:33:40 -0400
Received: from fieldses.org ([173.255.197.46]:51102 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727192AbfDYPdj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Apr 2019 11:33:39 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 3D8931C98; Thu, 25 Apr 2019 11:33:39 -0400 (EDT)
Date:   Thu, 25 Apr 2019 11:33:39 -0400
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH 6/9] NFSv4: Convert the NFS client idmapper to use the
 container user namespace
Message-ID: <20190425153339.GB8133@fieldses.org>
References: <20190424214650.4658-1-trond.myklebust@hammerspace.com>
 <20190424214650.4658-2-trond.myklebust@hammerspace.com>
 <20190424214650.4658-3-trond.myklebust@hammerspace.com>
 <20190424214650.4658-4-trond.myklebust@hammerspace.com>
 <20190424214650.4658-5-trond.myklebust@hammerspace.com>
 <20190424214650.4658-6-trond.myklebust@hammerspace.com>
 <20190424214650.4658-7-trond.myklebust@hammerspace.com>
 <20190425143243.GA8133@fieldses.org>
 <e94c2488d89ae13675f9931d013a3d711459ecad.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e94c2488d89ae13675f9931d013a3d711459ecad.camel@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Apr 25, 2019 at 03:00:22PM +0000, Trond Myklebust wrote:
> The assumption is that if you have enough privileges to mount a
> filesystem using the NFS client, then you would also have enough
> privileges to run a userspace client, so there is little point in
> restricting the NFS client.
> 
> So the guiding principle is that a NFS client mount that is started in
> a container should behave as if it were started by a process in a "real
> VM". That means that the root uid/gid in the container maps to a root
> uid/gid on the wire.
> Ditto, if there is a need to run the idmapper in the container, then
> the expectation is that processes running as 'user' with uid 'u', will
> see their creds mapped correctly by the idmapper. Again, that's what
> you would see if the process were running in a VM instead of a
> container.
> 
> Does that all make sense?

Yes, thanks!

I thought there was a problem that the idmapper depended on
keyring usermodehelper calls that it was hard to pass namespace
information to.  Did that get fixed and I missed it or or forgot?

> 
> So this means that any orchestrator software which may be setting up
> NFS mounts as part of setting up the container has 2 options:
> 
>    1. Either perform the mount outside the container namespaces, in which
>       case the container process uids/gids are mapped from their
>       user_namespace into the user_namespace of the orchestrator, and the
>       uids/gids on the wire will reflect those mapped uids/gids (so uid 0
>       in the container will be mapped to uid xxx where xxx is decided by
>       the orchestrator).
>    2. Perform the mount inside the container namespaces, in which case the
>       container process uids/gids go on the wire as-is.

OK, great, that sounds perfect.

--b.
