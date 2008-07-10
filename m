From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH 04/14] text-based mount command: get_client_address support for IPv6
Date: Thu, 10 Jul 2008 16:35:57 -0400
Message-ID: <76bd70e30807101335y54f8b479v39953a772e08e88c@mail.gmail.com>
References: <20080710001725.6137.83845.stgit@tarkus.1015granger.net>
	 <20080710003723.6137.51761.stgit@tarkus.1015granger.net>
	 <20080710193008.GA27734@fieldses.org>
	 <5E74A13F-4A79-4356-8BBE-7B535F00EA66@oracle.com>
	 <20080710194310.GC27734@fieldses.org>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.184]:30058 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757192AbYGJUgA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2008 16:36:00 -0400
Received: by mu-out-0910.google.com with SMTP id w8so1118572mue.1
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2008 13:35:57 -0700 (PDT)
In-Reply-To: <20080710194310.GC27734@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 10, 2008 at 3:43 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Jul 10, 2008 at 03:36:21PM -0400, Chuck Lever wrote:
>> On Jul 10, 2008, at 3:30 PM, J. Bruce Fields wrote:
>>> On Wed, Jul 09, 2008 at 08:37:24PM -0400, Chuck Lever wrote:
>>>> Introduce IPv6-enabled version of get_client_address.  The legacy
>>>> mount
>>>> command could use this eventually as well.
>>>>
>>>> I don't remember how to tell an NFSv4 server to disable the callback
>>>> channel:  whether an ANY address is passed with SETCLIENTID, or a
>>>> loopback address is passed.  The patch allows either to be used with
>>>> a
>>>> compile-time switch.
>>>
>>> I would have thought INADDR_ANY.  But in any case we should just pick
>>> one....
>>
>> Well, yes, but we should pick the "correct" one.  :-)  The patch does it
>> this way just to make a note of this issue so we can make a decision
>> before committing this upstream.
>>
>> Does RFC 3530 have any recommendation about this?
>
> Not that I can find on a quick skim.

Is it clarified in the NFSv4.1 draft?

> I don't see why the spec would forbid running over loopback, though, in
> which case a loopback callback address would make sense.  And I assume
> INADDR_ANY is always meaningless as a destination address, so is a
> logical way to tell the server it can't call back to you.

Yep, I agree.

I recall a few years back at a CITI bake-a-thon there was a certain
server vendor who had trouble with loopback callback addresses,
probably because their implementation was server-only, so an NFSv4
callback from loopback would make no sense for them.  The client in
this case was sending a loopback callback address because it hadn't
implemented a callback service and wanted to prevent the server from
calling it back.

Do we have a high degree of certainty that sending an ANY address is
appropriate if the client can't determine a reasonable callback
address to send with SETCLIENTID?

Is it at least OK for Linux's NFSv4 server?

If we think this might be a problem, I can change all this back to
simply failing the mount request when the mount.nfs command can't
figure out a valid callback address.

