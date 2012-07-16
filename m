Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:39580 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754216Ab2GPTJI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Jul 2012 15:09:08 -0400
Subject: Re: [PATCH 13/15] NFS: Discover NFSv4 server trunking when mounting
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1342465540.4648.25.camel@lade.trondhjem.org>
Date: Mon, 16 Jul 2012 15:09:03 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <FA164FA1-5E20-4958-887C-6B5C503B841F@oracle.com>
References: <20120711201718.3767.66867.stgit@degas.1015granger.net> <20120711203134.3767.47961.stgit@degas.1015granger.net> <1342465540.4648.25.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 16, 2012, at 3:05 PM, Myklebust, Trond wrote:

> On Wed, 2012-07-11 at 16:31 -0400, Chuck Lever wrote:
>> "Server trunking" is a fancy named for a multi-homed NFS server.
>> Trunking might occur if a client sends NFS requests for a single
>> workload to multiple network interfaces on the same server.  There
>> are some implications for NFSv4 state management that make it useful
>> for a client to know if a single NFSv4 server instance is
>> multi-homed.  (Note this is only a consideration for NFSv4, not for
>> legacy versions of NFS, which are stateless).
>> 
>> If a client cares about server trunking, no NFSv4 operations can
>> proceed until that client determines who it is talking to.  Thus
>> server IP trunking discovery must be done when the client first
>> encounters an unfamiliar server IP address.
>> 
>> The nfs_get_client() function walks the nfs_client_list and matches
>> on server IP address.  The outcome of that walk tells us immediately
>> if we have an unfamiliar server IP address.  It invokes
>> nfs_init_client() in this case.  Thus, nfs4_init_client() is a good
>> spot to perform trunking discovery.
>> 
>> Discovery requires a client to establish a fresh client ID, so our
>> client will now send SETCLIENTID or EXCHANGE_ID as the first NFS
>> operation after a successful ping, rather than waiting for an
>> application to perform an operation that requires NFSv4 state.
>> 
>> The exact process for detecting trunking is different for NFSv4.0 and
>> NFSv4.1, so a minorversion-specific init_client callout method is
>> introduced.
>> 
>> CLID_INUSE recovery is important for the trunking discovery process.
>> CLID_INUSE is a sign the server recognizes the client's nfs_client_id4
>> id string, but the client is using the wrong principal this time for
>> the SETCLIENTID operation.  The SETCLIENTID must be retried with a
>> series of different principals until one works, and the rest of
>> trunking discovery can proceed.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> fs/nfs/client.c    |  237 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>> fs/nfs/internal.h  |    6 +
>> fs/nfs/nfs4_fs.h   |    8 ++
>> fs/nfs/nfs4proc.c  |    2 
>> fs/nfs/nfs4state.c |  186 ++++++++++++++++++++++++++++++++++++++++-
>> 5 files changed, 433 insertions(+), 6 deletions(-)
> 
> Applying: NFS: Discover NFSv4 server trunking when mounting
> error: patch failed: fs/nfs/nfs4state.c:1656
> error: fs/nfs/nfs4state.c: patch does not apply
> Patch failed at 0001 NFS: Discover NFSv4 server trunking when mounting

I can take a look.  What are you applying it to, exactly?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




