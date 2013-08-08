Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46872 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932245Ab3HHBhm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Aug 2013 21:37:42 -0400
Message-ID: <1375925850.19907.5.camel@cr0>
Subject: Re: [Patch net-next v2 5/8] sunrpc: use generic union inet_addr
From: Cong Wang <amwang@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Date: Thu, 08 Aug 2013 09:37:30 +0800
In-Reply-To: <20130807092123.451e93db@tlielax.poochiereds.net>
References: <1375427674-21735-1-git-send-email-amwang@redhat.com>
	 <1375427674-21735-6-git-send-email-amwang@redhat.com>
	 <20130802093625.2c70a330@tlielax.poochiereds.net>
	 <1375672445.32485.8.camel@cr0>
	 <20130806062801.67714276@tlielax.poochiereds.net>
	 <1375878446.11370.36.camel@cr0>
	 <20130807092123.451e93db@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-08-07 at 09:21 -0400, Jeff Layton wrote:
> Ok, good point. That does look cleaner. I'd still like to see the rpc_*
> wrappers go away, but that can be done later.
> 

I will move the wrappers to generic since several people asked.


