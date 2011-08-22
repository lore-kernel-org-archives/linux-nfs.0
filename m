Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:64629 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753403Ab1HVTcd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Aug 2011 15:32:33 -0400
Subject: Re: [PATCH] sunrpc: Add scope id to svc_addr_u for IPv6 LINKLOCAL address
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110822192620.GB16261@fieldses.org>
Date: Mon, 22 Aug 2011 15:32:13 -0400
Cc: Mi Jinlong <mijinlong@cn.fujitsu.com>, NFS <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Message-Id: <3CA77E10-4099-4DDB-BE7A-88395CC34C93@oracle.com>
References: <4E4F8B5D.6060404@cn.fujitsu.com> <20110822192620.GB16261@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 22, 2011, at 3:26 PM, J. Bruce Fields wrote:

> On Sat, Aug 20, 2011 at 06:24:29PM +0800, Mi Jinlong wrote:
>> +/* 
>> + * Add scope id for LINKLOCAL address
>> + */
>> +struct in6_addr_scopeid{
>> +	struct in6_addr	sin6_addr;
>> +	__u32		sin6_scope_id;
>> +};
>> +
>> union svc_addr_u {
>> -    struct in_addr	addr;
>> -    struct in6_addr	addr6;
>> +	struct in_addr		addr;
>> +	struct in6_addr_scopeid	addr6;
> 
> By the way, is there any reason why nfsd really needs its own address
> structure?  Shouldn't we use sockaddr_storage or something?  I feel like
> we've got a little too much one-off address handling in nfsd.

That would be my only complaint about the patch.

I think we chose a smaller struct here to save space, and we could do that because we didn't need a port number or scope ID.  If a scope ID is indeed required, then we should consider something larger like a struct sockaddr_storage, IMO.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




