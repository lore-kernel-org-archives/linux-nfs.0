Return-Path: <SRS0=QgGt=SL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BA50C10F0E
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 20:09:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1C3652084C
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 20:09:31 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726517AbfDIUJa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 16:09:30 -0400
Received: from fieldses.org ([173.255.197.46]:38246 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726496AbfDIUJ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Apr 2019 16:09:29 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 5008A1CEE; Tue,  9 Apr 2019 16:09:29 -0400 (EDT)
Date:   Tue, 9 Apr 2019 16:09:29 -0400
To:     Trond Myklebust <trondmy@gmail.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/6] Allow containerised knfsd to set supported NFS
 versions
Message-ID: <20190409200929.GA29099@fieldses.org>
References: <20190409154619.33615-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190409154619.33615-1-trond.myklebust@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Apr 09, 2019 at 11:46:13AM -0400, Trond Myklebust wrote:
> The current knfsd implementation is unable to support containers that
> want to run different combinations of NFS versions. This is because of
> the way we define which versions are supported: by directly editing the
> global version table in 'nfsd_program'.
> The following patch set modifies the method used to define version
> information by moving some of the server RPC request initialisation
> down into knfsd itself, allowing it to manage the version-specific
> initialisation.
> 
> Note that we might want to consider a few follow ups to this patchset
> to get rid of some of the version-specific flags (e.g. vs_hidden) that
> currently need to be managed in the generic SUNRPC server code on behalf
> of just one or two RPC programs. These flags can easily by replaced by
> custom RPC request initialisers.
> 
> ---
> v2: Fix compile issues when CONFIG_NFSD_V2_ACL and CONFIG_NFSD_V3_ACL
>     are undefined.
>     Don't move the svc_reserve() call in svc_process_common(), since
>     that can trigger 'RPC request reserved xxx but used yyy' issues.

Thanks!  I've applied this revised version.

--b.

> 
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
>  fs/nfsd/nfsctl.c           |  25 ++--
>  fs/nfsd/nfsd.h             |   8 +-
>  fs/nfsd/nfssvc.c           | 255 +++++++++++++++++++++++++------
>  include/linux/sunrpc/svc.h |  33 ++++
>  net/sunrpc/svc.c           | 298 ++++++++++++++++++++++++-------------
>  10 files changed, 478 insertions(+), 160 deletions(-)
> 
> -- 
> 2.20.1
