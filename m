Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:17572 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755403Ab0JVP5m convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Oct 2010 11:57:42 -0400
Subject: Re: [PATCH] xs_bind retry binding forever
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1287689917.9144.84.camel@heimdal.trondhjem.org>
Date: Fri, 22 Oct 2010 11:56:23 -0400
Cc: Ben Myers <bpm@sgi.com>, linux-nfs@vger.kernel.org
Message-Id: <48B51F5A-E060-4B0B-8AD6-1E4247C4289F@oracle.com>
References: <20101021183203.12776.28469.stgit@lady3jane.americas.sgi.com> <20101021183337.12776.18768.stgit@lady3jane.americas.sgi.com> <1287689917.9144.84.camel@heimdal.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Oct 21, 2010, at 3:38 PM, Trond Myklebust wrote:

> On Thu, 2010-10-21 at 13:33 -0500, Ben Myers wrote:
>> Retry bind for reserved source ports forever.  Add an error message when we
>> have a hard time binding one.
> 
> NACK. This approach leads to the process spinning forever in that loop,
> which is exactly why we introduced the limit in the first place. See all
> the old archived bug report emails about 'rpciod taking 100% cpu'.

The root problem seems to be the hard loop.  Thinking out loud, what if the client's FSM or some other higher up layer performed the retry, with a short delay inserted after each attempt?

> Cheers
>  Trond
> 
>> Signed-off-by: Ben Myers <bpm@sgi.com>
>> ---
>> net/sunrpc/xprtsock.c |   22 ++++++++++++++++++----
>> 1 files changed, 18 insertions(+), 4 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index b6309db..79a001b 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -1560,9 +1560,16 @@ static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
>> 		}
>> 		last = port;
>> 		port = xs_next_srcport(transport, sock, port);
>> -		if (port > last)
>> +		if (port > last) {
>> +			if (nloop > 2 && net_ratelimit()) {
>> +				printk("RPC: %s %pI4: Cannot bind reserved "
>> +				       "source port.  Consider decreasing "
>> +				       "min_resvport.\n",
>> +				       __func__, &myaddr.sin_addr);
>> +			}
>> 			nloop++;
>> -	} while (err == -EADDRINUSE && nloop != 2);
>> +		}
>> +	} while (err == -EADDRINUSE);
>> 	dprintk("RPC:       %s %pI4:%u: %s (%d)\n",
>> 			__func__, &myaddr.sin_addr,
>> 			port, err ? "failed" : "ok", err);
>> @@ -1593,9 +1600,16 @@ static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
>> 		}
>> 		last = port;
>> 		port = xs_next_srcport(transport, sock, port);
>> -		if (port > last)
>> +		if (port > last) {
>> +			if (nloop > 2 && net_ratelimit()) {
>> +				printk("RPC: %s %pI6: Cannot bind reserved "
>> +				       "source port.  Consider decreasing "
>> +				       "min_resvport.\n",
>> +					__func__, &myaddr.sin6_addr);
>> +			}
>> 			nloop++;
>> -	} while (err == -EADDRINUSE && nloop != 2);
>> +		}
>> +	} while (err == -EADDRINUSE);
>> 	dprintk("RPC:       xs_bind6 %pI6:%u: %s (%d)\n",
>> 		&myaddr.sin6_addr, port, err ? "failed" : "ok", err);
>> 	return err;
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
chuck[dot]lever[at]oracle[dot]com




