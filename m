Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:51605 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935888AbdJQQk3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Oct 2017 12:40:29 -0400
Received: by mail-qt0-f169.google.com with SMTP id h4so4862955qtk.8
        for <linux-nfs@vger.kernel.org>; Tue, 17 Oct 2017 09:40:29 -0700 (PDT)
Message-ID: <1508258427.4747.7.camel@redhat.com>
Subject: Re: [PATCH 0/4] make function arg and structures as const
From: Jeff Layton <jlayton@redhat.com>
To: Bhumika Goyal <bhumirks@gmail.com>, julia.lawall@lip6.fr,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@fieldses.org, davem@davemloft.net,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Date: Tue, 17 Oct 2017 12:40:27 -0400
In-Reply-To: <1508256866-12798-1-git-send-email-bhumirks@gmail.com>
References: <1508256866-12798-1-git-send-email-bhumirks@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-10-17 at 18:14 +0200, Bhumika Goyal wrote:
> Make the function argument as const. After thing change, make
> the cache_detail structures as const.
> 
> Bhumika Goyal (4):
>   sunrpc: make the function arg as const
>   NFS: make cache_detail structures const
>   NFSD: make cache_detail structures const
>   SUNRPC: make cache_detail structures const
> 
>  fs/nfs/dns_resolve.c              | 2 +-
>  fs/nfsd/export.c                  | 4 ++--
>  fs/nfsd/nfs4idmap.c               | 4 ++--
>  include/linux/sunrpc/cache.h      | 2 +-
>  net/sunrpc/auth_gss/svcauth_gss.c | 4 ++--
>  net/sunrpc/cache.c                | 2 +-
>  net/sunrpc/svcauth_unix.c         | 4 ++--
>  7 files changed, 11 insertions(+), 11 deletions(-)
> 

Looks pretty straightforward. You can add this to the set:

Reviewed-by: Jeff Layton <jlayton@redhat.com>
