Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46862 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754276Ab3HEDO1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 4 Aug 2013 23:14:27 -0400
Message-ID: <1375672445.32485.8.camel@cr0>
Subject: Re: [Patch net-next v2 5/8] sunrpc: use generic union inet_addr
From: Cong Wang <amwang@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Date: Mon, 05 Aug 2013 11:14:05 +0800
In-Reply-To: <20130802093625.2c70a330@tlielax.poochiereds.net>
References: <1375427674-21735-1-git-send-email-amwang@redhat.com>
	 <1375427674-21735-6-git-send-email-amwang@redhat.com>
	 <20130802093625.2c70a330@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-08-02 at 09:36 -0400, Jeff Layton wrote:
> On Fri,  2 Aug 2013 15:14:31 +0800
> Cong Wang <amwang@redhat.com> wrote:
> 
> > From: Cong Wang <amwang@redhat.com>
> > 
> > sunrpc defines some helper functions for sockaddr, actually they
> > can re-use the generic functions for union inet_addr too.
> 
> Only some of these patches in this series have made it to lists to
> which I'm subscribed, so I may be missing some context here...
> 
> I'm not sure I really understand the value of "union inet_addr". Why
> not just use the conventional method of passing around "struct sockaddr"
> pointers, and then casting them to struct sockaddr_in/sockaddr_in6
> depending on what the sa_family is set to?

Yes.

> 
> With that you wouldn't need to leave the (now pointless) rpc_* wrappers
> in place and could just call your new helpers directly.
> 

J. Bruce asked the same question, see:
http://marc.info/?l=linux-nfs&m=137475685903460&w=2

Thanks.

