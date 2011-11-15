Return-Path: linux-nfs-owner@vger.kernel.org
Received: from lo.gmane.org ([80.91.229.12]:34540 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756665Ab1KORUX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Nov 2011 12:20:23 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1RQMg9-0004JK-SY
	for linux-nfs@vger.kernel.org; Tue, 15 Nov 2011 18:20:13 +0100
Received: from nat12.iteam.ua ([194.146.132.141])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 15 Nov 2011 18:20:13 +0100
Received: from free.lan.c2.718r by nat12.iteam.ua with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 15 Nov 2011 18:20:13 +0100
To: linux-nfs@vger.kernel.org
From: Pavel <free.lan.c2.718r@gmail.com>
Subject: Re: clients fail to reclaim locks after server reboot or manual sm-notify
Date: Tue, 15 Nov 2011 17:19:59 +0000 (UTC)
Message-ID: <loom.20111115T181523-12@post.gmane.org>
References: <loom.20111114T180637-632@post.gmane.org> <4EC1678D.902@netapp.com> <4EC18E5F.4080101@netapp.com> <loom.20111115T142111-739@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pavel <free.lan.c2.718r@...> writes:

> 
> Bryan Schumaker <bjschuma@...> writes:
> 
> > 
> > On Mon 14 Nov 2011 02:10:05 PM EST, Bryan Schumaker wrote:
> > It might also be useful if you could share the /etc/exports file on the 
> > server.
> > 
> > Thanks!
> > 
> > - Bryan

The options I export shares with are: rw,no_root_squash,no_all_squash,sync;
wdelay and no_subtree_check are added as default.

The output of 'exportfs -v' (whether I export share using /etc/exports entry or 
exportfs resource agent) is the following:

/mnt/B/share 192.168.0.0/24(rw,wdelay,no_root_squash,no_subtree_check)




