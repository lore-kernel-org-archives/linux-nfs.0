From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: (was: nfs-utils-1.1.3 released)
Date: Sun, 3 Aug 2008 11:10:22 -0400
Message-ID: <20080803151022.GA31484@fieldses.org>
References: <488D718F.200@RedHat.com> <20080801131533.GN14057@debianrules.debiancolombia.org> <20080802172529.GC30454@fieldses.org> <87myjul1fk.fsf@burly.wgtn.ondioline.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Steve Dickson <SteveD@redhat.com>,
	Christian Surchi <csurchi@debian.org>,
	Rasmus =?utf-8?Q?B=C3=B8g?= Hansen <rasmus-tUP8e6pgWdNlY7y4Fx5NiA@public.gmane.org>,
	492970@bugs.debian.org,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Paul Collins <paul-dsjeNyW6Qm/D+ROgJ3VA+kB+6BGkLq7r@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45303 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755711AbYHCPKf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 3 Aug 2008 11:10:35 -0400
In-Reply-To: <87myjul1fk.fsf-D7l3p2TGOOdLdt5/z87VRY6ehsQQaF5K@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 04, 2008 at 12:37:19AM +1200, Paul Collins wrote:
> "J. Bruce Fields" <bfields@fieldses.org> writes:
>=20
> > On Fri, Aug 01, 2008 at 11:15:33PM +1000, An=C3=ADbal Monsalve Sala=
zar wrote:
> >> On Mon, Jul 28, 2008 at 03:13:19AM -0400, Steve Dickson wrote:
> >> >I just cut the 1.1.3 nfs-utils release. Unfortunately I'm having
> >> >issues accessing my kernel.org account so for the moment the=20
> >> >tar ball is only available on SourceForge:
> >> >
> >> >     http://sourceforge.net/projects/nfs
> >> >[...]=20
> >>=20
> >> 1.1.3 clients don't work with a 1.0.10 server anymore.
> >
> > Very weird--it might make sense if upgrading nfs-utils broke the mo=
unt
> > itself, but here it seems the mount is succeeding and subsequent fi=
le
> > access (which I'd expect to only involve the in-kernel client code)=
 is
> > failing.  Maybe there's some difference in the mount options?  What=
 does
> > /proc/self/mounts say?  I assume these are all v2 or v3 mounts?
>=20
> I discovered today that I was no longer able to write to the v3 mount=
 on
> my 1.1.2 server.  I checked /proc/mounts and noticed sec=3Dnull on th=
e
> mount.  Either adding sec=3Dsys to the client's mount options or
> downgrading to nfs-common 1.1.2 on the client fixes the problem.

That would do it!

So it sounds like there's a bug that causes mount.nfs to get the defaul=
t
mount options wrong?

--b.
