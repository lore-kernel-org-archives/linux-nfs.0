Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:41847 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752453AbbBSKPG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Feb 2015 05:15:06 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1YOO8N-0001t4-Jz
	for linux-nfs@vger.kernel.org; Thu, 19 Feb 2015 11:15:03 +0100
Received: from 78-83-22-128.spectrumnet.bg ([78-83-22-128.spectrumnet.bg])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 19 Feb 2015 11:15:03 +0100
Received: from az by 78-83-22-128.spectrumnet.bg with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 19 Feb 2015 11:15:03 +0100
To: linux-nfs@vger.kernel.org
From: svilen dobrev <az@svilendobrev.com>
Subject: Re: rpc-statd won't start for user NFS mounts
Date: Thu, 19 Feb 2015 10:09:08 +0000 (UTC)
Message-ID: <loom.20150219T110245-75@post.gmane.org>
References: <54D3704C.6010305@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tobias Powalowski <tobias.powalowski@...> writes:

> 
> Hi,
> https://bugs.archlinux.org/task/42491
> This one I can reproduce, doing NFS3 user,noauto setting in fstab makes
> it impossible to mount it as user.
> - The systemd service nfs-client.target is loaded.
> - rpcbind comes up by doing the mount
> - rpc-statd is not coming up because of authentification error.
> Failed to start rpc-statd.service: Interactive authentication required.
> What is the correct way to solve this?
> 
> Thanks for your answer.
> greetings
> tpowa
 
i stepped on this after upgrade today.. (and it's nfs4).
i get these in journalctl -xe:
.. rpc.statd[686]: Opening /var/run/rpc.statd.pid failed: Permission denied
then i tried $ sudo touch /var/run/rpc.statd.pid
and then mount suddenly works.

if that workaround gives any clue..


