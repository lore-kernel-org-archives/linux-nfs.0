Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44442 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619AbbGMOdG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 10:33:06 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH 4/9] NFS: Use RPC functions for matching sockaddrs
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <55A3C976.20302@Netapp.com>
Date: Mon, 13 Jul 2015 10:32:38 -0400
Cc: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <6CFC438A-9FED-49CC-A7BA-9C5AF757C916@oracle.com>
References: <1436561897-8051-1-git-send-email-Anna.Schumaker@Netapp.com> <1436561897-8051-5-git-send-email-Anna.Schumaker@Netapp.com> <20150713070311.GH26245@infradead.org> <55A3C976.20302@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 13, 2015, at 10:21 AM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:

> On 07/13/2015 03:03 AM, Christoph Hellwig wrote:
>>> static int nfs_sockaddr_cmp_ip6(const struct sockaddr *sa1,
>>> 				const struct sockaddr *sa2)
>>> {
>>> 	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sa1;
>>> 	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sa2;
>>> 
>>> -	return nfs_sockaddr_match_ipaddr6(sa1, sa2) &&
>>> -		(sin1->sin6_port == sin2->sin6_port);
>>> +	return rpc_cmp_addr6(sa1, sa2) && (sin1->sin6_port == sin2->sin6_port);
>>> }
>>> 
>>> static int nfs_sockaddr_cmp_ip4(const struct sockaddr *sa1,
>>> @@ -350,31 +301,8 @@ static int nfs_sockaddr_cmp_ip4(const struct sockaddr *sa1,
>>> 	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sa1;
>>> 	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sa2;
>>> 
>>> -	return nfs_sockaddr_match_ipaddr4(sa1, sa2) &&
>>> -		(sin1->sin_port == sin2->sin_port);
>>> -}
>> 
>> I'd say kill nfs_sockaddr_cmp as well and use rpc_cmp_addr in
>> nfs_match_client.
>> 
> 
> Okay, looking closer at the code now.  rpc_cmp_addr() explicitely doesn't check for port number, but nfs_sockaddr_cmp() does.  I could add port checking to rpc_cmp_addr(), but I don't know if it was left out intentionally when the code was written.

Consider adding rpc_cmp_addr_port() which does port checking too?


--
Chuck Lever



