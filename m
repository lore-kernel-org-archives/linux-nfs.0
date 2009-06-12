From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 3/3] SUNRPC: Use AUTH_NULL for GETPORT/GETADDR requests
Date: Fri, 12 Jun 2009 17:30:23 -0400
Message-ID: <1244842223.32257.14.camel@heimdal.trondhjem.org>
References: <20090515153111.17053.3822.stgit@ingres.1015granger.net>
	 <20090515153309.17053.44496.stgit@ingres.1015granger.net>
	 <1244840937.32257.6.camel@heimdal.trondhjem.org>
	 <49BC11A9-3E49-4D41-9C25-8214BFADFE3C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53129 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751520AbZFLVaW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jun 2009 17:30:22 -0400
In-Reply-To: <49BC11A9-3E49-4D41-9C25-8214BFADFE3C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-06-12 at 17:17 -0400, Chuck Lever wrote:
> On Jun 12, 2009, at 5:08 PM, Trond Myklebust wrote:
> 
> > On Fri, 2009-05-15 at 11:33 -0400, Chuck Lever wrote:
> >> rpcbind servers do not require RPC authentication, so AUTH_NULL is  
> >> all
> >> that is needed.  This saves a few bytes on the wire, and a bit of
> >> computational expense on both ends.
> >
> > This certainly isn't the case for all portmap implementations.
> 
> What implementations require AUTH_SYS ?  The libtirpc and glibc  
> rpcb_getaddr/pmap_getport implementations use NULL, as far as I can  
> tell.  libtirpc rpcb_set uses a local socket, which does local  
> authentication.  pmap_set in glib uses NULL, I think.

I just have a vague memory at the back of my head that the last time we
tried this, we had to revert the change because some portmapper variant
was rejecting it.

The right thing might be simply be to add a handler for the
AUTH_TOO_WEAK error.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
