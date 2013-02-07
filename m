Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41369 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754000Ab3BGPLD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2013 10:11:03 -0500
Date: Thu, 7 Feb 2013 10:11:02 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 0/2] nfsd: checksum first 256 bytes of request to
 guard against XID collisions in the DRC
Message-ID: <20130207151102.GD3222@fieldses.org>
References: <1360248701-23963-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1360248701-23963-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 07, 2013 at 09:51:39AM -0500, Jeff Layton wrote:
> This patchset is a respin of the ones that Bruce has not yet committed
> of my DRC overhaul. The main difference is the first patch, which adds a
> routine to strip the trailing checksum off of decrypted or
> integrity-verified buffer.
> 
> I've tested both the client and server with different krb5 flavors (and
> using both the v1 and v2 codepaths) and it seems to work fine with those
> checksum blobs stripped off.
> 
> I think we should consider this for 3.9 since XID collisions are a lot
> more likely now with the new DRC code in place.

Looks good--applying for 3.9 absent any objections.

--b.

> 
> Jeff Layton (2):
>   sunrpc: trim off trailing checksum before returning decrypted or
>     integrity authenticated buffer
>   nfsd: keep a checksum of the first 256 bytes of request
> 
>  fs/nfsd/cache.h                     |  5 ++++
>  fs/nfsd/nfscache.c                  | 53 ++++++++++++++++++++++++++++++++++---
>  include/linux/sunrpc/xdr.h          |  1 +
>  net/sunrpc/auth_gss/gss_krb5_wrap.c |  2 ++
>  net/sunrpc/auth_gss/svcauth_gss.c   | 10 +++++--
>  net/sunrpc/xdr.c                    | 42 +++++++++++++++++++++++++++++
>  6 files changed, 107 insertions(+), 6 deletions(-)
> 
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
