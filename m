Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26713 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753828Ab3KGVjX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Nov 2013 16:39:23 -0500
Message-ID: <527C08C2.9050807@RedHat.com>
Date: Thu, 07 Nov 2013 16:40:18 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>, Chuck Lever <chuck.lever@oracle.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
References: <1383851364-8370-1-git-send-email-steved@redhat.com>	<A8E8F2C4-8CB7-434E-8520-B2B53F0582D9@oracle.com> <20131107160115.0f2bd8a8@tlielax.poochiereds.net>
In-Reply-To: <20131107160115.0f2bd8a8@tlielax.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/11/13 16:01, Jeff Layton wrote:
> On Thu, 7 Nov 2013 11:25:19 -0800
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> Hi Steve-
>>
>> On Nov 7, 2013, at 11:09 AM, Steve Dickson <steved@redhat.com> wrote:
>>
>>> This new module parameter makes the v4 client
>>> use the minimal authentication flavor (AUTH_UNIX)
>>> when establishing NFSV4 state and doing the
>>> pseudoroot lookup
>>
>> The patch description doesn't say, but is this change to work around the 15 second GSSD upcall timeout? Have we completely given up on fixing the upcall?
>>
> 
> That would be my preferred solution too. The whole problem is that this
> upcall takes too damned long to time out.
> 
> But...how can it be fixed?
> 
> Due to the way that rpc_pipefs interface works, there's no way that I
> can see to make that fail immediately if no one is listening on the
> pipe. You could reduce the timeout I guess but that's sort of a
> half-assed solution.
> 
> IMO, we're long past due for a new upcall that uses a different design
> altogether. Maybe something based on call_usermodehelper that doesn't
> require a running daemon?
Bingo! I think it would be huge for all these upcalls to work like the idmapping
does on the client (aka via call_usermodehelper)... but which the likes
of Kerberos it may not be possible... 

steved.

> 
