From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH] svc: Modify svc_xprt_create to take a sockaddr
Date: Mon, 21 Jan 2008 13:30:41 -0500
Message-ID: <FD665904-E655-48E9-8508-D9E118762C84@oracle.com>
References: <20080121171105.29028.61809.stgit@dell3.ogc.int> <9ECEB764-A93C-4DF2-BB6E-273C33C02B6E@oracle.com> <1200938366.25562.14.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:33714 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbYAUScQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2008 13:32:16 -0500
In-Reply-To: <1200938366.25562.14.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

On Jan 21, 2008, at 12:59 PM, Trond Myklebust wrote:
> On Mon, 2008-01-21 at 12:47 -0500, Chuck Lever wrote:
>> This is sort of a generic question.
>>
>> The server-side interface appears to be using strings to identify
>> transports ("tcp"), but the client-side is still using numbers
>> (XPRT_TRANSPORT_TCP).  There are one or two sticky issues to fix
>> before the client-side can use strings, but...
>
> We already have to parse the mount string in the NFS code. Why on  
> earth
> would we want to have a second parser for the same thing in the RPC
> code?


Not sure what you are getting at here.

The goal of using string transport identifiers in the RPC client is  
that the value of "proto=" could be passed directly to the RPC  
client.  The way it works today, we have to add support in the NFS  
mount option parser for any new RPC transport capability.

One of the goals of the client-side transport switch has always been  
to allow new transport capabilities to be dynamically loaded without  
needing to make code changes to the NFS client to support them.

For example, it would be nice to have an SCTP transport capability,  
or a single-socket-per-client UDP transport capability, in addition  
to the default socket-based transports we have now.  With the current  
arrangement, we'll have to add code in the NFS mount option parser to  
allow users to select these.  If the proto= value were simply passed  
through, it would be simple for the RPC client to match the value to  
an identifier string specified by the new transport.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
