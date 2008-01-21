From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC,PATCH] svc: Modify svc_xprt_create to take a sockaddr
Date: Mon, 21 Jan 2008 12:59:25 -0500
Message-ID: <1200938366.25562.14.camel@heimdal.trondhjem.org>
References: <20080121171105.29028.61809.stgit@dell3.ogc.int>
	 <9ECEB764-A93C-4DF2-BB6E-273C33C02B6E@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tom Tucker <tom@opengridcomputing.com>, bfields@fieldses.org,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:46079 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751711AbYAUR7l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jan 2008 12:59:41 -0500
In-Reply-To: <9ECEB764-A93C-4DF2-BB6E-273C33C02B6E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-01-21 at 12:47 -0500, Chuck Lever wrote:

> This is sort of a generic question.
> 
> The server-side interface appears to be using strings to identify  
> transports ("tcp"), but the client-side is still using numbers  
> (XPRT_TRANSPORT_TCP).  There are one or two sticky issues to fix  
> before the client-side can use strings, but...

We already have to parse the mount string in the NFS code. Why on earth
would we want to have a second parser for the same thing in the RPC
code?

Trond

