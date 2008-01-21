From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH] svc: Modify svc_xprt_create to take a sockaddr
Date: Mon, 21 Jan 2008 12:22:53 -0600
Message-ID: <1200939773.11003.53.camel@trinity.ogc.int>
References: <20080121171105.29028.61809.stgit@dell3.ogc.int>
	 <9ECEB764-A93C-4DF2-BB6E-273C33C02B6E@oracle.com>
	 <1200938366.25562.14.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, bfields@fieldses.org,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:49178 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751237AbYAUSP3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2008 13:15:29 -0500
In-Reply-To: <1200938366.25562.14.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-01-21 at 12:59 -0500, Trond Myklebust wrote:
> On Mon, 2008-01-21 at 12:47 -0500, Chuck Lever wrote:
> 
> > This is sort of a generic question.
> > 
> > The server-side interface appears to be using strings to identify  
> > transports ("tcp"), but the client-side is still using numbers  
> > (XPRT_TRANSPORT_TCP).  There are one or two sticky issues to fix  
> > before the client-side can use strings, but...
> 
> We already have to parse the mount string in the NFS code. Why on earth
> would we want to have a second parser for the same thing in the RPC
> code?
> 

I don't. Oversight on my part....I'll recode with the existing
functions...

> Trond
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

