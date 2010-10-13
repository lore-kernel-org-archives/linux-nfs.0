Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4277 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752076Ab0JMRk4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Oct 2010 13:40:56 -0400
Message-ID: <4CB5EF15.5030003@RedHat.com>
Date: Wed, 13 Oct 2010 13:40:37 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Jeff Layton <jlayton@redhat.com>, Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: whither NFS umount?
References: <678C897C-DECE-49C1-AFC4-B57CF3A09385@oracle.com>	 <1286903046.24878.13.camel@heimdal.trondhjem.org>	 <C5614601-A685-4D7A-8DC3-23375F88AF42@oracle.com>	 <20101012151826.76b75f52@corrin.poochiereds.net> <1286912649.1956.19.camel@heimdal.trondhjem.org>
In-Reply-To: <1286912649.1956.19.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Sorry for joining late... 

On 10/12/2010 03:44 PM, Trond Myklebust wrote:
> On Tue, 2010-10-12 at 15:18 -0400, Jeff Layton wrote:
> 
>> I think the part that causes problems is having userspace do this. In
>> theory, if the kernel were in charge of sending the UMNT, then it's not
>> really a problem since it knows when to do it. If we have code that
>> sends a UMNT already, why not do a best-effort UMNT call from the
>> kernel when we tear down the sb?
> 
> Purely for the pleasure of allowing the server to maintain inaccurate
> statistics about who is currently mounting what? I think not...
> 
> You can get far more accurate results by replacing the MNT/UMNT state
> counter with a purely server-based scheme to track who accessed one or
> more files on each exported partition in the past 5 minutes or so. That
> would even work with NFSv4...
> 
>> Either way, eliminating umount.nfs would be nice...
> 
> Agreed.
I having a hard time understanding this logic... 

Why do we think we (the Linux community) can simply 
throw way an established part of the protocol just because 
we deem it advisory... Now maybe in our implementation UMNT its
advisory and it might even be advisory in the spec, but how do we 
know with  other NFS implementation is not advisory, its actually needed.
We don't known and we can't known....

Now when our implementation becomes an NFSv4 only implementation, 
I say fine; Eliminate all the protocols that go along
with both v2 and v3. But until then lets just have leave
the legacy protocols along and move forward in more meaningful 
efforts... 

steved.
 


