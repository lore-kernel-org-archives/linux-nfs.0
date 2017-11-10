Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53404 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751808AbdKJCV0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 21:21:26 -0500
Date: Thu, 9 Nov 2017 21:21:25 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>, julia.lawall@lip6.fr,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        davem@davemloft.net, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Subject: Re: [PATCH 0/4] make function arg and structures as const
Message-ID: <20171110022125.GA13874@fieldses.org>
References: <1508256866-12798-1-git-send-email-bhumirks@gmail.com>
 <1508258427.4747.7.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1508258427.4747.7.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 17, 2017 at 12:40:27PM -0400, Jeff Layton wrote:
> On Tue, 2017-10-17 at 18:14 +0200, Bhumika Goyal wrote:
> > Make the function argument as const. After thing change, make
> > the cache_detail structures as const.
> > 
> > Bhumika Goyal (4):
> >   sunrpc: make the function arg as const
> >   NFS: make cache_detail structures const
> >   NFSD: make cache_detail structures const
> >   SUNRPC: make cache_detail structures const
> > 
> >  fs/nfs/dns_resolve.c              | 2 +-
> >  fs/nfsd/export.c                  | 4 ++--
> >  fs/nfsd/nfs4idmap.c               | 4 ++--
> >  include/linux/sunrpc/cache.h      | 2 +-
> >  net/sunrpc/auth_gss/svcauth_gss.c | 4 ++--
> >  net/sunrpc/cache.c                | 2 +-
> >  net/sunrpc/svcauth_unix.c         | 4 ++--
> >  7 files changed, 11 insertions(+), 11 deletions(-)
> > 
> 
> Looks pretty straightforward. You can add this to the set:
> 
> Reviewed-by: Jeff Layton <jlayton@redhat.com>

Thanks, I've applied 1, 3, and 4 and could take #2 as well if it's OK
with Trond/Anna.

--b.
