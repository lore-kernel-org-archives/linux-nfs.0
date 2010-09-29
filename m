From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v3 0/9] sunrpc: Create sockets in namespaces
Date: Wed, 29 Sep 2010 17:45:27 -0400
Message-ID: <20100929214527.GC26180@fieldses.org>
References: <4CA32AB4.2090808@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38096 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753914Ab0I2Vpl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Sep 2010 17:45:41 -0400
In-Reply-To: <4CA32AB4.2090808@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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

Shall I commit this to my for-2.6.37 tree?  Objections?

--b.
