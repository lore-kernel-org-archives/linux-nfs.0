From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/8] SUNRPC: Add address family field to svc_serv data structure
Date: Fri, 4 Jul 2008 09:45:36 -0400
Message-ID: <76bd70e30807040645x3991b32cu9a05b7fb1e19ecc4@mail.gmail.com>
References: <20080630224147.24887.18730.stgit@ellison.1015granger.net>
	 <20080630224529.24887.47412.stgit@ellison.1015granger.net>
	 <20080703211423.GL30918@fieldses.org>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:57910 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758363AbYGDNpr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jul 2008 09:45:47 -0400
Received: by yw-out-2324.google.com with SMTP id 9so530799ywe.1
        for <linux-nfs@vger.kernel.org>; Fri, 04 Jul 2008 06:45:37 -0700 (PDT)
In-Reply-To: <20080703211423.GL30918@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 3, 2008 at 5:14 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Mon, Jun 30, 2008 at 06:45:30PM -0400, Chuck Lever wrote:
>> Introduce and initialize an address family field in the svc_serv structure.
>>
>> This field will determine what family to use for the service's listener
>> sockets and what families are advertised via the local rpcbind daemon.
>
> Possibly dumb question: so it never makes sense to listen on sockets
> with both address families?

There are several ways to map an AF_INET address to an AF_INET6
address, so you can easily set up a single AF_INET6 listener that can
also handle your AF_INET traffic.

You can listen on both, but I think having a single listener is less complex.

-- 
Chuck Lever
