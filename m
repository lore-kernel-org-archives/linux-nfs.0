From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFS and mobile clients - can it work?
Date: Wed, 24 Sep 2008 11:24:03 -0400
Message-ID: <48DA5B93.5030307@RedHat.com>
References: <18646.58594.377630.950531@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37559 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751528AbYIXPZ2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2008 11:25:28 -0400
In-Reply-To: <18646.58594.377630.950531-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil Brown wrote:
> Hi.
> 
>  Suppose I have a mobile client such as a notebook computer which
>  changes networks from time to time - e.g. when "docked" it uses a
>  wired network, but when I "undock" it uses a wireless network.  And
>  as I move around it might change from one wireless network to
>  another.
> 
>  Is it at all reasonable to expect that I could have an NFS mounted
>  filesystem that continues to work across all of those changes?
> 
>  If we just assume NFSv3 and ignore locking for the moment, then this
>  seems to work quite well if you use UDP, but fails badly if you use
>  TCP.  This is because the connected socket holds on to the old source
>  address.
Could this possibly be handled by some type of user-level connection manager that would be able to deal with the changing of a server's IP address? 
  
> 
>  I think that the only way to get the client to close and re-open the
>  socket would be to wait for 5 minutes with no IO requests.  But that
>  would be hard to ensure.  Any attempt to access any file will trigger
>  a request which will keep retrying which will keep the socket active,
>  so the client won't close it.... It doesn't seem to work anyway.  The
>  RPC client appears to try to connect from the same source IP address,
>  though I haven't checked the code to be sure of this.
Again, this is where I think a connection manager could help... The kernel could do a "this server is broken give me another please" up-call and the CM could do all the needed host-to-address translation, making sure the IP address that is passed down a valid and working address...  

Continuing with this theory... this might be a cheap and dirty way of getting redundant or failover mount for v2/v3... with read-only mounts of course... 

> 
>  Would it be worthwhile/practical to have a 'remount' mount option to
>  request that the socket be closed and re-opened?
Only if we could teach autofs to do this... otherwise it should be 
auto-magically... imho..

> 
>  If there were any active locks, there is probably nothing useful that
>  can be done for them.  Unless the client manages to send a NOTIFY to
>  the server before changing IP address, the server will never drop the
>  locks.   Maybe "-o remount,reopen" would only work if "-o nolocks"
>  were in force.  It's not an ideal solution, but it might be better
>  than the current situations?
Or read-only mounts...  Meaning, we start with read-only and then move on to read/write  mounts..

> 
>  I'm not sure whether NFSv4 makes this easier or harder.  Can you
>  continue a client session (SET_CLIENTID) from a different IP address?
>  Can you change the callback address for a CLIENT once it is created?
I would think easier since there is less traffic between the server and client due to delegations... 

my two cents...

steved.
