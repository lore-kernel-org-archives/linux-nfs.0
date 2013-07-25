Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46990 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755452Ab3GYMew (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Jul 2013 08:34:52 -0400
Message-ID: <1374755683.29923.7.camel@cr0>
Subject: Re: [Patch net-next 4/7] sunrpc: use generic union inet_addr
From: Cong Wang <amwang@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Date: Thu, 25 Jul 2013 20:34:43 +0800
In-Reply-To: <20130723164051.GE12569@fieldses.org>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com>
	 <1374476713-8838-5-git-send-email-amwang@redhat.com>
	 <20130723164051.GE12569@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-07-23 at 12:40 -0400, J. Bruce Fields wrote:
> On Mon, Jul 22, 2013 at 03:05:10PM +0800, Cong Wang wrote: 
> >  static inline unsigned short rpc_get_port(const struct sockaddr *sap)
> >  {
> > -	switch (sap->sa_family) {
> > -	case AF_INET:
> > -		return ntohs(((struct sockaddr_in *)sap)->sin_port);
> > -	case AF_INET6:
> > -		return ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
> > -	}
> > -	return 0;
> > +	return inet_addr_get_port((const union inet_addr *)sap);
> >  }
> 
> Is there any reason to keep the rpc_get_port wrapper at all after this?
> Or if its still useful to have the convenience of not having to do the
> cast, maybe the wrapper should move to common code to?  (Is there some
> reason only the rpc code needs this?)
> 

Yeah, the only reason why I keep it is that I don't want to touch all
the callers of rpc_get_port(). I agree that we can make it a generic
function.

Thanks.

