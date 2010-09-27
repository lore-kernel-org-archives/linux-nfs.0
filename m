Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:4394 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759373Ab0I0Nll (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 09:41:41 -0400
Message-ID: <4CA09F03.6090407@parallels.com>
Date: Mon, 27 Sep 2010 17:41:23 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        David Miller <davem@davemloft.net>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 7/8] net: Export __sock_create
References: <4CA06C7A.5060307@parallels.com>	 <4CA06D62.4040703@parallels.com> <1285594260.19362.40.camel@heimdal.trondhjem.org>
In-Reply-To: <1285594260.19362.40.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/27/2010 05:31 PM, Trond Myklebust wrote:
> On Mon, 2010-09-27 at 14:09 +0400, Pavel Emelyanov wrote:
>> Can we can do it not through the Dave's tree?
> 
> I think we will still need Dave's approval for this. Either an Ack or a
> signed-off-by. Linus will very likely yell at us and refuse to take the
> patch if we don't.

OK, I then put Dave in Cc.

And a small background of the patch - I'm trying to make sunrpc layer work
in net namespaces and in order to do this I need to turn existing calls to
sock_create_kern() into __sock_create() to specify the net namespace the
socket are to be created in.

Dave, can we go on with this, please? :)

> Cheers
>   Trond
> 
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>> ---
>>  include/linux/net.h |    2 ++
>>  net/socket.c        |    3 ++-
>>  2 files changed, 4 insertions(+), 1 deletions(-)
>>
>> diff --git a/include/linux/net.h b/include/linux/net.h
>> index dee0b11..16faa13 100644
>> --- a/include/linux/net.h
>> +++ b/include/linux/net.h
>> @@ -229,6 +229,8 @@ enum {
>>  extern int	     sock_wake_async(struct socket *sk, int how, int band);
>>  extern int	     sock_register(const struct net_proto_family *fam);
>>  extern void	     sock_unregister(int family);
>> +extern int	     __sock_create(struct net *net, int family, int type, int proto,
>> +				 struct socket **res, int kern);
>>  extern int	     sock_create(int family, int type, int proto,
>>  				 struct socket **res);
>>  extern int	     sock_create_kern(int family, int type, int proto,
>> diff --git a/net/socket.c b/net/socket.c
>> index 2270b94..0c37b00 100644
>> --- a/net/socket.c
>> +++ b/net/socket.c
>> @@ -1144,7 +1144,7 @@ call_kill:
>>  }
>>  EXPORT_SYMBOL(sock_wake_async);
>>  
>> -static int __sock_create(struct net *net, int family, int type, int protocol,
>> +int __sock_create(struct net *net, int family, int type, int protocol,
>>  			 struct socket **res, int kern)
>>  {
>>  	int err;
>> @@ -1256,6 +1256,7 @@ out_release:
>>  	rcu_read_unlock();
>>  	goto out_sock_release;
>>  }
>> +EXPORT_SYMBOL(__sock_create);
>>  
>>  int sock_create(int family, int type, int protocol, struct socket **res)
>>  {
