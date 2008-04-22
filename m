From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 03/33] SUNRPC: Don't attempt to destroy expired RPCSEC_GSS credentials..
Date: Tue, 22 Apr 2008 09:38:01 -0400
Message-ID: <86898638-C54D-44F7-917E-1EDF6795B56C@oracle.com>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <20080419204047.14124.64969.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <FB8780E7-FE92-40D6-8DFE-0663DF1B0162@oracle.com> <1208822443.7767.23.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:37474 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754150AbYDVNjG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Apr 2008 09:39:06 -0400
In-Reply-To: <1208822443.7767.23.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 21, 2008, at 8:00 PM, Trond Myklebust wrote:
> On Mon, 2008-04-21 at 13:50 -0400, Chuck Lever wrote:
>>> This actually fixes a hang situation. Basically, some servers will
>>> decide
>>> that the client is crazy if it tries to destroy an RPC context for
>>> which
>>> they have sent an RPCSEC_GSS_CREDPROBLEM, and so will refuse to talk
>>> to it
>>> for a while.
>>
>> That seems unfriendly.  Is this server-side behavior mandated?  Why
>> wouldn't the server just treat an extraneous context destruction
>> request as a successful no-op?
>>
>> You definitely should include an explanation of this server-side
>> behavior in the documenting comment for gss_destroying_context.
>
> RFC-2203 states that servers are supposed to silently discard requests
> that they don't recognise (see section 5.3.3.1 - Context  
> Management), so
> it is correct server behaviour.


Dropping the request to destroy a context is fine.  Temporarily  
fencing the client is what I was concerned about.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
