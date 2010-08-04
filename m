Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35669 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750921Ab0HDP2x convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 11:28:53 -0400
Subject: Re: Kerberized NFS (v3 and v4) does not work if Kerberos token is >= 2048 bytes (if PAGE_SIZE == 4096)
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <E820D075-2582-4FF8-B788-14D41070DA29@illinois.edu>
Date: Wed, 4 Aug 2010 11:28:35 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <D17BAFDB-6B3B-40B6-9C28-5689D18FBBA5@netapp.com>
References: <E820D075-2582-4FF8-B788-14D41070DA29@illinois.edu>
To: Jonathan Manton <jmanton@illinois.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Yes, this limitation has been known for a long time. We ran into this same issue using X.509 certs and spkm3. I imagine PKINIT will also hit this limitation.

-->Andy

On Aug 4, 2010, at 10:38 AM, Jonathan Manton wrote:

> Kerberized NFS does not work for users who have a Kerberos token that is 2048 bytes or larger (assuming PAGE_SIZE == 4096).  This can (easily) happen in enterprise environments that use Active Directory as their Kerberos source, due to the additional Privilege Account Certificate (PAC) added by AD to the token.
> 
> When a user with a Kerberos token of 2048 bytes or larger attempts to access a filesystem mounted using Kerberized NFS, the NFS server locks up for 30 seconds, and ultimately the call fails.
> 
> The root cause of this problem is the interface between the sunrpc layer and the rpc.svcgssd daemon.  When an NFS NULL request comes in from a client to establish the initial security context, information is passed via the rpc cache mechanism through a named pipe (sunrpc_cache_pipe_upcall() in net/sunrpc/cache.c), to be consumed by the rpc.svcgssd daemon.  This results in the upcall data being formatted via rsi_request() in net/sunrpc/auth_gss/svcauth_gss.c.  rsi_request() uses the qword_addhex() routine (implemented in net/sunrpc/cache.c) to encode the upcall data as ASCII for the named pipe.
> 
> The issue is that the upcall data is limited to PAGE_SIZE bytes (this buffer is allocated in sunrpc_cache_pipe_upcall).  On my kernel at least, this is 4096 bytes.  The upcall data is encoded as ASCII characters.  It takes two ASCII characters to encode each byte of upcall data, meaning that any token over 2047 bytes will fill the buffer and result in an error condition.
> 
> When that happens, sunrpc_cache_pipe_upcall returns -EAGAIN, which implies (according to Documentation/filesystems/nfs/rpc-cache.txt) that the upcall is pending, even though in fact sunrpc_cache_pipe_upcall has actually freed the buffer and never added the call to the cache request queue.
> 
> The result is that all nfsd kernel processes continue to try to process the request and check back on the request, continuously, for 30 seconds, trying to enqueue the upcall.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

