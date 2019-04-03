Return-Path: <SRS0=5sV6=SF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12AB8C4360F
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Apr 2019 00:36:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DA3422146E
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Apr 2019 00:36:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726694AbfDCAgY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 20:36:24 -0400
Received: from mx1.redhat.com ([209.132.183.28]:52494 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725912AbfDCAgY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 2 Apr 2019 20:36:24 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id B43FF3082A32;
        Wed,  3 Apr 2019 00:36:23 +0000 (UTC)
Received: from parsley.fieldses.org (ovpn-121-10.rdu2.redhat.com [10.10.121.10])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 8977A600D4;
        Wed,  3 Apr 2019 00:36:23 +0000 (UTC)
Received: by parsley.fieldses.org (Postfix, from userid 2815)
        id A832C180A39; Tue,  2 Apr 2019 20:36:22 -0400 (EDT)
Date:   Tue, 2 Apr 2019 20:36:22 -0400
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     Trond Myklebust <trondmy@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/6] Allow containerised knfsd to set supported NFS
 versions
Message-ID: <20190403003619.GA11222@parsley.fieldses.org>
References: <20190402231448.27743-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190402231448.27743-1-trond.myklebust@hammerspace.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Wed, 03 Apr 2019 00:36:23 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Apr 02, 2019 at 04:14:42PM -0700, Trond Myklebust wrote:
> The current knfsd implementation is unable to support containers that
> want to run different combinations of NFS versions. This is because of
> the way we define which versions are supported: by directly editing the
> global version table in 'nfsd_program'.
> The following patch set modifies the method used to define version
> information by moving some of the server RPC request initialisation
> down into knfsd itself, allowing it to manage the version-specific
> initialisation.

Sounds fine, though I'm curious what the motivation is.

I assume the current behavior is that setting versions from any
container sets them globally (rather than erroring out or something)--so
is there any way some can detect whether they've got the new behavior
other than trying it and seeing what the result is in another container?

--b.

> 
> Note that we might want to consider a few follow ups to this patchset
> to get rid of some of the version-specific flags (e.g. vs_hidden) that
> currently need to be managed in the generic SUNRPC server code on behalf
> of just one or two RPC programs. These flags can easily by replaced by
> custom RPC request initialisers.
> 
> Trond Myklebust (6):
>   SUNRPC/nfs: Fix return value for nfs4_callback_compound()
>   SUNRPC: Add a callback to initialise server requests
>   SUNRPC: Clean up generic dispatcher code
>   SUNRPC: Allow further customisation of RPC program registration
>   nfsd: Add custom rpcbind callbacks for knfsd
>   nfsd: Allow containers to set supported nfs versions
> 
>  fs/lockd/svc.c             |   4 +-
>  fs/nfs/callback.c          |   2 +
>  fs/nfs/callback_xdr.c      |   2 +-
>  fs/nfsd/netns.h            |   8 +
>  fs/nfsd/nfs4proc.c         |   3 +-
>  fs/nfsd/nfsctl.c           |  25 +--
>  fs/nfsd/nfsd.h             |   8 +-
>  fs/nfsd/nfssvc.c           | 251 +++++++++++++++++++++++++-----
>  include/linux/sunrpc/svc.h |  33 ++++
>  net/sunrpc/svc.c           | 310 ++++++++++++++++++++++++-------------
>  10 files changed, 480 insertions(+), 166 deletions(-)
> 
> -- 
> 2.20.1
> 
