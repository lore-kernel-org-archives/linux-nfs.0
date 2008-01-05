From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: A new NFSv4 server...
Date: Sat, 05 Jan 2008 13:32:43 +1100
Message-ID: <477EEC4B.3050108@melbourne.sgi.com>
References: <200801041548.KAA18953@snowhite.cis.uoguelph.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: jeff@garzik.org, linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Rick Macklem <rick-bYVALtacgsT800Iu1Vt84J3p9npsUQCG@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:58406 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754641AbYAECYr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jan 2008 21:24:47 -0500
In-Reply-To: <200801041548.KAA18953-bYVALtacgsT800Iu1Vt84J3p9npsUQCG@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rick Macklem wrote:
>> You had me worried there for a moment, I thought you might be the first
>> person to admit to liking the NFS4 protocol design.
>>     
>
> I actually like quite a bit about it, although I agree that the XDR/Sun
> RPC underpinnings are getting pretty tired (mid-1980s). I liked Sessions,
> but think that it's gotten overly complex (why 5 required encrypted
> checksum algorithms, wouldn't one be enough? for example).

Agreed, the basic ideas behind Sessions are good and long overdue.

>  It would have been simpler,
> if it had been "posix only" and not tried to be Windows compatible, but
> I see the argument for Windows compatibility, hense the Open.
>   

I don't see the argument.  I've yet to meet a sysadmin who would want
to use NFS from a Windows client when that client already has a adequate
remote filesystem client implementation on it.

>   
>> The classic persistent file handles, for example, could be considered a
>> major
>> design flaw.  Firstly it makes the inode# -> dentry lookup a performance
>> path
>> for the underlying filesystem, which it isn't in any local load. 
>>     
>
> Sounds like a server implementor's perspective. 
Well, yeah ;-)

> From a client implementor's
> point of view, a T-stable file handle is a wonderful thing. I have no idea
> how to correctly implement client side support for the volatile file
> handles allowed in NFSv4. My client doesn't support them.
>   
I can see how volatile file handles would be a problem for clients, and
I don't think they're the answer either.  For files, a better solution
would be to use an index into a small per-session table of open files.
Directories are a different matter though.

-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

