From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: NFS 5-minute hangs upon S3 resume using 2.6.27 client
Date: Thu, 23 Oct 2008 00:15:20 +0200
Message-ID: <200810230015.20493.rjw@sisk.pl>
References: <20081022212934.GA24143@zoy.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Michel Lespinasse <walken-Y93EPB1FQwg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:34340 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754729AbYJVWK4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2008 18:10:56 -0400
In-Reply-To: <20081022212934.GA24143-Y93EPB1FQwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday, 22 of October 2008, Michel Lespinasse wrote:
> Hi,

Hi,

> This has been mentionned in bugzilla already, but I'd like to draw attention
> before it gets too late for 2.6.28.

I'm afraid it already is too late.

> The following is a common cause of 5-minute NFS hangs here:
> 
> * Client has TCP connections to the NFS server, goes to S3 sleep for few hours.
> * TCP connections die on the server side.
>   (not 100% sure why, do they use some kind of keepalive ???)
> * Client resumes from S3.
> * Client sends NFS requests down its TCP connections, gets back RST packet.
> * [Client hangs for exactly 300 seconds here]
> * Client establishes new TCP connections to the NFS server,
>   and recovers from the hang.
> 
> A tcpdump trace is attached at the end of bugzilla bug 11154:
> http://bugzilla.kernel.org/show_bug.cgi?id=11154
> 
> Should the client immediately try to reconnect when its existing connection
> receives an RST packet ? (the 5 minute delay would make sense to me if
> RST was received in reply to a SYN, but I'm not sure about it in the case
> of an existing open TCP connection).
> 
> If the 5 minute delay after an RST is necessary, could the client avoid it
> by explicitly closing/reopening its connections using suspend/resume hooks ?
> 
> (I can not work around the issue locally by mounting/unmounting my NFS
> shares around the suspend/resume because rootfs also on NFS...)
> 
> This NFS setup was working fine in 2.6.24. There has been issues with
> 2.6.25 and 2.6.26, but I did not confirm if they are the same bug.
> 2.6.25 usualy recovers after some variable delay and 2.6.26 usualy
> does not recover. Bugs 11154 and 11061 have more details about this,
> also Ian Campbell has been tracking an NFS issue under load that
> appeared at around the same time.
> 
> Hope this helps,

Thanks for the info, but I'm not a networking expert.

You should have CCed the NFS people, but it looks like they already know.

Thanks,
Rafael
