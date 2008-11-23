From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NLM: AF_UNSPEC addresses are all equal
Date: Sat, 22 Nov 2008 21:08:30 -0500
Message-ID: <F3857F53-32D5-47C6-AE76-D1575F5C7091@oracle.com>
References: <20081122165521.3765.1127.stgit@ingres.1015granger.net>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:22522 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755156AbYKWCIs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Nov 2008 21:08:48 -0500
In-Reply-To: <20081122165521.3765.1127.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

On Nov 22, 2008, at Nov 22, 2008, 11:58 AM, Chuck Lever wrote:
> The nlm_cmp_addr() function, which compares two IP addresses, is
> sometimes used to check AF_UNSPEC addresses.  If both addresses are
> AF_UNSPEC, then it should consider them equal -- the contents of an
> AF_UNSPEC address, other than the address family, are
> inconsequential.
>
> This is important because the loop in nlm_lookup_host() always
> compares the h_srcaddr field to the incoming source address.  For
> client nlm_host entries, both are always AF_UNSPEC, and should allow
> the entry match to succeed.  If it always fails, then we create a
> fresh nlm_host entry every time we mount the same server, even if
> all other items in the existing entry (protocol, NLM version, host
> address) match.
>
> These extra entries will eventually expire once the server is
> unmounted, so the impact of this bug, introduced in 2.6.28 with
> commit 781b61a6, should be minor.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> Bruce-
>
> Another minor lockd IPv6 bug fix for 2.6.28.
>
> Alternate fix for this problem is to change nlm_lookup_host() so that
> it compares the srcaddrs only when h_server is set.

I now have a patch that does this instead, and it seems to make more  
sense to me.

>  include/linux/lockd/lockd.h |    2 ++
> 1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
> index b56d5aa..e8aa108 100644
> --- a/include/linux/lockd/lockd.h
> +++ b/include/linux/lockd/lockd.h
> @@ -344,6 +344,8 @@ static inline int nlm_cmp_addr(const struct  
> sockaddr *sap1,
> {
> 	if (sap1->sa_family == sap2->sa_family) {
> 		switch (sap1->sa_family) {
> +		case AF_UNSPEC:
> +			return 1;
> 		case AF_INET:
> 			return __nlm_cmp_addr4(sap1, sap2);
> 		case AF_INET6:
>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
