Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54490 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753190AbdKJP3K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Nov 2017 10:29:10 -0500
Date: Fri, 10 Nov 2017 10:29:09 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        Bhumika Goyal <bhumirks@gmail.com>, julia.lawall@lip6.fr,
        trond.myklebust@primarydata.com, davem@davemloft.net,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Subject: Re: [PATCH 0/4] make function arg and structures as const
Message-ID: <20171110152909.GO8773@fieldses.org>
References: <1508256866-12798-1-git-send-email-bhumirks@gmail.com>
 <1508258427.4747.7.camel@redhat.com>
 <20171110022125.GA13874@fieldses.org>
 <7c61a3c8-4042-7b05-1298-e3abbef916c2@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <7c61a3c8-4042-7b05-1298-e3abbef916c2@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 10, 2017 at 10:09:46AM -0500, Anna Schumaker wrote:
> 
> 
> On 11/09/2017 09:21 PM, J. Bruce Fields wrote:
> > On Tue, Oct 17, 2017 at 12:40:27PM -0400, Jeff Layton wrote:
> >> On Tue, 2017-10-17 at 18:14 +0200, Bhumika Goyal wrote:
> >>> Make the function argument as const. After thing change, make
> >>> the cache_detail structures as const.
> >>>
> >>> Bhumika Goyal (4):
> >>>   sunrpc: make the function arg as const
> >>>   NFS: make cache_detail structures const
> >>>   NFSD: make cache_detail structures const
> >>>   SUNRPC: make cache_detail structures const
> >>>
> >>>  fs/nfs/dns_resolve.c              | 2 +-
> >>>  fs/nfsd/export.c                  | 4 ++--
> >>>  fs/nfsd/nfs4idmap.c               | 4 ++--
> >>>  include/linux/sunrpc/cache.h      | 2 +-
> >>>  net/sunrpc/auth_gss/svcauth_gss.c | 4 ++--
> >>>  net/sunrpc/cache.c                | 2 +-
> >>>  net/sunrpc/svcauth_unix.c         | 4 ++--
> >>>  7 files changed, 11 insertions(+), 11 deletions(-)
> >>>
> >>
> >> Looks pretty straightforward. You can add this to the set:
> >>
> >> Reviewed-by: Jeff Layton <jlayton@redhat.com>
> > 
> > Thanks, I've applied 1, 3, and 4 and could take #2 as well if it's OK
> > with Trond/Anna.
> 
> I don't mind taking #2, it's already in my branch :)

OK, thanks.--b.
