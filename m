Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47650 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752705Ab2C2OcT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Mar 2012 10:32:19 -0400
Date: Thu, 29 Mar 2012 10:32:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [PATCH 0/8] NFSd: precursor and cleanup patch set
Message-ID: <20120329143218.GI16938@fieldses.org>
References: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120328150152.2646.33607.stgit@localhost6.localdomain6>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 28, 2012 at 07:08:53PM +0400, Stanislav Kinsbursky wrote:
> This patch set prepares ground for making NFSd export and expkey caches
> allocated and registered per network namespace context.
> Mainly, it just replaces hard-coded pointers with dereferenced everywhere
> required.

Thanks.  I'll be travelling next week and may not get to look at this
till I get back.

--b.

> 
> The following series consists of:
> 
> ---
> 
> Stanislav Kinsbursky (8):
>       nfsd: use passed cache_detail pointer expkey_parse()
>       nfsd: add link to owner cache detail to svc_export structure
>       nfsd: use cache detail pointer from svc_export structure on cache put
>       nfsd: use exp_put() for svc_export_cache put
>       nfsd: pass svc_export_cache pointer as private data to "exports" seq file ops
>       nfsd: use hash table from cache detail in nfsd export seq ops
>       nfsd: pass pointer to export cache down to stack wherever possible.
>       nfsd: pass pointer to expkey cache down to stack wherever possible.
> 
> 
>  fs/nfsd/export.c            |  102 ++++++++++++++++++++++++-------------------
>  fs/nfsd/nfsctl.c            |   11 ++++-
>  fs/nfsd/nfsfh.c             |    2 -
>  include/linux/nfsd/export.h |    3 +
>  4 files changed, 71 insertions(+), 47 deletions(-)
> 
