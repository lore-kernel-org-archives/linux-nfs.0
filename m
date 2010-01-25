From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] statd: Teach nfs_compare_sockaddr() to handle NULL arguments.
Date: Mon, 25 Jan 2010 13:18:03 -0500
Message-ID: <8B71F5B0-04B5-4276-AD7C-B2E5A4BBD7A6@oracle.com>
References: <4B5DCDEB.60708@RedHat.com> <B551AB0E-5D8A-4ABD-B333-F55C8DEE3906@oracle.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:36963 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752632Ab0AYSS5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jan 2010 13:18:57 -0500
In-Reply-To: <B551AB0E-5D8A-4ABD-B333-F55C8DEE3906@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 25, 2010, at 1:05 PM, Chuck Lever wrote:

> On Jan 25, 2010, at 11:59 AM, Steve Dickson wrote:
>> It seems the list of interfaces returned by getifaddrs()
>> can contain a null address pointer (ifa->ifa_addr) even though
>> the interface is marked UP (this happens with the tun0 interface).
>
> It might be nice to document this quirk in from_local.c.
>
>> So this patch makes nfs_compare_sockaddr() return false
>> if either one of its arguments is null..
>>
>> Author: Steve Dickson <steved@redhat.com>
>> Date:   Mon Jan 25 11:42:36 2010 -0500
>>
>>   Teach nfs_compare_sockaddr() to handle NULL arguments.
>>
>>   Signed-off-by: Steve Dickson <steved@redhat.com>
>
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

Hrm.  On second thought....

Catching these in nfs_compare_sockaddr() will make it harder to find  
NULL pointer bugs in other parts of the code, I would think.  Instead,  
maybe you should trap these in from_local.c.  That way you document  
the quirk (as above) as well.

>> diff --git a/support/include/sockaddr.h b/support/include/sockaddr.h
>> index 732514b..9af2543 100644
>> --- a/support/include/sockaddr.h
>> +++ b/support/include/sockaddr.h
>> @@ -20,6 +20,7 @@
>> #ifndef NFS_UTILS_SOCKADDR_H
>> #define NFS_UTILS_SOCKADDR_H
>>
>> +#include <libio.h>
>> #include <stdbool.h>
>> #include <sys/socket.h>
>> #include <netinet/in.h>
>> @@ -223,6 +224,9 @@ compare_sockaddr6(__attribute__ ((unused))  
>> const struct sockaddr *sa1,
>> static inline _Bool
>> nfs_compare_sockaddr(const struct sockaddr *sa1, const struct  
>> sockaddr *sa2)
>> {
>> +	if (sa1 == NULL || sa2 == NULL)
>> +		return false;
>> +
>> 	if (sa1->sa_family == sa2->sa_family)
>> 		switch (sa1->sa_family) {
>> 		case AF_INET:
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




