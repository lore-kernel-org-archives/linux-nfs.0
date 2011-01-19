Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from esrismtp2.esri.com ([198.102.62.103]:35544 "EHLO esri3.esri.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751446Ab1ASArm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Jan 2011 19:47:42 -0500
Date: Tue, 18 Jan 2011 16:29:07 -0800
From: Ray Van Dolson <rvandolson@esri.com>
To: rhelv6-list@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: NFSv4 automount - nss_getpwnam name 'user@domain.com' does not map
 into domain 'localdomain'
Message-ID: <20110119002907.GA25400@esri.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Am doing a kickstart installation of RHEL 6.0 vanilla (no errata
applied).

After reboot, when using the automounter to access NFSv4 shares
(running on Fedora 13), we see the following in the logs on the RHEL6
client:

Jan 18 15:56:16 rhel6test rpc.idmapd[1387]: nss_getpwnam: name 'root@esri.com' does not map into domain 'localdomain'
Jan 18 15:56:16 rhel6test rpc.idmapd[1387]: nss_getpwnam: name 'ray5147@esri.com' does not map into domain 'localdomain'

As a result, directories are not mapped to the correct users but
instead to 'nobody'.

This is odd, because per the idmap man pages, the default domain used
by rpc.idmapd should be the same as the system domain minus the
hostname.  This should be esri.com, and is when I type hostname.

Thinking that perhaps rpc.idmapd was started before the network
subsystem, I restarted it.  Immediately everything worked fine.

I rebooted the system assuming the problem would return, but it didn't.
Maybe there's a cache used by rpc.idmapd (nscd?)?  Is there something
else maybe I'm missing?

Trying to determine if the "right" thing to do is to leave my
configuration as default or if I should be modifying /etc/idmapd.conf
to set a default domain.

Thanks,
Ray
