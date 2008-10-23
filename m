From: Michel Lespinasse <walken-Y93EPB1FQwg@public.gmane.org>
Subject: Fwd: NFS 5-minute hangs upon S3 resume using 2.6.27 client
Date: Wed, 22 Oct 2008 21:02:31 -0700
Message-ID: <20081023040231.GA13512@zoy.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server.lespinasse.org ([64.142.28.226]:57917 "EHLO
	server.lespinasse.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbYJWEhE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Oct 2008 00:37:04 -0400
Received: from michel.lespinasse.org (michel.home.lespinasse.org [10.1.0.1])
	by server.lespinasse.org (Postfix) with ESMTP id DED352FC1C
	for <linux-nfs@vger.kernel.org>; Wed, 22 Oct 2008 21:02:31 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I sent this out to LKML earlier but was told this would be a better list.
This has been mentionned in bugzilla already, but I'd like to draw attention
before it gets too late for 2.6.28 (or is it already too late ???)

The following is a common cause of 5-minute NFS hangs here:

* Client has TCP connections to the NFS server, goes to S3 sleep for few hours.
* TCP connections die on the server side.
  (not 100% sure why, do they use some kind of keepalive ???)
* Client resumes from S3.
* Client sends NFS requests down its TCP connections, gets back RST packet.
* [Client hangs for exactly 300 seconds here]
* Client establishes new TCP connections to the NFS server,
  and recovers from the hang.

A tcpdump trace is attached at the end of bugzilla bug 11154:
http://bugzilla.kernel.org/show_bug.cgi?id=11154

Should the client immediately try to reconnect when its existing connection
receives an RST packet ? (the 5 minute delay would make sense to me if
RST was received in reply to a SYN, but I'm not sure about it in the case
of an existing open TCP connection).

If the 5 minute delay after an RST is necessary, could the client avoid it
by explicitly closing/reopening its connections using suspend/resume hooks ?

(I can not work around the issue locally by mounting/unmounting my NFS
shares around the suspend/resume because rootfs also on NFS...)

This NFS setup was working fine in 2.6.24. There has been issues with
2.6.25 and 2.6.26, but I did not confirm if they are the same bug.
2.6.25 usualy recovers after some variable delay and 2.6.26 usualy
does not recover. Bugs 11154 and 11061 have more details about this,
also Ian Campbell has been tracking an NFS issue under load that
appeared at around the same time.

Hope this helps,

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.
