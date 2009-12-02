From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 5/9] sunrpc/cache: allow threads to block while waiting
 for cache update.
Date: Wed, 02 Dec 2009 16:50:55 -0500
Message-ID: <1259790655.25518.21.camel@localhost>
References: <20090909062539.20462.67466.stgit@notabene.brown>
	 <20090909063254.20462.99277.stgit@notabene.brown>
	 <20091202205928.GF15045@fieldses.org>  <1259788985.2663.38.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:39810 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755313AbZLBVvC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Dec 2009 16:51:02 -0500
In-Reply-To: <1259788985.2663.38.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-12-02 at 16:23 -0500, Trond Myklebust wrote: 
> Couldn't you also simplify things a good deal by just adding a
> completion to struct cache_deferred_req, and then letting
> cache_defer_req() call wait_for_completion_timeout()?

Better yet, the caller of cache_check() could decide whether or not to
also call wait_for_completion_timeout().

In addition to allowing the rpc server thread to wait upon the
authentication upcall, this could also simplify the nfsv4 server's
idmapper code, and the nfsv4 client's dns resolver code.


