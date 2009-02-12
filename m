From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NLM] 2.6.27.14 breakage when grace period expires
Date: Thu, 12 Feb 2009 14:43:15 -0500
Message-ID: <1234467795.7190.70.camel@heimdal.trondhjem.org>
References: <20090211112318.GA29133@janus>
	 <20090211203555.GC27686@fieldses.org> <20090211203703.GA9662@janus>
	 <20090211203948.GD27686@fieldses.org> <20090212142830.GA28107@janus>
	 <1234451789.7190.38.camel@heimdal.trondhjem.org>
	 <20090212153634.GB28107@janus>
	 <1234462647.7190.53.camel@heimdal.trondhjem.org>
	 <20090212182943.GA1945@janus>
	 <1234465837.7190.62.camel@heimdal.trondhjem.org>
	 <03CEE6BB-D39D-47A5-BB6C-2FB3E206142F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <Chuck.Lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:51839 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758975AbZBLTnW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Feb 2009 14:43:22 -0500
In-Reply-To: <03CEE6BB-D39D-47A5-BB6C-2FB3E206142F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-02-12 at 14:35 -0500, Chuck Lever wrote:
> I wasn't sure exactly where the compared addresses came from.  I had  
> assumed that they all came through the listener, so we wouldn't need  
> this kind of translation.  It shouldn't be difficult to map addresses  
> passed in via nlmclnt_init() to AF_INET6.
> 
> But this is the kind of thing that makes "falling back" to an AF_INET  
> listener a little challenging.  We will have to record what flavor the  
> listener is and do a translation depending on what listener family was  
> actually created.

Why? Should we care whether we're receiving IPv4 addresses or IPv6
v4-mapped addresses? They're the same thing...

We're already doing the mapping for the NFSv4 callback channel. See
nfs_sockaddr_match_ipaddr() in fs/nfs/client.c

Trond

