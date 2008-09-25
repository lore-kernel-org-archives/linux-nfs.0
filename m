From: Neil Brown <neilb@suse.de>
Subject: Re: NFS and mobile clients - can it work?
Date: Thu, 25 Sep 2008 14:13:44 +1000
Message-ID: <18651.4088.147169.7967@notabene.brown>
References: <18646.58594.377630.950531@notabene.brown>
	<48D9E9E6.8000706@suse.de>
	<48DA401D.2040804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Suresh Jayaraman <sjayaraman@suse.de>, linux-nfs@vger.kernel.org
To: Ric Wheeler <rwheeler@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:37240 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751496AbYIYENr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Sep 2008 00:13:47 -0400
In-Reply-To: message from Ric Wheeler on Wednesday September 24
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday September 24, rwheeler@redhat.com wrote:
> Suresh Jayaraman wrote:
> > Neil Brown wrote:
> >   
> >>  Suppose I have a mobile client such as a notebook computer which
> >>  changes networks from time to time - e.g. when "docked" it uses a
> >>  wired network, but when I "undock" it uses a wireless network.  And
> >>  as I move around it might change from one wireless network to
> >>  another.
> >>     
> >
> > This is quite a common scenario these days.
> >
> >   
> >>  Is it at all reasonable to expect that I could have an NFS mounted
> >>  filesystem that continues to work across all of those changes?
> >>     
> >
> > I think it is reasonable to expect with the changing network paradigm of
> > mobile computing. Successful protocols/implementations always have
> > adapted themselves to the changing (network) needs :)
> >   
> 
> The other place to address this is in the networking layer itself. If I 
> remember correctly, there is support in IPV6 for "mobile IP" which might 
> allow you to do this:
> 
> http://www.ietf.org/rfc/rfc2002.txt
> 
> I have no idea how much of this made it into working systems,
> 

You can get the same effect of a mobile IP with IPv4 using a VPN, such
as OpenVPN.

I think I've come to the conclusion that this is the only way to
reliably have a mobile NFS mount.  The server really has too much
investment in the IP of the client, both for locking and for the reply
cache.  Because of these, the Linux NFS client tries hard to reconnect
from the same source address when it does reconnect, and this is
unlikely to change (I suspect).

When a client does change IP address, all NFS mounts should be
unmounted (probably umount --lazy) and an automounter should be used
to re-establish them on demand.

It is conceivable that the connection could be broken and
re-established without requiring the re-mount.  But as it would have
to drop all locks and lose any benefits of the server's reply cache,
it should not happen automatically.

If you want really mobile mounts, use OpenVPN or similar.

Thanks everyone for your input.

NeilBrown
