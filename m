From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: NFS and mobile clients - can it work?
Date: Mon, 22 Sep 2008 11:00:07 +0530
Message-ID: <OF6640388A.E528F300-ON652574CC.001DC61A-652574CC.001E395A@in.ibm.com>
References: <18646.58594.377630.950531@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([59.145.155.6]:45310 "EHLO
	e28esmtp06.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751354AbYIVFbl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Sep 2008 01:31:41 -0400
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m8M5Va1m027123
	for <linux-nfs@vger.kernel.org>; Mon, 22 Sep 2008 11:01:36 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8M5Uaoi1515550
	for <linux-nfs@vger.kernel.org>; Mon, 22 Sep 2008 11:01:25 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m8M5UZqH009752
	for <linux-nfs@vger.kernel.org>; Mon, 22 Sep 2008 15:30:36 +1000
In-Reply-To: <18646.58594.377630.950531-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil,

If you have running over IPv6, you can use Mobile IPv6 (configure
IPv6_MIP6)
to make this work over TCP. I have never tried it, but theoretically it
should
work. Mobile IP will fool the TCP layer (and other ULP's) onwards by
passing
the "home" network address while using the new network address internally
at
IP layer for communication (both sends and recvs).

- KK

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
>
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
>
>  If there were any active locks, there is probably nothing useful that
>  can be done for them.  Unless the client manages to send a NOTIFY to
>  the server before changing IP address, the server will never drop the
>  locks.   Maybe "-o remount,reopen" would only work if "-o nolocks"
>  were in force.  It's not an ideal solution, but it might be better
>  than the current situations?
>
>  I'm not sure whether NFSv4 makes this easier or harder.  Can you
>  continue a client session (SET_CLIENTID) from a different IP address?
>  Can you change the callback address for a CLIENT once it is created?
>
>
>  For now, I think the options are to use UDP (which has it's own
>  problems) or to for an unmount (--lazy) when the client IP address
>  changes.
>
> Thoughts?
>
> Thanks,
> NeilBrown
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

