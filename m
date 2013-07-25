Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57361 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755553Ab3GYMyM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Jul 2013 08:54:12 -0400
Date: Thu, 25 Jul 2013 08:54:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Cong Wang <amwang@redhat.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [Patch net-next 4/7] sunrpc: use generic union inet_addr
Message-ID: <20130725125405.GC5777@fieldses.org>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com>
 <1374476713-8838-5-git-send-email-amwang@redhat.com>
 <20130723164051.GE12569@fieldses.org>
 <1374755683.29923.7.camel@cr0>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1374755683.29923.7.camel@cr0>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 25, 2013 at 08:34:43PM +0800, Cong Wang wrote:
> On Tue, 2013-07-23 at 12:40 -0400, J. Bruce Fields wrote:
> > On Mon, Jul 22, 2013 at 03:05:10PM +0800, Cong Wang wrote: 
> > >  static inline unsigned short rpc_get_port(const struct sockaddr *sap)
> > >  {
> > > -	switch (sap->sa_family) {
> > > -	case AF_INET:
> > > -		return ntohs(((struct sockaddr_in *)sap)->sin_port);
> > > -	case AF_INET6:
> > > -		return ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
> > > -	}
> > > -	return 0;
> > > +	return inet_addr_get_port((const union inet_addr *)sap);
> > >  }
> > 
> > Is there any reason to keep the rpc_get_port wrapper at all after this?
> > Or if its still useful to have the convenience of not having to do the
> > cast, maybe the wrapper should move to common code to?  (Is there some
> > reason only the rpc code needs this?)
> > 
> 
> Yeah, the only reason why I keep it is that I don't want to touch all
> the callers of rpc_get_port().

Makes sense, thanks.

--b.

> I agree that we can make it a generic
> function.
> 
> Thanks.
> 
