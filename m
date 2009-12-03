From: Kelly Anderson <kelly-lACMDn57031vQQPgy9v2K1aTQe2KTcn/@public.gmane.org>
Subject: Re: [NFS] Nfs4 over Ipv6 patch to fix ipv6 subnetting in /etc/exports
Date: Wed, 02 Dec 2009 17:16:04 -0700
Message-ID: <4B170344.9070205@silka.with-linux.com>
References: <4B16EF49.8040106@silka.with-linux.com> <5A28692A-9683-4B49-A016-6639BD80E1BC@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 216-146-103-100.dsl.nemontel.net ([216.146.103.100]:60599 "EHLO
	silka.with-linux.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbZLCAag (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Dec 2009 19:30:36 -0500
In-Reply-To: <5A28692A-9683-4B49-A016-6639BD80E1BC@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/02/2009 04:32 PM, Chuck Lever wrote:
> [Cc: correct mailing list]
>
> IPv6 support in mountd is entirely experimental (ie not guaranteed to 
> work), and exists only my personal git repo, not in the official 
> nfs-utils git repo.  However, it looks like you are working against my 
> code.

I got it from the following.
git://git.linux-nfs.org/projects/cel/nfs-utils.git

>
>
> Also, we prefer patches submitted inline, not as attachments, as that 
> makes it easy to hit "reply" and comment on the content of the patch.  
> A patch description and a Signed-off-by: line is required.  Take a 
> look in the archives of this mailing list for examples.
>
> Basically your patch misapplies the address mask in check_subnet_v6, 
> so I don't think it's the right fix.  Instead of "sin6 & mask" you 
> have "sin6 & sin6" which basically means the mask is ignored, and the 
> check will always succeed.
>
> Maybe the mask generation code in init_netmask() is not correct?

I think you missread the patch. So I posted the complete patched 
function.  The problem was sin6->sin6_addr.s6_addr should be 
sin6->sin6_addr.s6_addr32.  It doesn't make sense to compare an 8 bit 
value with a 32 bit value.  Notice it's really comparing "address" to 
"sin6" so it's really ((address ^ sin6) & mask).  sin6 is a poor choice 
of variable names in this case since it makes it hard to interpret the code.

static int
check_subnet_v6(const struct sockaddr_in6 *address,
         const struct sockaddr_in6 *mask, const struct addrinfo *ai)
{
     for (; ai; ai = ai->ai_next) {
         struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)ai->ai_addr;

         if (sin6->sin6_family != AF_INET6)
             continue;

         if (mask_match(address->sin6_addr.s6_addr32[0],
                 sin6->sin6_addr.s6_addr32[0],
                       mask->sin6_addr.s6_addr32[0]) &&
             mask_match(address->sin6_addr.s6_addr32[1],
                 sin6->sin6_addr.s6_addr32[1],
                       mask->sin6_addr.s6_addr32[1]) &&
             mask_match(address->sin6_addr.s6_addr32[2],
                 sin6->sin6_addr.s6_addr32[2],
                       mask->sin6_addr.s6_addr32[2]) &&
             mask_match(address->sin6_addr.s6_addr32[3],
                 sin6->sin6_addr.s6_addr32[3],
                       mask->sin6_addr.s6_addr32[3]))
             return 1;
     }
     return 0;
}


--- ./support/export/client.c.orig    2009-11-30 08:06:18.000000000 -0700
+++ ./support/export/client.c    2009-12-02 15:16:55.361725808 -0700
@@ -505,16 +505,16 @@ check_subnet_v6(const struct sockaddr_in
              continue;

          if (mask_match(address->sin6_addr.s6_addr32[0],
-                sin6->sin6_addr.s6_addr[0],
+                sin6->sin6_addr.s6_addr32[0],
                        mask->sin6_addr.s6_addr32[0]) &&
              mask_match(address->sin6_addr.s6_addr32[1],
-                sin6->sin6_addr.s6_addr[1],
+                sin6->sin6_addr.s6_addr32[1],
                        mask->sin6_addr.s6_addr32[1]) &&
              mask_match(address->sin6_addr.s6_addr32[2],
-                sin6->sin6_addr.s6_addr[2],
+                sin6->sin6_addr.s6_addr32[2],
                        mask->sin6_addr.s6_addr32[2]) &&
              mask_match(address->sin6_addr.s6_addr32[3],
-                sin6->sin6_addr.s6_addr[3],
+                sin6->sin6_addr.s6_addr32[3],
                        mask->sin6_addr.s6_addr32[3]))
              return 1;
      }


