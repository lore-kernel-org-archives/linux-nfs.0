From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: NFS and mobile clients - can it work?
Date: Wed, 24 Sep 2008 12:49:02 +0530
Message-ID: <48D9E9E6.8000706@suse.de>
References: <18646.58594.377630.950531@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:49012 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbYIXHSW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2008 03:18:22 -0400
In-Reply-To: <18646.58594.377630.950531-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil Brown wrote:
> 
>  Suppose I have a mobile client such as a notebook computer which
>  changes networks from time to time - e.g. when "docked" it uses a
>  wired network, but when I "undock" it uses a wireless network.  And
>  as I move around it might change from one wireless network to
>  another.

This is quite a common scenario these days.

>  Is it at all reasonable to expect that I could have an NFS mounted
>  filesystem that continues to work across all of those changes?

I think it is reasonable to expect with the changing network paradigm of
mobile computing. Successful protocols/implementations always have
adapted themselves to the changing (network) needs :)

>  I think that the only way to get the client to close and re-open the
>  socket would be to wait for 5 minutes with no IO requests.  But that
>  would be hard to ensure.  Any attempt to access any file will trigger
>  a request which will keep retrying which will keep the socket active,
>  so the client won't close it.... It doesn't seem to work anyway.  The
>  RPC client appears to try to connect from the same source IP address,
>  though I haven't checked the code to be sure of this.
> 
>  Would it be worthwhile/practical to have a 'remount' mount option to
>  request that the socket be closed and re-opened?

or better name would be 'reconnect'?

>  If there were any active locks, there is probably nothing useful that
>  can be done for them.  Unless the client manages to send a NOTIFY to
>  the server before changing IP address, the server will never drop the
>  locks.   Maybe "-o remount,reopen" would only work if "-o nolocks"
>  were in force.  It's not an ideal solution, but it might be better
>  than the current situations?

Definitely, it can make mobile clients life easier. And it looks to me
that all of these can be done at the userspace itself.

>  I'm not sure whether NFSv4 makes this easier or harder.  Can you
>  continue a client session (SET_CLIENTID) from a different IP address?
>  Can you change the callback address for a CLIENT once it is created?

I think 'nolock' and 'nfs4' can't be used together and nfs4 always will
enable locking.


Thanks,

-- 
Suresh Jayaraman
