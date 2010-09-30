Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:29850 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751452Ab0I3Fqs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 01:46:48 -0400
Message-ID: <4CA42437.3090102@parallels.com>
Date: Thu, 30 Sep 2010 09:46:31 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 0/9] sunrpc: Create sockets in namespaces
References: <4CA32AB4.2090808@parallels.com> <20100929214527.GC26180@fieldses.org> <0678928F-3DE0-4AB9-8CD9-7BDA3A362A20@oracle.com>
In-Reply-To: <0678928F-3DE0-4AB9-8CD9-7BDA3A362A20@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>> Shall I commit this to my for-2.6.37 tree?  Objections?
> 
> I think it looks OK.
> 
> But I was wondering if there were any other changes needed for the RDMA 
> transport capability, or had we decided that would happen at a latter point, 
> or that changes are entirely unneeded

We definitely need more changes in the RDMA transport, but I would like to
have it done later (unless someone other than me starts doing it earlier ;) ).

> (are namespaces already supported in the IB stack)?

Nope. And this makes RDMA netnsization even more harder :(