>>>>
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>>
>>>> utils/mount/network.c |  122 +++++++++++++++++++++++++++++++++++++++
>>>> ++++++++++
>>>> utils/mount/network.h |    2 +
>>>> 2 files changed, 124 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>>>> index 3f2721b..128d7f7 100644
>>>> --- a/utils/mount/network.c
>>>> +++ b/utils/mount/network.c
>>>> @@ -918,3 +918,125 @@ int get_client_address(struct sockaddr_in
>>>> *saddr, struct sockaddr_in *caddr)
>>>>     }
>>>>     return 1;
>>>> }
>>>> +
>>>> +/*
>>>> + * Try a getsockname() on a connected datagram socket.
>>>> + *
>>>> + * Returns 1 and fills in @buf if successful; otherwise, zero.
>>>> + *
>>>> + * A connected datagram socket prevents leaving a socket in
>>>> TIME_WAIT.
>>>> + * This conserves the ephemeral port number space, helping reduce
>>>> failed
>>>> + * socket binds during mount storms.
>>>> + */
>>>> +static int nfs_ca_sockname(const struct sockaddr *sap, const
>>>> socklen_t salen,
>>>> +                      struct sockaddr *buf, socklen_t *buflen)
>>>> +{
>>>> +   struct sockaddr_in sin = {
>>>> +           .sin_family             = AF_INET,
>>>> +           .sin_addr.s_addr        = htonl(INADDR_ANY),
>>>> +   };
>>>> +   struct sockaddr_in6 sin6 = {
>>>> +           .sin6_family            = AF_INET6,
>>>> +           .sin6_addr              = IN6ADDR_ANY_INIT,
>>>> +   };
>>>> +   int sock;
>>>> +
>>>> +   sock = socket(sap->sa_family, SOCK_DGRAM, IPPROTO_UDP);
>>>> +   if (sock < 0)
>>>> +           return 0;
>>>> +
>>>> +   switch (sap->sa_family) {
>>>> +   case AF_INET:
>>>> +           if (bind(sock, (struct sockaddr *)&sin, sizeof(sin)) < 0) {
>>>> +                   close(sock);
>>>> +                   return 0;
>>>> +           }
>>>> +           break;
>>>> +   case AF_INET6:
>>>> +           if (bind(sock, (struct sockaddr *)&sin6, sizeof(sin6)) < 0) {
>>>> +                   close(sock);
>>>> +                   return 0;
>>>> +           }
>>>> +           break;
>>>> +   default:
>>>> +           errno = EAFNOSUPPORT;
>>>> +           return 0;
>>>> +   }
>>>> +
>>>> +   if (connect(sock, sap, salen) < 0) {
>>>> +           close(sock);
>>>> +           return 0;
>>>> +   }
>>>> +
>>>> +   return !getsockname(sock, buf, buflen);
>>>> +}
>>>> +
>>>> +/*
>>>> + * Try to generate an address that prevents the server from calling
>>>> us.
>>>> + *
>>>> + * Returns 1 and fills in @buf if successful; otherwise, zero.
>>>> + */
>>>> +static int nfs_ca_gai(const struct sockaddr *sap, const socklen_t
>>>> salen,
>>>> +                 struct sockaddr *buf, socklen_t *buflen)
>>>> +{
>>>> +   struct addrinfo *gai_results;
>>>> +   struct addrinfo gai_hint = {
>>>> +           .ai_family      = sap->sa_family,
>>>> +#ifdef GENERATE_LOOPBACK_ADDRESS
>>>> +           .ai_flags       = 0,            /* loopback */
>>>> +#else
>>>> +           .ai_flags       = AI_PASSIVE,   /* ANYADDR */
>>>> +#endif
>>>> +   };
>>>> +
>>>> +   if (getaddrinfo(NULL, "", &gai_hint, &gai_results))
>>>> +           return 0;
>>>> +
>>>> +   *buflen = gai_results->ai_addrlen;
>>>> +   memcpy(buf, gai_results->ai_addr, *buflen);
>>>> +
>>>> +   freeaddrinfo(gai_results);
>>>> +
>>>> +   return 1;
>>>> +}
>>>> +
>>>> +/**
>>>> + * nfs_callback_address - acquire our local network address
>>>> + * @sap: pointer to address of remote
>>>> + * @sap_len: length of address
>>>> + * @buf: pointer to buffer to be filled in with local network
>>>> address
>>>> + * @buflen: IN: length of buffer to fill in; OUT: length of filled-
>>>> in address
>>>> + *
>>>> + * Discover a network address that an NFSv4 server can use to call
>>>> us back.
>>>> + * On multi-homed clients, this address depends on which NIC we use
>>>> to
>>>> + * route requests to the server.
>>>> + *
>>>> + * Returns 1 and fills in @buf if an unambiguous local address is
>>>> + * available; returns 1 and fills in an appropriate ANYADDR address
>>>> + * if a local address isn't available; otherwise, returns zero.
>>>> + */
>>>> +int nfs_callback_address(const struct sockaddr *sap, const
>>>> socklen_t salen,
>>>> +                    struct sockaddr *buf, socklen_t *buflen)
>>>> +{
>>>> +   struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)buf;
>>>> +
>>>> +   if (nfs_ca_sockname(sap, salen, buf, buflen) == 0)
>>>> +           if (nfs_ca_gai(sap, salen, buf, buflen) == 0)
>>>> +                   goto out_failed;
>>>> +
>>>> +   /*
>>>> +    * The server can't use an interface ID that was generated
>>>> +    * here on the client, so always clear sin6_scope_id.
>>>> +    */
>>>> +   if (sin6->sin6_family == AF_INET6)
>>>> +           sin6->sin6_scope_id = 0;
>>>> +
>>>> +   return 1;
>>>> +
>>>> +out_failed:
>>>> +   *buflen = 0;
>>>> +   if (verbose)
>>>> +           nfs_error(_("%s: failed to construct callback address"));
>>>> +   return 0;
>>>> +
>>>> +}
>>>> diff --git a/utils/mount/network.h b/utils/mount/network.h
>>>> index 8da7e20..2f4ff3a 100644
>>>> --- a/utils/mount/network.h
>>>> +++ b/utils/mount/network.h
>>>> @@ -58,6 +58,8 @@ int nfs_string_to_sockaddr(const char *, const
>>>> size_t,
>>>> int nfs_present_sockaddr(const struct sockaddr *,
>>>>                      const socklen_t, char *, const size_t);
>>>> int get_client_address(struct sockaddr_in *, struct sockaddr_in *);
>>>> +int nfs_callback_address(const struct sockaddr *, const socklen_t,
>>>> +           struct sockaddr *, socklen_t *);
>>>> int nfs_call_umount(clnt_addr_t *, dirpath *);
>>>> int clnt_ping(struct sockaddr_in *, const unsigned long,
>>>>             const unsigned long, const unsigned int,
>>>>



-- 
Chuck Lever
