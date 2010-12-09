Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:50579 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754145Ab0LIVlp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Dec 2010 16:41:45 -0500
Subject: Re: proposed patch to rpcbind to provide finer-grained security controls than offered by the -i option
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20101209204913.GA30338@ti93.telemetry-investments.com>
Date: Thu, 9 Dec 2010 16:41:35 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <DFA85276-FD83-47A6-A9CD-B0F0A11D6086@oracle.com>
References: <20101209204913.GA30338@ti93.telemetry-investments.com>
To: "Andrew J. Schorr" <ajschorr@alumni.princeton.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 9, 2010, at 3:49 PM, Andrew J. Schorr wrote:

> Hi,
> 
> The current rpcbind -i option seems to relax 3 different security requirements.
> If the user wants to allow any one of the three, he is forced to allow
> all 3.
> 
> The attached patch introduces 3 new options (-c, -r, and -u) to break this
> down to give the user control of which security requirements to relax.
> 
> This patch compiles, but has not been tested yet.  If there is any
> interest in accepting this, I will of course test it. :-)  But it's fairly
> basic, so I thought I'd gauge the interest level first.  Steve
> Dickson from Redhat suggested that I post here to discuss this issue
> regarding https://bugzilla.redhat.com/show_bug.cgi?id=481422

Looking over the bug...

It sounds like your application is trying to use glibc's RPC implementation with rpcbind.  If you build your application with libtirpc instead, it should use an AF_UNIX socket to contact rpcbind instead of loopback.  The AF_UNIX socket carries some authentication information with the registration request.  All users of your application would be allowed to set or unset RPC registrations in that case.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




