From: Neil Brown <neilb@suse.de>
Subject: Re: (was: nfs-utils-1.1.3 released)
Date: Sun, 3 Aug 2008 21:43:27 +1000
Message-ID: <18581.39391.324920.100038@notabene.brown>
References: <488D718F.200@RedHat.com>
	<20080801131533.GN14057@debianrules.debiancolombia.org>
	<20080802172529.GC30454@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Steve Dickson <SteveD@redhat.com>,
	Christian Surchi <csurchi@debian.org>,
	Rasmus =?utf-8?Q?B=C3=B8g?= Hansen <rasmus-tUP8e6pgWdNlY7y4Fx5NiA@public.gmane.org>,
	492970@bugs.debian.org,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52667 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753772AbYHCLnj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2008 07:43:39 -0400
In-Reply-To: message from J. Bruce Fields on Saturday August 2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Saturday August 2, bfields@fieldses.org wrote:
> On Fri, Aug 01, 2008 at 11:15:33PM +1000, An=EDbal Monsalve Salazar w=
rote:
> > On Mon, Jul 28, 2008 at 03:13:19AM -0400, Steve Dickson wrote:
> > >I just cut the 1.1.3 nfs-utils release. Unfortunately I'm having
> > >issues accessing my kernel.org account so for the moment the=20
> > >tar ball is only available on SourceForge:
> > >
> > >     http://sourceforge.net/projects/nfs
> > >[...]=20
> >=20
> > 1.1.3 clients don't work with a 1.0.10 server anymore.
>=20
> Very weird--it might make sense if upgrading nfs-utils broke the moun=
t
> itself, but here it seems the mount is succeeding and subsequent file
> access (which I'd expect to only involve the in-kernel client code) i=
s
> failing.  Maybe there's some difference in the mount options?  What d=
oes
> /proc/self/mounts say?  I assume these are all v2 or v3 mounts?

I'm guessing v4 and that idmapd is causing problems.  I cannot see any
other possible cause (not that this one seems likely).

If we can get a "tcpdump -s0 -port 2049" of the traffic it might help.

NeilBrown
