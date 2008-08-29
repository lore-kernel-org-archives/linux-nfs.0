From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/6] 2nd IPv6 patchset for 2.6.28 (repost)
Date: Fri, 29 Aug 2008 13:29:12 -0400
Message-ID: <76bd70e30808291029j1da5db26waa3e4db93c2a857d@mail.gmail.com>
References: <20080827204852.17837.38361.stgit@manray.1015granger.net>
	 <20080829172506.GB7099@fieldses.org>
	 <20080829172530.GC7099@fieldses.org>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.191]:23875 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494AbYH2R3O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Aug 2008 13:29:14 -0400
Received: by mu-out-0910.google.com with SMTP id g7so770913muf.1
        for <linux-nfs@vger.kernel.org>; Fri, 29 Aug 2008 10:29:12 -0700 (PDT)
In-Reply-To: <20080829172530.GC7099@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 29, 2008 at 1:25 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Fri, Aug 29, 2008 at 01:25:06PM -0400, bfields wrote:
>> On Wed, Aug 27, 2008 at 04:56:58PM -0400, Chuck Lever wrote:
>> > Based on review comments, I've changed how the NFSv4 callback server
>> > starts its listener.  If the kernel has IPv6 support, it will start an
>> > AF_INET6 listener; otherwise it will start an AF_INET listener.
>> >
>> > Subsequent lockd IPv6 patches already work this way, it turns out, so
>> > I've updated the patch in this subseries that adds a helper to display
>> > NLM IPv6 addresses.  If an IPv6 address is a mapped IPv4 address, it
>> > will be displayed as a dotted-quad instead of as an IPv6 address.  This
>> > should cause the helper to display IPv4-style addresses on systems that
>> > use only IPv4, even though the listener is AF_INET6.  This effects
>> > only error and debugging messages.
>> >
>> > I should revisit other areas (already integrated, and in pending
>> > patches) which display presentation format addresses, to ensure they
>> > follow suit.
>>
>> I already applied 2-6, so I've removed those and replaced them by your
>> new versions.  The resulting change is just the following.
>
> Whoops, sorry, I meant:
>
> --b.
>
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index 3f0c1a8..008e402 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -18,6 +18,7 @@
>  #include <linux/lockd/sm_inter.h>
>  #include <linux/mutex.h>
>
> +#include <net/ipv6.h>
>
>  #define NLMDBG_FACILITY                NLMDBG_HOSTCACHE
>  #define NLM_HOST_NRHASH                32
> @@ -65,7 +66,11 @@ static void nlm_display_address(const struct sockaddr *sap,
>                snprintf(buf, len, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
>                break;
>        case AF_INET6:
> -               snprintf(buf, len, NIP6_FMT, NIP6(sin6->sin6_addr));
> +               if (ipv6_addr_v4mapped(&sin6->sin6_addr))
> +                       snprintf(buf, len, NIPQUAD_FMT,
> +                                NIPQUAD(sin6->sin6_addr.s6_addr32[3]));
> +               else
> +                       snprintf(buf, len, NIP6_FMT, NIP6(sin6->sin6_addr));
>                break;
>        default:
>                snprintf(buf, len, "unsupported address family");

Yes, I think that's the only change in patches 2-6.

--
Chuck Lever
