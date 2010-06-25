Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:38001 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755996Ab0FYU1l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jun 2010 16:27:41 -0400
Message-ID: <4C2510C6.902@oracle.com>
Date: Fri, 25 Jun 2010 16:25:42 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org, trond.myklebust@fys.uio.no,
        Staubach_Peter@emc.com, bfields@fieldses.org
Subject: Re: [PATCH 1/2] sunrpc: split the vs_hidden flag into TCP and UDP
 variants (try #2)
References: <1277480946-23844-1-git-send-email-jlayton@redhat.com>	<4C24D057.4090403@oracle.com>	<20100625120710.2ead8998@tlielax.poochiereds.net>	<4C24D95F.6090301@oracle.com> <20100625134754.51e313fa@tlielax.poochiereds.net>
In-Reply-To: <20100625134754.51e313fa@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/25/10 01:47 PM, Jeff Layton wrote:
> nfsd shares the same sockets between all NFS versions. We can't change
> that since you don't know what NFS version you're getting a call for
> until you read in the data. There's really no way around this.

That is worth mentioning in a documenting comment before nfsd4_dispatch().

I feel that we're adding yet another kludge to the NFSD infrastructure 
to preserve an aging user space API and transport design that was built 
for an era when all NFS versions would always use every transport and 
address family.

I agree with Peter that we should make an effort to use the RPC 
infrastructure as it was intended, in order to advertise the correct 
services and transport capabilities; and update our user space API to 
allow user space to have more fine-grained control over what the kernel 
will advertise and run.  But perhaps that's for another day.
