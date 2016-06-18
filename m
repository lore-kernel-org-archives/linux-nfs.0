Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33632 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751228AbcFRN35 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 18 Jun 2016 09:29:57 -0400
Date: Sat, 18 Jun 2016 09:29:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Damjan Georgievski <gdamjan@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsd crash with 4.6 and 4.7 (bisected)
Message-ID: <20160618132955.GD9980@fieldses.org>
References: <CAEk1YH658ajK5Dz-T0=_EEP-zS5KUD+Awm0AsAQyjqMDjKLraw@mail.gmail.com>
 <20160617191220.GB899@fieldses.org>
 <CAEk1YH6crPwzVAOBv+swq2K9hNsH9W-RW-_kwyz=dMC+kWeEPQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAEk1YH6crPwzVAOBv+swq2K9hNsH9W-RW-_kwyz=dMC+kWeEPQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 18, 2016 at 12:04:32PM +0200, Damjan Georgievski wrote:
> >> I'm experiencing a kernel crash with the kernel nfs daemon in 4.6.1,
> >> 4.6.2 and 4.7.0-rc3-g5edb564
> >> 4.5.4 is ok.
> >>
> >> My server is ArchLinux, nothing special, nfs-server.service enabled,
> >> this in exports:
> >> /home/nfs/archlinux-rpi
> >> 192.168.15.0/24(rw,no_subtree_check,nohide,insecure,no_root_squash,async)
> >>
> >> The client is a raspberrypi with 4.4.13-2-ARCH kernel, a nfs root,
> >> ArchLinuxArm and this kernel cmdline:
> >> nfsroot=192.168.15.103:/home/nfs/archlinux-rpi,vers=4.2,proto=tcp,rsize=1048576,wsize=1048576
> >>
> >> the crash happens every time I *reboot* the raspberrypi. just booting
> >> it in the first place doesn't crash the server.
> >> please cc me for other info, since I'm not subscribed.
> >
> > Could you check latest upstream?  I think there's a good chance this is
> > fixed by 39a9beab5acb "rpc: share one xps between all backchannels".
> 
> thanks Bruce,
> 4.7.0-rc3-gbb96727 seems to work fine.
> 
> I hope this gets submitted to stable too?

Yes, the "Cc: stable@vger.kernel.org" should make that happen, though it
may take some time for them to get to it.

--b.
