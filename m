From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 8/8] SUNRPC: fewer conditionals in the
	format_ip_address routines
Date: Thu, 03 Jan 2008 16:45:35 -0500
Message-ID: <1199396736.1913.7.camel@heimdal.trondhjem.org>
References: <20071220195518.3280.91282.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:54029 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751540AbYACVpk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jan 2008 16:45:40 -0500
In-Reply-To: <20071220195518.3280.91282.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2007-12-20 at 14:55 -0500, Chuck Lever wrote:
> Clean up: have the set up routines explicitly pass the strings to be used
> for the transport name and NETID.  This removes a number of conditionals
> and dependencies on rpc_xprt.prot, which is overloaded.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---

NACK to this one. This whole premise of doing a kstrdup() on a bunch of
constants is silly. It's not as if we need to rewrite the contents of
address_strings[FOO] every 2 seconds.

If you're going to clean this up, then please do so by making
address_strings be an array of 'const char *', and just have these
entries point to the constants "udp", "udp6", "tcp", "tcp6" (just like
RDMA already does).

Cheers
  Trond

