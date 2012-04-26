Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:41508 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752284Ab2DZSn7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 14:43:59 -0400
Subject: Re: [PATCH 13/20] NFS: Fix recovery from NFS4ERR_CLID_INUSE
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=windows-1252
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1335459334.9701.25.camel@lade.trondhjem.org>
Date: Thu, 26 Apr 2012 14:43:52 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <F4214CAE-E0DE-4A3C-BA0B-02A9F8277897@oracle.com>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net> <20120423205505.11446.28437.stgit@degas.1015granger.net> <D6859152-CF45-44CC-BB3C-B40CB9FD0BE8@oracle.com> <1335459334.9701.25.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 26, 2012, at 12:55 PM, Myklebust, Trond wrote:

> On Thu, 2012-04-26 at 12:24 -0400, Chuck Lever wrote:
>> On Apr 23, 2012, at 4:55 PM, Chuck Lever wrote:
>> 
>>> For NFSv4 minor version 0, currently the cl_id_uniquifier allows the
>>> Linux client to generate a unique nfs_client_id4 string whenever a
>>> server replies with NFS4ERR_CLID_INUSE.
>>> 
>>> NFS4ERR_CLID_INUSE actually means that the client has presented this
>>> nfs_client_id4 string with a different authentication flavor in the
>>> past.  Retrying with a different nfs_client_id4 string means the
>>> client orphans NFSv4 state on the server.  This state will take at
>>> least a whole lease period to be purged.
>>> 
>>> Change recovery to try the identification operation again with a
>>> different auth flavor until it works.  The retry loop is factored
>>> out of nfs4_proc_setclientid() and into the state manager, so that
>>> both mv0 and mv1 client ID establishment is covered by the same
>>> CLID_INUSE recovery logic.
>>> 
>>> XXX: On further review, I'm not sure how it would be possible to
>>> send an nfs_client_id4 with the wrong authentication flavor, since
>>> the au_name is part of the string itself...
>> 
>> I'm having other doubts about this whole approach.
>> 
>> In the loop in nfs4_reclaim_lease(), the client will need to replace the RPC transport for each retried flavor, and then continue using the transport that worked.  New mounts clone their transport from the nfs_client, even if its authentication flavor does not match what might have been specified on the mount.  (I haven't checked this, is it true?)

It looks like nfs_init_server_rpcclient() changes the flavor of the RPC transport that was cloned from cl_rpcclient, so that shouldn't be a problem.

>> What's more, there's no way a server can identify a re-used nfs_client_id4, since we currently plant the authentication flavor in the nfs_client_id4 string…
>> 
>> In fact, because we generate nfs_client_id4 strings with the flavor built in, won't each flavor used on a mount generate a separate lease on the server?
> 
> Then lets move the flavour out of the clientid string,

Removing the flavor from the nfs_client_id4 string makes sense.

> and just settle
> for handling CLID_INUSE by changing the flavour on the SETCLIENTID call.

This is where I get hazy.  

If I simply change the authentication flavor on the existing clp->cl_rpcclient, will this affect ongoing RENEW operations that also use this transport?  Do we want subsequent RENEW operations to use the new flavor?

Thinking hypothetically, it seems to me that CLID_INUSE is really an indication of a permanent configuration error, or a software bug, and we should not bother to recover.  But maybe that's my limited imagination.  Under what use cases do you think CLID_INUSE might occur and it might be useful to attempt recovery?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




