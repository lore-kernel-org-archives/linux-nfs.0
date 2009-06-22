From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/5] nfsd: add support for NFSv4 callbacks over IPv6
 (try #2)
Date: Mon, 22 Jun 2009 11:50:40 -0400
Message-ID: <20090622115040.5bf55dd7@tlielax.poochiereds.net>
References: <1245436981-11806-1-git-send-email-jlayton@redhat.com>
	<C4F29AD4-164F-431D-9BEB-836717A6D65F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Bruce Fields <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33518 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754833AbZFVPun (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jun 2009 11:50:43 -0400
In-Reply-To: <C4F29AD4-164F-431D-9BEB-836717A6D65F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 22 Jun 2009 11:47:37 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:


> > 3) add patch that makes it set the sin6_scope_id for the callback
> > address to the same value as the sin6_scope_id in the svc_rqst- 
> > >rq_addr.
> > This allows the server to call back clients that mounted the server  
> > via
> > one of its link-local addresses.
> 
> The rpcbind XDR patches I'm working on provide a full universal  
> address 2 sockaddr conversion capability in sunrpc.ko, since several  
> unrelated features in NFS/NFSD/sunrpc appear to require it.  I think  
> the server-side callback client should use this common code instead of  
> having its own version.
> 
> The new code is in my git repo; you should be able to pull HEAD to  
> have a look.
> 

That sounds good. I'd rather use common code if it's present. I'll have
a look.

-- 
Jeff Layton <jlayton@redhat.com>
