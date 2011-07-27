Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43905 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754460Ab1G0Rpm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jul 2011 13:45:42 -0400
Date: Wed, 27 Jul 2011 13:45:37 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Justin Piszcz <jpiszcz@lucidpixels.com>
Cc: Ruediger Meier <sweet_f_a@gmx.de>, Bryan Schumaker <bjschuma@netapp.com>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        xfs@oss.sgi.com
Subject: Re: 2.6.xx: NFS: directory motion/cam2 contains a readdir loop
Message-ID: <20110727174537.GA9667@fieldses.org>
References: <alpine.DEB.2.02.1107270952270.1451@p34.internal.lan>
 <alpine.DEB.2.02.1107271227340.1451@p34.internal.lan>
 <4E303F6F.8010706@netapp.com>
 <201107271900.11091.sweet_f_a@gmx.de>
 <alpine.DEB.2.02.1107271316140.1451@p34.internal.lan>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.DEB.2.02.1107271316140.1451@p34.internal.lan>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jul 27, 2011 at 01:17:35PM -0400, Justin Piszcz wrote:
> 
> 
> On Wed, 27 Jul 2011, Ruediger Meier wrote:
> 
> >On Wednesday 27 July 2011, Bryan Schumaker wrote:
> >>On 07/27/2011 12:28 PM, Justin Piszcz wrote:
> >>>On Wed, 27 Jul 2011, J. Bruce Fields wrote:
> >>>>
> >>>>What filesystem on the server are you exporting?
> >>>
> >>>xfs.
> >>>/dev/sda1 on / type xfs (rw,noatime)
> >>>
> >>>Nothing special, thoughts?
> >>
> >>Are there a lot of files in the directory you're exporting?  It looks
> >>like cookie 10272 is mapped to multiple files.
> >
> >I thought xfs is immune to readdir loops!?
> >Is your export directory really located directly within / on /dev/sda1?
> 
> Hi,
> 
> I was sharing out a directory on the NFS server:
> /d1         192.168.0.0/24(async,rw,no_root_squash,no_subtree_check,fsid=1)
> 
> Should I share out / instead?

You can do that if you want, but note that anyone malicious on that
network can get access to / by guessing filehandles.  (Safer would be to
mount a separate partition at /d1.)

But in any case that's got nothing to do with readdir cookie problems.

--b.

> Is this a known problem?
> 
> $ df -h
> Filesystem            Size  Used Avail Use% Mounted on
> /dev/sda1              30G   13G   18G  43% /
> tmpfs                 2.0G  8.0K  2.0G   1% /lib/init/rw
> udev                   10M  192K  9.9M   2% /dev
> tmpfs                 2.0G     0  2.0G   0% /dev/shm
> $
> 
> Justin.
> 
> 
