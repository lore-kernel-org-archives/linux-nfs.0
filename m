From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 01/14] NLM: Beef up NLM address display function
Date: Wed, 29 Oct 2008 16:05:33 -0400
Message-ID: <A44F37EE-4E28-4678-A64A-82129B198450@oracle.com>
References: <20081024180150.23810.9718.stgit@ingres.1015granger.net> <20081024180954.23810.34150.stgit@ingres.1015granger.net> <20081029192514.GA1406@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:59993 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305AbYJ2UFp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Oct 2008 16:05:45 -0400
In-Reply-To: <20081029192514.GA1406@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 29, 2008, at 3:25 PM, J. Bruce Fields wrote:
> On Fri, Oct 24, 2008 at 02:09:54PM -0400, Chuck Lever wrote:
>> Add support for IPv6 addresses with a scope ID,
>
> I remain a bit confused about scope ID's.  If you tell me they're
> needed, I'll believe you.

In this case we need to be able to send an IPv6 address to user space  
(in addition to the original use for this code, which was just to  
print debugging information).

To support locking and NSM with link-local addresses (which need an  
interface ID to work) we need to have scope ID support here.

>> and enable calls from outside of fs/lockd/host.c
>
> Some day of course it'd be nice to collect all the basic "display an
> ipv6 address" code together in one place!

There's a storm brewing on netdev to put address printing support into  
the kernel's implementation of vsnprintf (in preference to NIPQUAD and  
NIP6), so this may all go away at some point soon.

>> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
>> index 9fd8889..c7516ae 100644
>> --- a/fs/lockd/host.c
>> +++ b/fs/lockd/host.c
>> @@ -104,29 +104,54 @@ static void nlm_clear_port(struct sockaddr  
>> *sap)
>> 	}
>> }
>>
>> -static void nlm_display_address(const struct sockaddr *sap,
> ...
>> +int nlm_display_address(const struct sockaddr *sap, char *buf,
>
> The return value is never used, even after your other patches.  Do you
> have any plans to use it?

I thought it was used in the NSM code.  I'll review that before  
submitting these again.

> --b.
>
>> +			const size_t len)
>> +{
>> 	switch (sap->sa_family) {
>> 	case AF_UNSPEC:
>> -		snprintf(buf, len, "unspecified");
>> -		break;
>> +		snprintf(buf, len, "unspecified address");
>> +		return -EAFNOSUPPORT;
>> 	case AF_INET:
>> -		snprintf(buf, len, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
>> -		break;
>> +		return nlm_display_ipv4_address(sap, buf, len);
>> 	case AF_INET6:
>> -		if (ipv6_addr_v4mapped(&sin6->sin6_addr))
>> -			snprintf(buf, len, NIPQUAD_FMT,
>> -				 NIPQUAD(sin6->sin6_addr.s6_addr32[3]));
>> -		else
>> -			snprintf(buf, len, NIP6_FMT, NIP6(sin6->sin6_addr));
>> -		break;
>> +		return nlm_display_ipv6_address(sap, buf, len);
>> 	default:
>> 		snprintf(buf, len, "unsupported address family");
>> -		break;
>> +		return -EAFNOSUPPORT;
>> 	}
>> }

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
