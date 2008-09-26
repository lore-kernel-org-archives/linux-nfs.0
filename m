From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 03/10] lockd: Adjust nlmsvc_lookup_host() to accomodate
	AF_INET6 addresses
Date: Fri, 26 Sep 2008 18:19:46 -0400
Message-ID: <20080926221946.GE7138@fieldses.org>
References: <20080917161337.4963.74674.stgit@ellison.1015granger.net> <20080917161735.4963.86248.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:44064 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912AbYIZWTx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 18:19:53 -0400
In-Reply-To: <20080917161735.4963.86248.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 17, 2008 at 11:17:35AM -0500, Chuck Lever wrote:
> Fix up nlmsvc_lookup_host() to pass AF_INET6 source addresses to
> nlm_lookup_host().
> 
> To keep stack usage down, we use address-family-specific sockaddr_in
> and sockaddr_in6 structures instead of sockaddr_storage where
> appropriate.  The server-side supports only AF_INET and AF_INET6.

Looks like there still is one sockaddr_storage on the stack.  That's 128
bytes.  Sounds doable, OK.

> +/**
> + * nlmsvc_lookup_host - Find an NLM host handle matching a remote client
> + * @rqstp: incoming NLM request
> + * @hostname: name of client host
> + * @hostname_len: length of client hostname
> + *
> + * Returns an nlm_host structure that matches the [client address,
> + * transport protocol, NLM version, client hostname] of the passed-in
> + * NLM request.  If one doesn't already exist in the host cache, a
> + * new handle is created and returned.
> + *
> + * Manufacture a specific source address in case the local system
> + * services clients from multiple IP addresses.

"Manufacture" makes it sound like we're faking one up somehow, but we're
actually just copying it from the svc_rqst, right?  Maybe make that
"store the specific source address..." instead?

--b.
