From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] SUNRPC: RPC client's TCP transport ignores errors
	during connect
Date: Tue, 08 Apr 2008 13:55:50 -0400
Message-ID: <1207677350.11699.9.camel@heimdal.trondhjem.org>
References: <20080408173602.21776.60671.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20804 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752802AbYDHR4G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2008 13:56:06 -0400
In-Reply-To: <20080408173602.21776.60671.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-04-08 at 13:38 -0400, Chuck Lever wrote:
> Commits 66af1e55 through 663b8858 recently changed how
> xs_tcp_state_change() awakens RPC tasks in order to address problems
> with disconnection of TCP sockets that were already connected.
> 
> The generic function xprt_connect_status() is invoked during a transport
> connection operation by this wake-up.  It expects a specific error value
> describing the connection failure, but currently always gets ENOTCONN.

Does it? AFAICS, the only errors that it cares about are ETIMEDOUT,
ENOTCONN, ECONNRESET, and ECONNREFUSED, and the only effect is change
the dprintk() message.

OTOH, call_connect_status() will cause the task to exit with an EIO if
ever it gets sent an ECONNRESET or ECONNREFUSED.

IOW: I'm sceptical to this change.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
