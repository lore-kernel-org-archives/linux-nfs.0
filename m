From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 21/38] svc: Change svc_sock_received to svc_xprt_received and export it
Date: Fri, 30 Nov 2007 18:23:08 -0500
Message-ID: <3E6C8687-0A0C-489F-B7F8-1EEFA2E01919@oracle.com>
References: <20071129223917.14563.77633.stgit@dell3.ogc.int> <20071129224037.14563.69171.stgit@dell3.ogc.int> <7E88BE3B-F35C-44B1-AE84-E5DE62E4EFA5@oracle.com> <1196464634.5432.68.camel@trinity.ogc.int>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:39485 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756010AbXK3XXW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2007 18:23:22 -0500
In-Reply-To: <1196464634.5432.68.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 30, 2007, at 6:17 PM, Tom Tucker wrote:
> On Fri, 2007-11-30 at 16:33 -0500, Chuck Lever wrote:
>> On Nov 29, 2007, at 5:40 PM, Tom Tucker wrote:
>>> {
>>> -	svsk->sk_xprt.xpt_pool = NULL;
>>> -	clear_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags);
>>> -	svc_xprt_enqueue(&svsk->sk_xprt);
>>> +	xprt->xpt_pool = NULL;
>>> +	clear_bit(XPT_BUSY, &xprt->xpt_flags);
>>> +	svc_xprt_enqueue(xprt);
>>>  }
>>> -
>>> +EXPORT_SYMBOL_GPL(svc_xprt_received);
>>
>> When I submitted the RPC client-side transport switch, Trond
>> suggested we add the EXPORTs later when it was clear why they are
>> needed.  This may be a personal preference of the server maintainer,
>> but I just thought I'd mention the possibility; it seems to make
>> sense here too.
>
> Sure, but we already have a server side provider that helps accelerate
> the proving process. The svcrdma module won't build without this being
> exported.

That's fine.  You just add the EXPORTs when you introduce the svcrdma  
module.

No biggie.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
