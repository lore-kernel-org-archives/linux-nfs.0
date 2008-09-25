From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 3/3] NFS: SETCLIENTID truncates client ID and netid
Date: Thu, 25 Sep 2008 12:10:26 -0400
Message-ID: <1222359026.13388.8.camel@localhost>
References: <20080925154814.8353.64762.stgit@manray.1015granger.net>
	 <20080925155712.8353.47707.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1446 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751506AbYIYQVw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Sep 2008 12:21:52 -0400
In-Reply-To: <20080925155712.8353.47707.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-09-25 at 11:57 -0400, Chuck Lever wrote:
> The sc_name field is currently 56 bytes long.  This is not large enough
> to hold a pair of IPv6 addresses, the authentication type, the protocol
> name, and a uniquifier number.  The maximum possible size of the name
> string using IPv6 addresses is just under 110 bytes, so I increased the
> size of the sc_name field to accomodate this maximum.
> 
> In addition, the strings in the nfs4_setclientid structure are
> constructed with scnprintf(), which wants to terminate its output with
> '\0'.  The sc_netid field was large enough only for a three byte netid
> string and a '\0' so inet6 netids were being truncated.  Perhaps we
> don't need the overhead of scnprintf() to do a simple string copy, but
> I fixed this by increasing the size of the buffer by one byte.
> 
> Since all three of the string buffers in nfs4_setclientid are
> constructed with scnprintf(), I increased the size of all three by one
> byte to document the requirement, although I don't think either the
> universal address field or the name field will be so small that these
> strings get truncated in this way.
> 
> The size of the Linux client's client ID on the wire will be larger
> than before.  RFC 3530 suggests the size limit for client IDs is 1024,
> and we are still well below that.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

ACK. I'll take this patch, but should Bruce take the other 2? I believe
he should already have other changes to rpcb_clnt.c in his tree...

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
