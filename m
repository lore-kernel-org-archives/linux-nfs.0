From: Neil Brown <neilb@suse.de>
Subject: NFS and mobile clients - can it work?
Date: Mon, 22 Sep 2008 10:20:50 +1000
Message-ID: <18646.58594.377630.950531@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:41129 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752842AbYIVBXu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Sep 2008 21:23:50 -0400
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id F19B2418CE
	for <linux-nfs@vger.kernel.org>; Mon, 22 Sep 2008 03:23:48 +0200 (CEST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi.

 Suppose I have a mobile client such as a notebook computer which
 changes networks from time to time - e.g. when "docked" it uses a
 wired network, but when I "undock" it uses a wireless network.  And
 as I move around it might change from one wireless network to
 another.

 Is it at all reasonable to expect that I could have an NFS mounted
 filesystem that continues to work across all of those changes?

 If we just assume NFSv3 and ignore locking for the moment, then this
 seems to work quite well if you use UDP, but fails badly if you use
 TCP.  This is because the connected socket holds on to the old source
 address.

 I think that the only way to get the client to close and re-open the
 socket would be to wait for 5 minutes with no IO requests.  But that
 would be hard to ensure.  Any attempt to access any file will trigger
 a request which will keep retrying which will keep the socket active,
 so the client won't close it.... It doesn't seem to work anyway.  The
 RPC client appears to try to connect from the same source IP address,
 though I haven't checked the code to be sure of this.

 Would it be worthwhile/practical to have a 'remount' mount option to
 request that the socket be closed and re-opened?

 If there were any active locks, there is probably nothing useful that
 can be done for them.  Unless the client manages to send a NOTIFY to
 the server before changing IP address, the server will never drop the
 locks.   Maybe "-o remount,reopen" would only work if "-o nolocks"
 were in force.  It's not an ideal solution, but it might be better
 than the current situations?

 I'm not sure whether NFSv4 makes this easier or harder.  Can you
 continue a client session (SET_CLIENTID) from a different IP address?
 Can you change the callback address for a CLIENT once it is created?


 For now, I think the options are to use UDP (which has it's own
 problems) or to for an unmount (--lazy) when the client IP address
 changes.

Thoughts?

Thanks,
NeilBrown
