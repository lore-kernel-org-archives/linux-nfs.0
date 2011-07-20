Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54948 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751584Ab1GTVKq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jul 2011 17:10:46 -0400
Date: Wed, 20 Jul 2011 17:10:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 0/9] sunrpc: Create sockets in namespaces
Message-ID: <20110720211040.GC27871@fieldses.org>
References: <4CA32AB4.2090808@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CA32AB4.2090808@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Just curious--is there still work left on nfs and rpc containerization?
And what's left to do there?

--b.

On Wed, Sep 29, 2010 at 04:01:56PM +0400, Pavel Emelyanov wrote:
> v3 changes:
> Moved the generic xprt alloc/free code to xprt.c.
> Got David's ack on the 8th patch :)
> 
> v2 changes:
> Fixed comments from Chuck and Trond.
> Added one patch, that factors out rpc_xprt allocation as well.
> 
> v1:
> This set implements pulling the net * argument down to the existing
> sock_create_kern calls in the sunrpc layer and creating the sockets
> in the given net.
> 
> Thanks,
> Pavel
