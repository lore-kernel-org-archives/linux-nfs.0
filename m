Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:27566 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757074Ab0JEFmU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Oct 2010 01:42:20 -0400
Message-ID: <4CAABAAB.8040608@parallels.com>
Date: Tue, 05 Oct 2010 09:42:03 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 9/13] sunrpc: Merge the xs_bind code
References: <4CA9CDA8.4010407@parallels.com> <4CA9CEE8.9050404@parallels.com> <66FA6AAD-87DC-4B81-8DAC-8F1D4FF7B72E@oracle.com>
In-Reply-To: <66FA6AAD-87DC-4B81-8DAC-8F1D4FF7B72E@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>> -static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
>> +static int xs_bind(struct sock_xprt *transport, struct socket *sock)
>> {
>> -	struct sockaddr_in myaddr = {
>> -		.sin_family = AF_INET,
>> -	};
>> -	struct sockaddr_in *sa;
>> +	struct sockaddr myaddr;
> 
> You want "struct sockaddr_storage" here.  A "struct sockaddr" is required by
> standard (iirc) to be only as large as a "struct sockaddr_in".  So this can't
> possibly hold an IPv6 socket address without overflowing.

OK

>> 	int err, nloop = 0;
>> 	unsigned short port = xs_get_srcport(transport);
>> 	unsigned short last;
>>
>> -	sa = (struct sockaddr_in *)&transport->srcaddr;
>> -	myaddr.sin_addr = sa->sin_addr;
>> +	memcpy(&myaddr, &transport->srcaddr, transport->xprt.addrlen);
>> 	do {
>> -		myaddr.sin_port = htons(port);
>> -		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
>> -						sizeof(myaddr));
>> +		BUILD_BUG_ON(offsetof(struct sockaddr_in, sin_port) !=
>> +				offsetof(struct sockaddr_in6, sin6_port));
>> +		((struct sockaddr_in *)&myaddr)->sin_port = htons(port);
> 
> This series of patches looks mostly OK at first blush, but this little 
> change is a bit offensive.  :-)
> 
> There should be some static inline helper functions that can get and set the
> port number in a socket address without a lot of magic, and I would prefer you
> use those instead.  (I would point you directly to them, but I can't easily
> access kernel source at the moment -- hotel internet sucks).
> 
> There should be one or two code examples in the RPC module or in headers that
> set and get ports in an automatic struct sockaddr_storage variable to give you
> an idea of what this needs to look like to avoid stack overruns and bad 
> pointer aliasing.

I believe you mean the rpc_set_port() one. Will do!

Thanks,
Pavel
