Return-Path: linux-nfs-owner@vger.kernel.org
Received: from lo.gmane.org ([80.91.229.12]:54231 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751986Ab1KPO6W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Nov 2011 09:58:22 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1RQgwO-0003Co-TP
	for linux-nfs@vger.kernel.org; Wed, 16 Nov 2011 15:58:20 +0100
Received: from nat12.iteam.ua ([194.146.132.141])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 16 Nov 2011 15:58:20 +0100
Received: from free.lan.c2.718r by nat12.iteam.ua with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 16 Nov 2011 15:58:20 +0100
To: linux-nfs@vger.kernel.org
From: Pavel <free.lan.c2.718r@gmail.com>
Subject: Re: clients fail to reclaim locks after server reboot or manual sm-notify
Date: Wed, 16 Nov 2011 14:58:08 +0000 (UTC)
Message-ID: <loom.20111116T155422-74@post.gmane.org>
References: <loom.20111114T180637-632@post.gmane.org> <4EC1678D.902@netapp.com> <4EC18E5F.4080101@netapp.com> <loom.20111115T142111-739@post.gmane.org> <4EC2DE49.5070000@netapp.com> <20111115221623.GA12453@fieldses.org> <4EC3C7BD.6060407@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bryan Schumaker <bjschuma@...> writes:

> > On Tue, Nov 15, 2011 at 04:48:57PM -0500, Bryan Schumaker wrote:
> >
> > Sorry, I'm having trouble keeping up....  What exactly do you do, on
> > which machine, and what do you then see happen?
> 
> Here is what I'm doing (On debian with 2.6.32):
> - (On Client) Mount the server: `sudo mount -o vers=3 
> 192.168.122.202:/home/bjschuma /mnt`
> - (On Client) Lock a file using nfs-utils/tools/locktest: `./testlk 
> /mnt/test`
> - (On Server) Call sm-notify with the server's IP address: `sudo 
> sm-notify -f -v 192.168.122.202`
> - dmesg on the client has this message:
>     lockd: spurious grace period reject?!
>     lockd: failed to reclaim lock for pid 2099 (errno -37, status 4)
> - (In wireshark) The client sends a lock request with the "Reclaim" bit 
> set to "yes" but the server replies with "NLM_DENIED_GRACE_PERIOD".
> 
> Shouldn't the server be allowing the lock reclaim?  When I tried 
> yesterday using 3.0 it only triggered DNS packets, I tried again a few 
> minutes ago and got the same results that I did using .32.
> 
> - Bryan
> 

Yes, everything is exactly as you wrote.

After the steps above I also get the following in client logs:
lockd: server in grace period
lockd: spurious grace period reject?!
lockd: failed to reclaim lock for pid 2508 (errno -37, status 4)

Thank you all for taking time!

