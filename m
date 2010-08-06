From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NFS use kernel DNS resolver
Date: Fri, 06 Aug 2010 22:00:13 +0100
Message-ID: <11355.1281128413@redhat.com>
References: <4C5C54A3.1010206@netapp.com> <1280970596.2865.28.camel@heimdal.trondhjem.org> <4C59D1A3.5030406@netapp.com> <13523.1281060342@redhat.com>
Cc: dhowells@redhat.com, Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Bryan Schumaker <bjschuma@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22427 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752473Ab0HFVAR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Aug 2010 17:00:17 -0400
In-Reply-To: <4C5C54A3.1010206@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bryan Schumaker <bjschuma@netapp.com> wrote:

> --- a/fs/nfs/dns_resolve.c
> +++ b/fs/nfs/dns_resolve.c
> ...
> +inline int nfs_dns_resolver_init(void)
> +{
> +	return 0;
> +}
> +
> +inline void nfs_dns_resolver_destroy(void)
> +{}

These functions are a little pointless since you do the same in the header
file, so I've removed them.  It still compiles...

David
