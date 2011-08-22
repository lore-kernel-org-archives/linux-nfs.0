Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56820 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753353Ab1HVT0W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Aug 2011 15:26:22 -0400
Date: Mon, 22 Aug 2011 15:26:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] sunrpc: Add scope id to svc_addr_u for IPv6 LINKLOCAL
 address
Message-ID: <20110822192620.GB16261@fieldses.org>
References: <4E4F8B5D.6060404@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E4F8B5D.6060404@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Aug 20, 2011 at 06:24:29PM +0800, Mi Jinlong wrote:
> +/* 
> + * Add scope id for LINKLOCAL address
> + */
> +struct in6_addr_scopeid{
> +	struct in6_addr	sin6_addr;
> +	__u32		sin6_scope_id;
> +};
> +
>  union svc_addr_u {
> -    struct in_addr	addr;
> -    struct in6_addr	addr6;
> +	struct in_addr		addr;
> +	struct in6_addr_scopeid	addr6;

By the way, is there any reason why nfsd really needs its own address
structure?  Shouldn't we use sockaddr_storage or something?  I feel like
we've got a little too much one-off address handling in nfsd.

--b.
