Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:48542 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752532AbeBLR7J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 12 Feb 2018 12:59:09 -0500
Subject: Re: [PATCH] net: make getname() functions return length rather than
 use int* parameter
To: David Miller <davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-bluetooth@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net,
        linux-wireless@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-sctp@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-x25@vger.kernel.org
References: <20180212141518.3354-1-dvlasenk@redhat.com>
 <20180212.124738.870301786818646917.davem@davemloft.net>
From: Denys Vlasenko <dvlasenk@redhat.com>
Message-ID: <4f0c5a1d-f75d-4c54-8cdd-5660b2233252@redhat.com>
Date: Mon, 12 Feb 2018 18:59:06 +0100
MIME-Version: 1.0
In-Reply-To: <20180212.124738.870301786818646917.davem@davemloft.net>
Content-Type: text/plain; charset=iso-8859-7; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/12/2018 06:47 PM, David Miller wrote:
> From: Denys Vlasenko <dvlasenk@redhat.com>
> Date: Mon, 12 Feb 2018 15:15:18 +0100
> 
>> Before:
>> All these functions either return a negative error indicator,
>> or store length of sockaddr into "int *socklen" parameter
>> and return zero on success.
>>
>> "int *socklen" parameter is awkward. For example, if caller does not
>> care, it still needs to provide on-stack storage for the value
>> it does not need.
>>
>> None of the many FOO_getname() functions of various protocols
>> ever used old value of *socklen. They always just overwrite it.
>>
>> This change drops this parameter, and makes all these functions, on success,
>> return length of sockaddr. It's always >= 0 and can be differentiated
>> from an error.
>>
>> Tests in callers are changed from "if (err)" to "if (err < 0)", where needed.
>>
>> rpc_sockname() lost "int buflen" parameter, since its only use was
>> to be passed to kernel_getsockname() as &buflen and subsequently
>> not used in any way.
>>
>> Userspace API is not changed.
>>
>>      text    data     bss      dec     hex filename
>> 30108430 2633624  873672 33615726 200ef6e vmlinux.before.o
>> 30108109 2633612  873672 33615393 200ee21 vmlinux.o
>>
>> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
> 
> Please do an allmodconfig build, there are still some conversions you
> missed:
> 
> security/tomoyo/network.c: In function ¡tomoyo_socket_listen_permission¢:
> security/tomoyo/network.c:658:19: warning: passing argument 3 of ¡sock->ops->getname¢ makes integer from pointer without a cast [-Wint-conversion]
>              &addr, &addr_len, 0);
>                     ^
> security/tomoyo/network.c:658:19: note: expected ¡int¢ but argument is of type ¡int *¢
> security/tomoyo/network.c:657:21: error: too many arguments to function ¡sock->ops->getname¢
>     const int error = sock->ops->getname(sock, (struct sockaddr *)
>                       ^~~~
> fs/dlm/lowcomms.c: In function ¡lowcomms_error_report¢:
> fs/dlm/lowcomms.c:495:6: error: too many arguments to function ¡kernel_getpeername¢
>        kernel_getpeername(con->sock, (struct sockaddr *)&saddr, &buflen)) {
>        ^~~~~~~~~~~~~~~~~~
> fs/dlm/lowcomms.c: In function ¡tcp_accept_from_sock¢:
> fs/dlm/lowcomms.c:761:7: warning: passing argument 3 of ¡newsock->ops->getname¢ makes integer from pointer without a cast [-Wint-conversion]
>         &len, 2)) {
>         ^
> fs/dlm/lowcomms.c:761:7: note: expected ¡int¢ but argument is of type ¡int *¢
> fs/dlm/lowcomms.c:760:6: error: too many arguments to function ¡newsock->ops->getname¢
>    if (newsock->ops->getname(newsock, (struct sockaddr *)&peeraddr,
>        ^~~~~~~

Sorry. Will send updated patch.
  
