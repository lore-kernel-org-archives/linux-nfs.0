Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:12945 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962Ab3AXFWp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jan 2013 00:22:45 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 5/7] nfsd4: rewrite xdr encoding of attributes
Date: Thu, 24 Jan 2013 05:22:43 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9183350A5@sacexcmbx05-prd.hq.netapp.com>
References: <1358981738-5649-1-git-send-email-bfields@redhat.com>
	 <1358981738-5649-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1358981738-5649-6-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-01-23 at 17:55 -0500, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Write xdr encoding primitives that can handle crossing page boundaries,
> and use them in nfsd4_encode_fattr.
> 
> The main practical advantage for now is that we can return arbitrarily
> large ACLs (well, up to our maximum rpc size).  However, compounds with
> other operations following such a getattr may fail.
> 
> Eventually we plan to use the same xdr code through v4 at least.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfs4proc.c |   6 +-
>  fs/nfsd/nfs4xdr.c  | 705 +++++++++++++++++++++++++++++++++++------------------
>  fs/nfsd/xdr4.h     |  18 +-
>  3 files changed, 483 insertions(+), 246 deletions(-)
> 

Why do these belong in the NFS server layer, and not the SUNRPC layer?

Also, why are you inventing an entirely new server-specific structure
instead of just reusing the existing struct xdr_stream? The xdr_stream
already has support for bounce buffers to deal with crossing page
boundaries (although I've only implemented the decode side of the
equation so far)...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
