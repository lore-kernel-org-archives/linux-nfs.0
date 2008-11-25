From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/6] SLAB-ify nlm_host cache
Date: Mon, 24 Nov 2008 22:39:22 -0500
Message-ID: <1227584362.7734.197.camel@heimdal.trondhjem.org>
References: <20081105215042.16549.50065.stgit@ingres.1015granger.net>
	 <1225922196.16857.60.camel@heimdal.trondhjem.org>
	 <20081124183836.GM17862@fieldses.org>
	 <4ABE8727-9E3A-434C-9421-852165F10699@oracle.com>
	 <1227557730.7734.39.camel@heimdal.trondhjem.org>
	 <DEE8B8E0-80E4-4D2E-A388-4FEF6AC6AA31@oracle.com>
	 <1227572626.7734.182.camel@heimdal.trondhjem.org>
	 <B61B380F-A803-4CC4-BA3C-0D7C7A485C01@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:55199 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752915AbYKYDjc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Nov 2008 22:39:32 -0500
In-Reply-To: <B61B380F-A803-4CC4-BA3C-0D7C7A485C01@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-11-24 at 20:48 -0500, Chuck Lever wrote:

> On the client-side, I don't think we need GC at all.  The client holds  
> a reference to the nlm_host as long as the file system is mounted.  It  
> can simply release the nlm_host and nsm_handle when it unmounts the  
> server.  When the last nlm_host that refers to an nsm_handle goes  
> away, the client sends an SM_UNMON to the server and the nsm_handle  
> goes away.  Done.

No, Chuck.

Vetoed...

Trond

