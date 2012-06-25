Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:44253 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791Ab2FYV5i convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jun 2012 17:57:38 -0400
Subject: Re: rpcauth_create() returns ERR_PTR
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=US-ASCII
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4FE8CE8C.7020007@netapp.com>
Date: Mon, 25 Jun 2012 17:56:32 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <2692BB15-F696-49CB-977B-0A1BCCF4CF56@oracle.com>
References: <17B0469E-0417-4F74-A035-625D41E5609B@oracle.com> <4FE8CE8C.7020007@netapp.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 25, 2012, at 4:48 PM, Bryan Schumaker wrote:

> On 06/25/2012 04:43 PM, Chuck Lever wrote:
>> Hi-
>> 
>> nfs4_create_sec_client() and nfs4_lookup_root_sec() both invoke rpcauth_create().  They check to see that it returned something that wasn't NULL.
>> 
>> As far as I can tell, rpcauth_create() reports an error by returning something that IS_ERR.  It doesn't return NULL.  nfs_init_server_rpcclient() appears to be correct.
>> 
>> The fix looks simple, but since I don't have any unit tests for this area of code, I was hoping you could take it from here.
>> 
> 
> Sure, I'll take a look at it.  You're right, checking for an error code instead of NULL sounds like an easy fix.

I'm trying to call rpcauth_create() in a loop, as your code does, and the call is failing with -EEXIST on the GSS flavors.  If you just check rpcauth_create's return code for NULL, you will miss this and think the call succeeded.

gss_pipes_dentries_create_net() doesn't seem to like being called twice.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




