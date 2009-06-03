From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 08/10] nfs-utils: add IPv6 support to nfssvc_setfds
Date: Wed, 03 Jun 2009 16:16:59 -0400
Message-ID: <4A26DA3B.3090404@RedHat.com>
References: <1244058763-10352-1-git-send-email-jlayton@redhat.com> <1244058763-10352-9-git-send-email-jlayton@redhat.com> <4D598E93-E9CE-4AA7-8289-169FD85EF05B@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36002 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751409AbZFCUUI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 16:20:08 -0400
In-Reply-To: <4D598E93-E9CE-4AA7-8289-169FD85EF05B@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> 
> On Jun 3, 2009, at 3:52 PM, Jeff Layton wrote:
> 
>> Allow nfssvc_setfds to properly deal with AF_INET6.
>>
>> IPv6 sockets for knfsd can't be allowed to accept IPv4 packets. Set the
>> correct option to prevent that from occurring on IPv6 sockets.
>>
>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>> ---
>> support/nfs/nfssvc.c |   14 ++++++++++++++
>> 1 files changed, 14 insertions(+), 0 deletions(-)
>>
>> diff --git a/support/nfs/nfssvc.c b/support/nfs/nfssvc.c
>> index 89fb5be..19f1a4c 100644
>> --- a/support/nfs/nfssvc.c
>> +++ b/support/nfs/nfssvc.c
>> @@ -76,6 +76,11 @@ nfssvc_setfds(const struct addrinfo *hints, const
>> char *node, const char *port)
>>     case AF_INET:
>>         family = "inet";
>>         break;
>> +#ifdef IPV6_SUPPORTED
>> +    case AF_INET6:
>> +        family = "inet6";
>> +        break;
>> +#endif /* IPV6_SUPPORTED */
>>     default:
>>         xlog(L_ERROR, "Unknown address family specified: %d\n",
>>                 hints->ai_family);
>> @@ -123,6 +128,15 @@ nfssvc_setfds(const struct addrinfo *hints, const
>> char *node, const char *port)
>>             rc = errno;
>>             goto error;
>>         }
>> +#ifdef IPV6_SUPPORTED
>> +        if (addr->ai_family == AF_INET6 &&
>> +            setsockopt(sockfd, IPPROTO_IPV6, IPV6_V6ONLY, &on,
>> sizeof(on))) {
>> +            xlog(L_ERROR, "unable to set IPV6_V6ONLY: "
>> +                "errno %d (%s)\n", errno, strerror(errno));
> 
> I'm still looking at the other patches, but I notice you could use %m
> here too.
I kinda like having both... the errno *and* the error string...

steved.
