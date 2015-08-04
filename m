Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18314 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756344AbbHDO2x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 10:28:53 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: Automatically loading svcrdma causes reboot hang on systemd
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CA+X5Wn5tYN1ScawJFQzt+SZz61S_PYEbCC=6cdbxr_M6GLzuPw@mail.gmail.com>
Date: Tue, 4 Aug 2015 10:28:44 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <93820DB5-C825-4A9E-BF67-4BB2AD0FA122@oracle.com>
References: <CA+X5Wn5tYN1ScawJFQzt+SZz61S_PYEbCC=6cdbxr_M6GLzuPw@mail.gmail.com>
To: james harvey <jamespharvey20@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 3, 2015, at 10:23 PM, james harvey <jamespharvey20@gmail.com> wrote:

> Fresh minimal Arch system, on kernel 4.1.3 (-1 Arch).  nfs-utils 1.3.2
> (-6 Arch).  Mellanox ConnectX MT25418 card, using latest firmware.
> systemd 223 (-1 Arch).
> 
> If I boot the system, log in, and manually "modprobe svcrdma" and
> "echo rdma 20049 > /proc/fs/nfsd/portlist", I can "systemctl reboot"
> or "systemctl shutdown" just fine.  Regardless of whether I do so as
> quickly as possible (kernel uptime 30-40sec) or wait several minutes.
> 
> If svcrdma is loaded and portlist is set through systemd with
> "Before=remote-fs-pre.target" and "After=nfs-server.target", I can
> reboot or shutdown just fine.  But, if I wait until the kernel has
> been up for about 60 seconds or more (I give it 2 min in testing to be
> sure), any reboot or shutdown hangs after everything is unmounted,
> services are stopped, and it's actually time to "hit" the power
> switch.  (Using sysrq-trigger does forces it to reboot.)
> 
> If I modify the systemd service, so it is after "network.target
> rdma.service auth-rpcgss-module.service nfs-blkmap.service
> nfs-config.service nfs-imapd.service nfs-mountd.service
> nfs-server.service nfs-server.target nfs-utils.service
> rpc-gssd.service rpc-statd-notify.service rpc-statd.service
> rpc-svcgssd.service", I can wait as long as I want, and
> reboot/shutdown works fine.
> 
> This is all without any NFS exports defined - so no NFS clients
> actually connected.
> 
> As crazy as this sounds (to me anyway), this shows that
> svcrdma/portlist will cause a reboot/shutdown lockup if it is loaded
> before or during when the RDMA or NFS kernel modules are being
> loaded... And works fine if it waits until they are all done.
> 
> I would expect modprobe or setting portlist would fail if it wasn't
> ready to be loaded, rather than come up, work, and later mysteriously
> hanging a reboot/shutdown.
> 
> I put about 20 hours into diagnosing this, and the results are 100%
> repeatable, even if the above conclusion sounds weird.
> 
> I haven't tried out if xprtrdma has the same effect.
> 
> If you also run arch, you can see/download the new AUR4 package that
> loads the kernel module and sets portlist at:
> https://aur4.archlinux.org/packages/nfs-utils-rdma-server/  and the
> client version at:
> https://aur4.archlinux.org/packages/nfs-utils-rdma-client/
> 
> If you "View Changes" on that page, you can see the previous version
> which causes the lockup.

I'm not an Arch user, so I don't entirely understand what is
going on (whether this is an issue unique to Arch, a problem
with the NFS systemd scripts, or a problem with resource
management in the kernel).

However, let's start with this:

http://marc.info/?l=linux-nfs&m=143647487532461&w=2

Can you apply this patch to your kernel, and see if it helps?


--
Chuck Lever



