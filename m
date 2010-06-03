From: Guillem Jover <guillem@debian.org>
Subject: Re: Bug#583435: rpcbind: Insecure handling of state files
Date: Thu, 3 Jun 2010 23:07:07 +0200
Message-ID: <20100603210707.GA7377@gaara.hadrons.org>
References: <20100527170908.GA14298@gaara.hadrons.org>
 <20100601120907.GA23357@gaara.hadrons.org>
 <20100602112520.GA22639@master.debian.org>
 <4C080B96.1030707@oracle.com>
 <20100603202743.GA6643@gaara.hadrons.org>
 <4C0811B9.3060809@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org, 583435@bugs.debian.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp13.ono.com ([62.42.230.16]:55854 "EHLO resmaa13.ono.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752929Ab0FCVHT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jun 2010 17:07:19 -0400
In-Reply-To: <4C0811B9.3060809@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-06-03 at 16:34:01 -0400, Chuck Lever wrote:
> On 06/ 3/10 04:27 PM, Guillem Jover wrote:
> >The second problem is that those files get created by the daemon on
> >shutdown, and they *do* follow symlinks. So a user can drop two
> >symlinks
> >there while the daemon is running and overwrite any file on the file
> >system on shutdown.
> >
> >The fix would consist of passing to configure something like
> >=E2=80=9C--with-statedir=3D/var/cache/rpcbind=E2=80=9D, and make sur=
e the daemon creates
> >such directory if missing on exit in src/warmstart.c:write_struct(),
> >which it does not seem to be doing currently.
> >
> >In addition it would be wise to notify upstream to change the defaul=
t
> >statedir to something else than /tmp.
>=20
> Agree changing the upstream default is a good idea.
>=20
> Generally, that kind of directory is created as part of installation
> (like, by rpm --install) rather than by the daemon itself.

At least for /var/run I think it's common for systems to mount it
as tmpfs, so the directories might not be there on boot. But those can
always be created by the init script (or equivalent), it might be a
problem if run from inetd though.

> >>Would /var/run (or a subdirectory of it) be a better choice than /t=
mp ?
> >
> >/var/run might not be preserved across reboots, but regardless of th=
at I
> >think /var/cache is a better fit, it's internal state, but it's used
> >to speed up start up time, and can be removed w/o ill effects.
>=20
> No, it's not intended to speed start up.
>=20
> The cache files aren't really supposed to be retained over a reboot.
> After a system restart, all of the RPC services will restart and
> register themselves again.  If just rpcbind restarts, all that
> registration state is lost, so that's the point of saving it in a
> file.

Ah, yeah that makes more sense! More so given the configure option, I
should have written "AFAIS" or something like that. :)

> I don't have a preference wrt /var/run or /var/cache.

So given that this is actually run time state, /var/run seems more
appropriate, indeed.

regards,
guillem
