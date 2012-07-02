Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:29586 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155Ab2GBOm7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jul 2012 10:42:59 -0400
Subject: Re: RPC rpcinfo command PATCH
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=US-ASCII
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAC+fKpJCN2GJvA71RW4j9GUW5rw+hAS1SgPUZzBwvNShd098Ag@mail.gmail.com>
Date: Mon, 2 Jul 2012 10:43:01 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <34DE974E-597D-460F-B2F0-5A6DBE51593F@oracle.com>
References: <CAC+fKpJCN2GJvA71RW4j9GUW5rw+hAS1SgPUZzBwvNShd098Ag@mail.gmail.com>
To: Leandro Meiners <lmeiners@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 2, 2012, at 10:32 AM, Leandro Meiners wrote:

> Hi,
> 
> I have written a patch for the rpcinfo command that allows querying
> the port-mapper via UDP instead of TCP. I added a new parameter
> (upper-case P) for this functionality. It was helpful for me during a
> penetration test and I thought it might be worth adding to the
> project.
> Signed-off-by: Leandro Meiners <lmeiners@gmail.com>

Instead of passing a string ("tcp") to pmapdump(), why not use IPPROTO_TCP and IPPROTO_UDP ?

Can you say a little bit more about how UDP helped you?