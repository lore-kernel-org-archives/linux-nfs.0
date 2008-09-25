From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] NFS: SETCLIENTID truncates client ID and netid
Date: Thu, 25 Sep 2008 14:51:37 -0400
Message-ID: <306811F2-3AD5-4FC8-BE6B-E29C0E61C3E0@oracle.com>
References: <20080925154814.8353.64762.stgit@manray.1015granger.net> <20080925155712.8353.47707.stgit@manray.1015granger.net> <48DBCBDC.9060305@redhat.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: trond.myklebust@netapp.com, bfields@fieldses.org,
	linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:59400 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754030AbYIYSwd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Sep 2008 14:52:33 -0400
In-Reply-To: <48DBCBDC.9060305@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 25, 2008, at 1:35 PM, Peter Staubach wrote:

> Chuck Lever wrote:
>> The sc_name field is currently 56 bytes long.  This is not large  
>> enough
>> to hold a pair of IPv6 addresses, the authentication type, the  
>> protocol
>> name, and a uniquifier number.  The maximum possible size of the name
>> string using IPv6 addresses is just under 110 bytes, so I increased  
>> the
>> size of the sc_name field to accomodate this maximum.
>>
>> In addition, the strings in the nfs4_setclientid structure are
>> constructed with scnprintf(), which wants to terminate its output  
>> with
>> '\0'.  The sc_netid field was large enough only for a three byte  
>> netid
>> string and a '\0' so inet6 netids were being truncated.  Perhaps we
>> don't need the overhead of scnprintf() to do a simple string copy,  
>> but
>> I fixed this by increasing the size of the buffer by one byte.
>>
>> Since all three of the string buffers in nfs4_setclientid are
>> constructed with scnprintf(), I increased the size of all three by  
>> one
>> byte to document the requirement, although I don't think either the
>> universal address field or the name field will be so small that these
>> strings get truncated in this way.
>>
>> The size of the Linux client's client ID on the wire will be larger
>> than before.  RFC 3530 suggests the size limit for client IDs is  
>> 1024,
>> and we are still well below that.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> include/linux/nfs_xdr.h |    8 ++++----
>> 1 files changed, 4 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
>> index 8c77c11..dc34977 100644
>> --- a/include/linux/nfs_xdr.h
>> +++ b/include/linux/nfs_xdr.h
>> @@ -672,16 +672,16 @@ struct nfs4_rename_res {
>> 	struct nfs_fattr *		new_fattr;
>> };
>> -#define NFS4_SETCLIENTID_NAMELEN	(56)
>> +#define NFS4_SETCLIENTID_NAMELEN	(128)
>>
>
> Perhaps (127) might have been a better choice here?  In the
> struct below, the arrays end up being allocated to (128) + 1
> plus whatever alignment bytes are valid for the platform.
> This wastes a fair amount of space.

Probably the worst alignment padding would be 7 bytes.  The struct is  
already large, and is only used once on the stack just after mounting,  
so I'm not that concerned.  I would rather have a little extra here  
than not enough.

However, we can trim the length of the name a little.  I counted about  
105 characters maximum in my simple calculations.  We could probably  
make it (111) to round out the field to 112 bytes (divisible by 8).

>       ps
>
>> struct nfs4_setclientid {
>> 	const nfs4_verifier *		sc_verifier;
>> 	unsigned int			sc_name_len;
>> -	char				sc_name[NFS4_SETCLIENTID_NAMELEN];
>> +	char				sc_name[NFS4_SETCLIENTID_NAMELEN + 1];
>> 	u32				sc_prog;
>> 	unsigned int			sc_netid_len;
>> -	char				sc_netid[RPCBIND_MAXNETIDLEN];
>> +	char				sc_netid[RPCBIND_MAXNETIDLEN + 1];
>> 	unsigned int			sc_uaddr_len;
>> -	char				sc_uaddr[RPCBIND_MAXUADDRLEN];
>> +	char				sc_uaddr[RPCBIND_MAXUADDRLEN + 1];
>> 	u32				sc_cb_ident;
>> };
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



