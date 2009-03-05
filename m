From: "Kevin W. Rudd" <solgato@us.ibm.com>
Subject: Re: Memory corruption in nfs3_xdr_setaclargs()
Date: Thu, 5 Mar 2009 08:33:28 -0800 (PST)
Message-ID: <alpine.LFD.1.10.0903050829420.3949@w-kevinr.beaverton.ibm.com>
References: <49760685.4030409@redhat.com> <1232475301.7055.14.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:60855 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753461AbZCEQdg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 11:33:36 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e37.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n25GXB87005075
	for <linux-nfs@vger.kernel.org>; Thu, 5 Mar 2009 09:33:11 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n25GXW1v145326
	for <linux-nfs@vger.kernel.org>; Thu, 5 Mar 2009 09:33:33 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n25GXWMm005733
	for <linux-nfs@vger.kernel.org>; Thu, 5 Mar 2009 09:33:32 -0700
In-Reply-To: <1232475301.7055.14.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 20 Jan 2009, Trond Myklebust wrote:

> Date: Tue, 20 Jan 2009 13:15:01 -0500
> From: Trond Myklebust <trond.myklebust@fys.uio.no>
> To: Sachin S. Prabhu <sprabhu@redhat.com>
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: Memory corruption in nfs3_xdr_setaclargs()
> 
> On Tue, 2009-01-20 at 17:14 +0000, Sachin S. Prabhu wrote:
>> A mistake in calculating the space left in the header in nfs3_xdr_setaclargs()
>> can cause memory corruption when setting a large number of acls.
>>
>> Reproducer:
>>
>> On Server:
>> 1) Create directory /test and set mode 777.
>> mkdir /test; chmod 777 /test
>> 2) Add 200 users and set default acl for user on /test
>> for i in {1..200}; do echo $i; useradd user$i; setfacl -m d:u:user$i:rwx
>> /test;done
>> 3) Add export /test  in /etc/exports
>> /test *(rw)
>>
>> On client
>> 1) Mount server:/test
>> mount server:/test /mnt
>> 2) Create large number of directories on the the share.
>> cd/mnt; for i in {1..1000}; do mkdir $i; done
>> At this point, the client should crash.
>>
>> A change in call_header changes the value req->rq_snd_buf->head[0]->iov_len to
>> reflect the exact size of the header.
>> [PATCH] RPC: Ensure XDR iovec length is initialized correctly in call_header
>> 334ccfd545bba9690515f2c5c167d5adb161989b
>>
>> The iov_len is set to the size of the header in  call_header().
>> req->rq_slen = xdr_adjust_iovec(&req->rq_svec[0], p);
>>
>> nfs3_xdr_setaclargs() depends on the older behavior and uses this value when
>> calculating the number of ACLs it can fit into the header.
>>
>>         /* put as much of the acls into head as possible. */
>>         len_in_head = min_t(unsigned int, buf->head->iov_len - base, len);
>>         len -= len_in_head;
>>         req->rq_slen = xdr_adjust_iovec(req->rq_svec, p + (len_in_head >> 2));
>>
>> Since at this stage, iov_len < base, len_in_head will always be set to len. For
>> a large number of ACLs, this will end up over-writing other parts of memory on
>> the nfs client.
>>
>> The following patch which set len_in_head to 0 was tested with the reproducer
>> and was found to fix the problem.
>>
>
> Looks alright. Could you please add a s-o-b line?
>
> Cheers
>  Trond
>
>> --- fs/nfs/nfs3xdr.c.orig	2009-01-20 15:18:12.000000000 +0000
>> +++ fs/nfs/nfs3xdr.c	2009-01-20 15:33:45.000000000 +0000
>> @@ -691,7 +691,10 @@ nfs3_xdr_setaclargs(struct rpc_rqst *req
>>  	*p++ = htonl(args->mask);
>>  	base = (char *)p - (char *)buf->head->iov_base;
>>  	/* put as much of the acls into head as possible. */
>> -	len_in_head = min_t(unsigned int, buf->head->iov_len - base, len);
>> +	if ( buf->head->iov_len > base )
>> +		len_in_head = min_t(unsigned int, buf->head->iov_len - base, len);
>> +	else
>> +		len_in_head = 0;
>>  	len -= len_in_head;
>>  	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p + (len_in_head >> 2));
>>
>> Thanks to Kevin Rudd who did the major legwork here to figure the problem and
>> create the patch.
>>
>> Sachin Prabhu
>>

Trond,

Do you know what happened to this patch?  Given the nasty corruption
aspect to the bug, we were expecting to see a fix for this merged into
the mainline by now.

Thanks

-Kevin

--
  Kevin W. Rudd
  IBM Global Services - Linux L3
  1-800-426-7378,  1-503-578-4161, T/L 775-4161
