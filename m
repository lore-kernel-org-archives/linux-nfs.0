From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 15/23] SUNRPC: rpcbind actually interprets r_owner string
Date: Thu, 26 Mar 2009 11:44:08 -0400
Message-ID: <994CA980-BA59-4F8E-B510-4079A175BFEF@oracle.com>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net> <20090319004713.32404.63163.stgit@ingres.1015granger.net> <49CB439D.5080401@sgi.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: trond.myklebust@fys.uio.no, bfields@fieldses.org,
	linux-nfs@vger.kernel.org
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:59439 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756413AbZCZPoe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 11:44:34 -0400
In-Reply-To: <49CB439D.5080401@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 26, 2009, at 4:58 AM, Greg Banks wrote:
> Chuck Lever wrote:
>>
>> Our port of rpcbind (from Sun) assumes this string contains a numeric
>> UID value, not alphabetical or symbolic characters, but checks this
>> value only for AF_LOCAL RPCB_SET or RPCB_UNSET requests.  In all  
>> other
>> cases, rpcbind ignores the contents of the r_owner string.
>
> Not that this makes the slightest difference to the usefulness of the
> patch, but it sounds like pretty strange behaviour for an rpcbind  
> server
> to be using an incoming r_owner value off the wire under any  
> circumstances.

It's ignored for wire requests.  r_owner is used only for AF_LOCAL  
requests (ie a local file socket) where the kernel can guarantee the  
owner.

>> The reference user space implementation of rpcb_set(3) uses a numeric
>> UID for all SET/UNSET requests (even via the network) and an empty
>> string for all other requests.  We emulate that behavior here to
>> maintain bug-for-bug compatibility.
>
> Fair enough.
>
> Reviewed-by: Greg Banks <gnb@sgi.com>

Thanks.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
