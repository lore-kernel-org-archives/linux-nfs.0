Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27338 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753408Ab0LJAHk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Dec 2010 19:07:40 -0500
Message-ID: <4D016F44.3020002@RedHat.com>
Date: Thu, 09 Dec 2010 19:07:32 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Andrew J. Schorr" <ajschorr@alumni.princeton.edu>,
        linux-nfs@vger.kernel.org
Subject: Re: proposed patch to rpcbind to provide finer-grained security controls
 than offered by the -i option
References: <20101209204913.GA30338@ti93.telemetry-investments.com> <DFA85276-FD83-47A6-A9CD-B0F0A11D6086@oracle.com>
In-Reply-To: <DFA85276-FD83-47A6-A9CD-B0F0A11D6086@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 12/09/2010 04:41 PM, Chuck Lever wrote:
> 
> On Dec 9, 2010, at 3:49 PM, Andrew J. Schorr wrote:
> 
>> Hi,
>>
>> The current rpcbind -i option seems to relax 3 different security requirements.
>> If the user wants to allow any one of the three, he is forced to allow
>> all 3.
>>
>> The attached patch introduces 3 new options (-c, -r, and -u) to break this
>> down to give the user control of which security requirements to relax.
>>
>> This patch compiles, but has not been tested yet.  If there is any
>> interest in accepting this, I will of course test it. :-)  But it's fairly
>> basic, so I thought I'd gauge the interest level first.  Steve
>> Dickson from Redhat suggested that I post here to discuss this issue
>> regarding https://bugzilla.redhat.com/show_bug.cgi?id=481422
> 
> Looking over the bug...
> 
> It sounds like your application is trying to use glibc's RPC 
> implementation with rpcbind.  If you build your application with 
> libtirpc instead, it should use an AF_UNIX socket to contact rpcbind 
> instead of loopback.  The AF_UNIX socket carries some authentication 
> information with the registration request.  All users of your 
> application would be allowed to set or unset RPC registrations 
> in that case.
> 
I was under the impression rebuilding the applications was not
possible... but maybe I misunderstood... 

But in the end, I guess I'm not against having functionality 
like this... If it make it easier for people to port legacy
applications to Linux, its probably a good thing... 

steved.
