From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 15/23] SUNRPC: rpcbind actually interprets r_owner string
Date: Fri, 27 Mar 2009 11:36:10 -0400
Message-ID: <CBF484BB-BF9A-4C0D-A56E-D8DFC394A966@oracle.com>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net> <20090319004713.32404.63163.stgit@ingres.1015granger.net> <49CB439D.5080401@sgi.com> <994CA980-BA59-4F8E-B510-4079A175BFEF@oracle.com> <49CC0D63.8090004@sgi.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: trond.myklebust@fys.uio.no, bfields@fieldses.org,
	linux-nfs@vger.kernel.org
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:19482 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756869AbZC0Pgb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2009 11:36:31 -0400
In-Reply-To: <49CC0D63.8090004@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 26, 2009, at 7:18 PM, Greg Banks wrote:
> Chuck Lever wrote:
>> On Mar 26, 2009, at 4:58 AM, Greg Banks wrote:
>>> Chuck Lever wrote:
>>>>
>>>> Our port of rpcbind (from Sun) assumes this string contains a  
>>>> numeric
>>>> UID value, not alphabetical or symbolic characters, but checks this
>>>> value only for AF_LOCAL RPCB_SET or RPCB_UNSET requests.  In all  
>>>> other
>>>> cases, rpcbind ignores the contents of the r_owner string.
>>>
>>> Not that this makes the slightest difference to the usefulness of  
>>> the
>>> patch, but it sounds like pretty strange behaviour for an rpcbind  
>>> server
>>> to be using an incoming r_owner value off the wire under any
>>> circumstances.
>>
>> It's ignored for wire requests.  r_owner is used only for AF_LOCAL
>> requests (ie a local file socket) where the kernel can guarantee the
>> owner.
>>
>>
> Sorry, I'm confused now.  Consider the r_owner field in the rpcb
> structure whose XDR representation flows through the AF_LOCAL  
> socket; is
> that used by rpcbind at all?  I don't understand how the kernel would
> guarantee that?

The library uses geteuid(2) to generate the r_owner string during  
RPCB_SET, as I mentioned before.  This is likely legacy behavior.

rpcbind then throws this away and uses getsockopt(SO_PEERCRED).  On  
network sockets I think that's always going to return a uid of -1, but  
for AF_LOCAL it will have a meaningful value.

I was loose about the use of the term "r_owner" : the r_owner  
parameter of RPCB_SET is always ignored, but _owner_ _information_ is  
used for requests coming in via AF_LOCAL.  The rpcb_clnt patch for the  
kernel is nothing more than a documentation change.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
