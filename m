From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: Do not display the setting of the "intr" mount
 option
Date: Mon, 04 May 2009 12:49:03 -0400
Message-ID: <1241455743.5754.10.camel@heimdal.trondhjem.org>
References: <20090501163402.25637.67939.stgit@ingres.1015granger.net>
	 <alpine.LFD.2.00.0905021010320.19638@maggie.lkpg.cendio.se>
	 <382F5CF6-4D1A-4B1E-8E17-B6426CFC3A03@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Peter =?ISO-8859-1?Q?=C5strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:55980 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757806AbZEDQtI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 May 2009 12:49:08 -0400
In-Reply-To: <382F5CF6-4D1A-4B1E-8E17-B6426CFC3A03@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-05-04 at 10:27 -0400, Chuck Lever wrote:
> On May 2, 2009, at 4:12 AM, Peter =C3=85strand wrote:
> > On Fri, 1 May 2009, Chuck Lever wrote:
> >
> >> The "intr" mount option has been deprecated for a while, but
> >> /proc/mounts continues to display "nointr" whether "intr" or "noin=
tr"
> >> has been specified for a mount point.
> >>
> >> Since these options do not have any effect, simply do not display
> >> them.
> >
> > Does this mean that "intr" is default now? Will the "intr" mount =20
> > option
> > still be accepted/ignored in the future?
>=20
> Since 2.6.25, the behavior of the NFS client has been a mix of the =20
> two.  I believe the current behavior is that SIGKILL can terminate an=
 =20
> NFS operation, but all other signals are deferred until pending NFS =20
> operations complete.
>=20
> The mount command continues to accept both options, but neither have =
=20
> any effect on the client's behavior (both options are no-ops).

Note that this behaviour is true of local filesystems too, since
generic_file_read() has been changed to call lock_page_killable()
instead of the uninterruptible lock_page().

Trond

