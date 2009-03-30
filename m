From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 06/17] SUNRPC: Set IPV6ONLY flag on PF_INET6 RPC listenersockets
Date: Mon, 30 Mar 2009 18:28:29 -0400
Message-ID: <12FE2DFB-2575-4F63-A4E1-69789C34587A@oracle.com>
References: <20090303220539.2933.15015.stgit@ingres.1015granger.net> <20090303223254.2933.70364.stgit@ingres.1015granger.net> <1238451467.23512.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: bfields@fieldses.org, steved@redhat.com, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:55551 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103AbZC3W3B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 18:29:01 -0400
In-Reply-To: <1238451467.23512.11.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 30, 2009, at 6:17 PM, Trond Myklebust wrote:
> On Tue, 2009-03-03 at 15:32 -0700, Chuck Lever wrote:
>> We are about to convert to using separate RPC listener sockets for
>> AF_INET and AF_INET6.  This echoes the way IPv6 is handled in user
>> space by TI-RPC, and eliminates the need to worry about mapped IPv4
>> AF_INET6 addresses when doing address comparisons.
>>
>> Start by setting the IPV6ONLY flag on RPC listener sockets.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> net/sunrpc/svcsock.c |   10 ++++------
>> 1 files changed, 4 insertions(+), 6 deletions(-)
>>
>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>> index d00bc33..ac6cd65 100644
>> --- a/net/sunrpc/svcsock.c
>> +++ b/net/sunrpc/svcsock.c
>> @@ -1144,13 +1144,11 @@ static struct svc_sock
>> *svc_setup_socket(struct svc_serv *serv,
>>                svc_tcp_init(svsk, serv);
>>
>>        /*
>> -        * We start one listener per sv_serv.  We want AF_INET
>> -        * requests to be automatically shunted to our PF_INET6
>> -        * listener using a mapped IPv4 address.  Make sure
>> -        * no-one starts an equivalent IPv4 listener, which
>> -        * would steal our incoming connections.
>> +        * If this is a PF_INET6 listener, we want to avoid
>> +        * getting requests from IPv4 remotes.  Those should
>> +        * be shunted to a PF_INET listener via rpcbind.
>>         */
>> -       val = 0;
>> +       val = 1;
>>        if (inet->sk_family == PF_INET6)
> 			         AF_INET6...

As far as I can tell PF_INET6 and AF_INET6 are interchangeable here.   
I can find examples of sk_family being set to or compared to either,  
and I think they always have the same value.  So it's really just a  
style preference?

> ...and this should probably be set before we bind the socket...

Yes, that's probably correct.  I hadn't encountered EADDRINUSE in my  
testing.

Should I send you a fix, or do you have one in mind already?

>>                kernel_setsockopt(sock, SOL_IPV6, IPV6_V6ONLY,
>>                                        (char *)&val, sizeof(val));

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
