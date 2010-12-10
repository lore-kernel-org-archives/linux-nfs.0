Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:42443 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754251Ab0LJPc3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Dec 2010 10:32:29 -0500
Subject: Re: proposed patch to rpcbind to provide finer-grained security controls than offered by the -i option
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20101210023847.GB15344@ti93.telemetry-investments.com>
Date: Fri, 10 Dec 2010 10:31:52 -0500
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <77480D58-4224-4713-A515-F1BCC133F44F@oracle.com>
References: <20101209204913.GA30338@ti93.telemetry-investments.com> <DFA85276-FD83-47A6-A9CD-B0F0A11D6086@oracle.com> <4D016F44.3020002@RedHat.com> <20101210023847.GB15344@ti93.telemetry-investments.com>
To: "Andrew J. Schorr" <ajschorr@alumni.princeton.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 9, 2010, at 9:38 PM, Andrew J. Schorr wrote:

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

Not to put to fine a point on it, but we discourage the use of indirect RPC calls.  It's a well-known security hole.  Also, allowing anyone to set and unset RPC registrations is also insecure, and is discouraged.

In general we want people to switch to using AF_UNIX for local registrations, as that is secure from remote attack, and allows rpcbind to assign ownership of the registration so that only the user who registered that service may unregister it.

> So I would argue that the patch is still a good thing, but I agree that
> I should relink my code with libtirpc.

IMO we shouldn't add features that encourage people to configure rpcbind insecurely, especially when there are reasonable alternatives.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




