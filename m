From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 1/3] SUNRPC: Ensure the server closes sockets in a timely
 fashion
Date: Wed, 17 Dec 2008 12:59:09 -0600
Message-ID: <49494BFD.6000909@opengridcomputing.com>
References: <20081017123207.GA14979@rabbit.intern.cm-ag>	 <1224484046.23068.14.camel@localhost.localdomain>	 <1225539927.2221.3.camel@localhost.localdomain>	 <1225546878.4390.3.camel@heimdal.trondhjem.org>	 <1227596962.16868.22.camel@localhost.localdomain>	 <1227619696.7057.19.camel@heimdal.trondhjem.org>	 <1227620339.9425.99.camel@zakaz.uk.xensource.com>	 <1227621434.7057.33.camel@heimdal.trondhjem.org>	 <1227621877.9425.102.camel@zakaz.uk.xensource.com>	 <1227737539.31008.2.camel@localhost.localdomain>	 <1228090631.7112.11.camel@heimdal.trondhjem.org>	 <1228090719.7112.13.camel@heimdal.trondhjem.org>	 <49491A50.7000109@opengridcomputing.com> <1229537296.7257.37.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, linux-nfs@vger.kernel.org,
	Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>, linux-kernel@vger.kernel.org,
	gcosta@redhat.com, Grant Coady <grant_lkml-rGYn+TmxqGy6c6uEtOJ/EA@public.gmane.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:54476 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752565AbYLQS7K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Dec 2008 13:59:10 -0500
In-Reply-To: <1229537296.7257.37.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Wed, 2008-12-17 at 09:27 -0600, Tom Tucker wrote:
>>> +	if (!test_bit(XPT_LISTENER, &xprt->xpt_flags))
>>> +		kernel_sock_shutdown(svsk->sk_sock, SHUT_RDWR);
>> How is this different than what happens as an artifact of sock_release?
> 
> The point is that it is independent of whether or not something is
> holding a reference to the svc_sock.

Thanks, makes sense.

> 

