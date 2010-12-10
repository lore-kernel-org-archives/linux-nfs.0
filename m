Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:54762 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756593Ab0LJQjf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Dec 2010 11:39:35 -0500
Subject: Re: proposed patch to rpcbind to provide finer-grained security controls than offered by the -i option
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20101210153716.GA32725@ti93.telemetry-investments.com>
Date: Fri, 10 Dec 2010 11:39:12 -0500
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <7CA86579-9CA7-4476-8A1B-05825A466279@oracle.com>
References: <20101209204913.GA30338@ti93.telemetry-investments.com> <DFA85276-FD83-47A6-A9CD-B0F0A11D6086@oracle.com> <4D016F44.3020002@RedHat.com> <20101210023847.GB15344@ti93.telemetry-investments.com> <77480D58-4224-4713-A515-F1BCC133F44F@oracle.com> <20101210153716.GA32725@ti93.telemetry-investments.com>
To: "Andrew J. Schorr" <ajschorr@alumni.princeton.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 10, 2010, at 10:37 AM, Andrew J. Schorr wrote:

> On Fri, Dec 10, 2010 at 10:31:52AM -0500, Chuck Lever wrote:
>> 
>> Not to put to fine a point on it, but we discourage the use of indirect RPC calls.  It's a well-known security hole.  Also, allowing anyone to set and unset RPC registrations is also insecure, and is discouraged.
>> 
>> In general we want people to switch to using AF_UNIX for local registrations, as that is secure from remote attack, and allows rpcbind to assign ownership of the registration so that only the user who registered that service may unregister it.
>> 
>>> So I would argue that the patch is still a good thing, but I agree that
>>> I should relink my code with libtirpc.
>> 
>> IMO we shouldn't add features that encourage people to configure rpcbind insecurely, especially when there are reasonable alternatives.
> 
> Well, if the patch won't be accepted, I will not put any more time into it.

To be clear, I'm not the rpcbind maintainer, so Steve can decide to take a patch anyway.

> But I do have one question: if glibc's RPC routines are deprecated in favor of
> libtirpc, why not either remove the RPC code from glibc or at least mark these
> functions deprecated so that people get warning messages when they rebuild code
> (i.e. use __attribute__ (( __deprecated__ )) for all the functions declared in
> /usr/include/rpc/*.h)?  There does not seem to be great documentation about
> this change for ignorant users such as myself (who just upgraded Fedora
> distros and unknowingly relinked with glibc instead of libtirpc).

Welcome to Linux.  Changing glibc is viewed by some as an exceptionally challenging political task, which is why RPC hasn't been removed from it.  I quite agree that now that we have libtirpc, RPC should be removed from glibc.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




