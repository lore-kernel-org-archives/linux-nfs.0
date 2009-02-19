From: Jeff Garzik <jeff@garzik.org>
Subject: Re: NFS4ERR_DENIED becomes EIO?
Date: Wed, 18 Feb 2009 20:22:48 -0500
Message-ID: <499CB468.7050702@garzik.org>
References: <499C7B53.5030802@garzik.org> <1234994399.8412.206.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36852 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751883AbZBSBWw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Feb 2009 20:22:52 -0500
In-Reply-To: <1234994399.8412.206.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Wed, 2009-02-18 at 16:19 -0500, Jeff Garzik wrote:
>> I think I may have found a tiny NFSv4 client bug.  What I am seeing:
>>
>> 1. On Linux NFS client (2.6.29-rc2), issue chown(1) to change the owner 
>> of the file (causing SETATTR:OWNER to be issued)
>>
>> 2. My userland NFS server returns NFS4ERR_DENIED for the SETATTR op
>>
>> 3. Linux NFS client returns EIO (I/O error) to userland
>>
>> That was a bit unexpected.  I would have guessed EPERM, perhaps.
>>
>> 	Jeff
> 
> I'd put this down as a server bug, as rfc 3530 really reserves the error
> NFS4ERR_DENIED for the LOCK/LOCKT/LOCKU operations.
> 
> In the case of a chown(), I'd expect the server to return NFS4ERR_PERM
> when failing because the caller is not root or the file owner. The
> client will then correctly translate that into an EPERM...

So noted...  thanks a bunch!  I'll make that change.

	Jeff


