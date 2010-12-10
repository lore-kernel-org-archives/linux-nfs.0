Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8853 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752736Ab0LJNwP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 08:52:15 -0500
Message-ID: <4D023081.9050102@RedHat.com>
Date: Fri, 10 Dec 2010 08:52:01 -0500
From: Steve Dickson <SteveD@redhat.com>
To: "Andrew J. Schorr" <ajschorr@alumni.princeton.edu>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: proposed patch to rpcbind to provide finer-grained security controls
 than offered by the -i option
References: <20101209204913.GA30338@ti93.telemetry-investments.com> <DFA85276-FD83-47A6-A9CD-B0F0A11D6086@oracle.com> <4D016F44.3020002@RedHat.com> <20101210023847.GB15344@ti93.telemetry-investments.com>
In-Reply-To: <20101210023847.GB15344@ti93.telemetry-investments.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 12/09/2010 09:38 PM, Andrew J. Schorr wrote:
> On Thu, Dec 09, 2010 at 07:07:32PM -0500, Steve Dickson wrote:
>>
>>
>> On 12/09/2010 04:41 PM, Chuck Lever wrote:
>>> It sounds like your application is trying to use glibc's RPC 
>>> implementation with rpcbind.  If you build your application with 
>>> libtirpc instead, it should use an AF_UNIX socket to contact rpcbind 
>>> instead of loopback.  The AF_UNIX socket carries some authentication 
>>> information with the registration request.  All users of your 
>>> application would be allowed to set or unset RPC registrations 
>>> in that case.
> 
> I think you are correct.  This is probably due to some combination
> of ignorance and stupidity on my part.  I didn't realize that libtirpc
> was a drop-in replacement for the glibc RPC routines.
> 
>> I was under the impression rebuilding the applications was not
>> possible... but maybe I misunderstood... 
> 
> Rebuilding should be possible, I need to look into this.
> 
>> But in the end, I guess I'm not against having functionality 
>> like this... If it make it easier for people to port legacy
>> applications to Linux, its probably a good thing... 
> 
> I think the patch does add more control over rpcbind behavior, but I
> grant that it may be less interesting if nobody is using IP to connect
> from local clients.  Nonetheless, it still adds the ability to have
> separate control over whether to accept remote set/unset calls and
> whether to honor indirect/callit calls.  Unless I'm mistaken, this is
> still relevant even if libtirpc is used.
> 
> So I would argue that the patch is still a good thing, but I agree that
> I should relink my code with libtirpc.
If you decide to officially resubmit the patch please
1) Please sign you patch with a  Signed-off-by: line as
    described in: 
      http://www.linuxtv.org/wiki/index.php/Development:_Submitting_Patches

2) Also include a separate patch that updates the manual page.
   (I can help with the nroff formatting). 

tia,

steved.
