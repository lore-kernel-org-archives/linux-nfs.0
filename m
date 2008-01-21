From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC,PATCH] svc: Modify svc_xprt_create to take a sockaddr
Date: Mon, 21 Jan 2008 17:42:51 -0500
Message-ID: <1200955371.27963.28.camel@heimdal.trondhjem.org>
References: <20080121171105.29028.61809.stgit@dell3.ogc.int>
	 <9ECEB764-A93C-4DF2-BB6E-273C33C02B6E@oracle.com>
	 <1200938366.25562.14.camel@heimdal.trondhjem.org>
	 <FD665904-E655-48E9-8508-D9E118762C84@oracle.com>
	 <1200943495.25562.52.camel@heimdal.trondhjem.org>
	 <1200948494.11003.71.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:40271 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754849AbYAUWm5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jan 2008 17:42:57 -0500
In-Reply-To: <1200948494.11003.71.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-01-21 at 14:48 -0600, Tom Tucker wrote:

> modprobe my_favorite_transport
> 
> mount .... -o proto="my_favorite_transport_id_string"
> 
> and it works...
> 
> Maybe I'm being naive, but that seems flexible and secure provided that
> the transport layer code is not broken.

You misunderstood me. I have no problems with passing the 'proto=' value
down once it has been parsed. My concern is that people are assuming
that we will allow these modules to have their own private mount
parameters (i.e. private user interfaces).

  Trond

