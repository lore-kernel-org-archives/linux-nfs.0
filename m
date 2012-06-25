Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:17576 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755516Ab2FYUsa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jun 2012 16:48:30 -0400
Message-ID: <4FE8CE8C.7020007@netapp.com>
Date: Mon, 25 Jun 2012 16:48:12 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: rpcauth_create() returns ERR_PTR
References: <17B0469E-0417-4F74-A035-625D41E5609B@oracle.com>
In-Reply-To: <17B0469E-0417-4F74-A035-625D41E5609B@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/25/2012 04:43 PM, Chuck Lever wrote:
> Hi-
> 
> nfs4_create_sec_client() and nfs4_lookup_root_sec() both invoke rpcauth_create().  They check to see that it returned something that wasn't NULL.
> 
> As far as I can tell, rpcauth_create() reports an error by returning something that IS_ERR.  It doesn't return NULL.  nfs_init_server_rpcclient() appears to be correct.
> 
> The fix looks simple, but since I don't have any unit tests for this area of code, I was hoping you could take it from here.
> 

Sure, I'll take a look at it.  You're right, checking for an error code instead of NULL sounds like an easy fix.

- Bryan

