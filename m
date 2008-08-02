From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: (was: nfs-utils-1.1.3 released)
Date: Sat, 2 Aug 2008 13:25:29 -0400
Message-ID: <20080802172529.GC30454__8873.92292866043$1217698012$gmane$org@fieldses.org>
References: <488D718F.200@RedHat.com> <20080801131533.GN14057@debianrules.debiancolombia.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Steve Dickson <SteveD@redhat.com>,
	Christian Surchi <csurchi@debian.org>,
	Rasmus =?utf-8?Q?B=C3=B8g?= Hansen <rasmus-tUP8e6pgWdNlY7y4Fx5NiA@public.gmane.org>,
	492970@bugs.debian.org,
	Linux NFS Mailing List <li
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39451 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750759AbYHBRZj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 2 Aug 2008 13:25:39 -0400
In-Reply-To: <20080801131533.GN14057-ePWG1nzy00eujY+JMLXK6WCv5UukjcD9wsqeKsqY1Ps@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 01, 2008 at 11:15:33PM +1000, An=C3=ADbal Monsalve Salazar =
wrote:
> On Mon, Jul 28, 2008 at 03:13:19AM -0400, Steve Dickson wrote:
> >I just cut the 1.1.3 nfs-utils release. Unfortunately I'm having
> >issues accessing my kernel.org account so for the moment the=20
> >tar ball is only available on SourceForge:
> >
> >     http://sourceforge.net/projects/nfs
> >[...]=20
>=20
> 1.1.3 clients don't work with a 1.0.10 server anymore.

Very weird--it might make sense if upgrading nfs-utils broke the mount
itself, but here it seems the mount is succeeding and subsequent file
access (which I'd expect to only involve the in-kernel client code) is
failing.  Maybe there's some difference in the mount options?  What doe=
s
/proc/self/mounts say?  I assume these are all v2 or v3 mounts?

--b.

>=20
> Please read the Debian bug report at http://bugs.debian.org/492970
>=20
> On Fri, Aug 01, 2008 at 02:54:02PM +0200, Christian Surchi wrote:
> >On Wed, Jul 30, 2008 at 12:56:12PM +0200, Rasmus B=C3=B8g Hansen wro=
te:
> >>Package: nfs-common
> >>Version: 1:1.1.3-1
> >>Severity: important
> >>
> >>
> >>Upgrading nfs-common 1:1.1.3-1 broke my NFS client.
> >>
> >>The NFS server is running etch and nothing was changed. After upgra=
ding
> >>the client to 1:1.1.3-1 access to my files (/home is NFS-mounted) i=
s
> >>disallowed where it should be allowed (and certainly was in 1:1.1.2=
-6).
> >
> >I confirm this one on my sid client too. No changes in nfs server=20
> >(etch). Downgrading nfs-common solved the problem for me too.
> >
> >Christian



> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
