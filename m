Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:33885 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716Ab2DZTEt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 15:04:49 -0400
Subject: Re: [PATCH 13/20] NFS: Fix recovery from NFS4ERR_CLID_INUSE
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1335466422.24247.8.camel@lade.trondhjem.org>
Date: Thu, 26 Apr 2012 15:04:45 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <99F031E0-3888-45A0-AA81-0F5C961B8AD8@oracle.com>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net> <20120423205505.11446.28437.stgit@degas.1015granger.net> <D6859152-CF45-44CC-BB3C-B40CB9FD0BE8@oracle.com> <1335459334.9701.25.camel@lade.trondhjem.org> <F4214CAE-E0DE-4A3C-BA0B-02A9F8277897@oracle.com> <1335466422.24247.8.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 26, 2012, at 2:53 PM, Myklebust, Trond wrote:

> On Thu, 2012-04-26 at 14:43 -0400, Chuck Lever wrote:
>> On Apr 26, 2012, at 12:55 PM, Myklebust, Trond wrote:
>> 
>>> On Thu, 2012-04-26 at 12:24 -0400, Chuck Lever wrote:
>>>> On Apr 23, 2012, at 4:55 PM, Chuck Lever wrote:
>>> Then lets move the flavour out of the clientid string,
>> 
>> Removing the flavor from the nfs_client_id4 string makes sense.
>> 
>>> and just settle
>>> for handling CLID_INUSE by changing the flavour on the SETCLIENTID call.
>> 
>> This is where I get hazy.  
>> 
>> If I simply change the authentication flavor on the existing clp->cl_rpcclient, will this affect ongoing RENEW operations that also use this transport?  Do we want subsequent RENEW operations to use the new flavor?
>> 
>> Thinking hypothetically, it seems to me that CLID_INUSE is really an indication of a permanent configuration error, or a software bug, and we should not bother to recover.  But maybe that's my limited imagination.  Under what use cases do you think CLID_INUSE might occur and it might be useful to attempt recovery?
>> 
> 
> The server caches the principal name that was used to call SETCLIENTID
> when the lease was established. Any attempt to call SETCLIENTID with a
> different principal will result in CLID_INUSE unless the lease has
> expired.
> 
> So what I was proposing wasn't that you try to change the authentication
> flavour on an existing nfs_client. It was that when you are probing, you
> can use the CLID_INUSE reply from SETCLIENTID as a direct indication
> that the server is indeed trunked, and that you already hold a lease on
> that server, but that the authentication flavour that you are trying to
> use is wrong.

The use case would be that my client has mounted a server via address X using authentication flavor 1, and then tries to mount the same server via address Y using authentication flavor 2.

Do we even need to retry the SETCLIENTID and to perform a SETCLIENTID_CONFIRM in that case?

Now, what about nfs4_reclaim_lease() ?  If the client sees CLID_INUSE during a lease reclaim, no trunking discovery is involved.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




