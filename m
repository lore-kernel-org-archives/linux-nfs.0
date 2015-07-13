Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:59855 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751451AbbGMO2G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2015 10:28:06 -0400
Subject: Re: [PATCH 4/9] NFS: Use RPC functions for matching sockaddrs
To: Christoph Hellwig <hch@infradead.org>
References: <1436561897-8051-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1436561897-8051-5-git-send-email-Anna.Schumaker@Netapp.com>
 <20150713070311.GH26245@infradead.org>
CC: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <55A3C976.20302@Netapp.com>
Date: Mon, 13 Jul 2015 10:21:42 -0400
MIME-Version: 1.0
In-Reply-To: <20150713070311.GH26245@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/13/2015 03:03 AM, Christoph Hellwig wrote:
>>  static int nfs_sockaddr_cmp_ip6(const struct sockaddr *sa1,
>>  				const struct sockaddr *sa2)
>>  {
>>  	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sa1;
>>  	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sa2;
>>  
>> -	return nfs_sockaddr_match_ipaddr6(sa1, sa2) &&
>> -		(sin1->sin6_port == sin2->sin6_port);
>> +	return rpc_cmp_addr6(sa1, sa2) && (sin1->sin6_port == sin2->sin6_port);
>>  }
>>  
>>  static int nfs_sockaddr_cmp_ip4(const struct sockaddr *sa1,
>> @@ -350,31 +301,8 @@ static int nfs_sockaddr_cmp_ip4(const struct sockaddr *sa1,
>>  	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sa1;
>>  	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sa2;
>>  
>> -	return nfs_sockaddr_match_ipaddr4(sa1, sa2) &&
>> -		(sin1->sin_port == sin2->sin_port);
>> -}
> 
> I'd say kill nfs_sockaddr_cmp as well and use rpc_cmp_addr in
> nfs_match_client.
> 

Okay, looking closer at the code now.  rpc_cmp_addr() explicitely doesn't check for port number, but nfs_sockaddr_cmp() does.  I could add port checking to rpc_cmp_addr(), but I don't know if it was left out intentionally when the code was written.

Trond?

Anna
