From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/8] sunrpc: Create sockets in namespaces
Date: Mon, 27 Sep 2010 15:10:02 -0400
Message-ID: <20100927191002.GB14000@fieldses.org>
References: <4CA06C7A.5060307@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43500 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757175Ab0I0TKI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 15:10:08 -0400
In-Reply-To: <4CA06C7A.5060307@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 27, 2010 at 02:05:46PM +0400, Pavel Emelyanov wrote:
> Hi!
> 
> This set implements pulling the net * argument down to the existing
> sock_create_kern calls in the sunrpc layer and creating the sockets
> in the given net.
> 
> Patch #7 opens the __sock_create for public and I hope we can do it
> not in the Dave's tree :)
> 
> Applies to git://linux-nfs.org/~bfields/linux.git nfsd-next after the
> ip_map_cache virtualization patch set I sent before.

They look fine to me.

--b.
