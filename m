From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC] server's statd and lockd will not sync after its nfslock
	restart
Date: Thu, 17 Dec 2009 15:14:31 -0500
Message-ID: <20091217201430.GA20185@fieldses.org>
References: <4B275EA3.9030603@cn.fujitsu.com> <F9F5EA38-B51C-44A4-9812-873EEE1891C9@oracle.com> <4B28B5FD.5000103@cn.fujitsu.com> <E6EC8330-4C4C-4917-AEE3-A2BEE35B9F8A@oracle.com> <4B2A02C6.6080501@cn.fujitsu.com> <35D45F43-D98F-460E-8060-F7C5F3ADFCFE@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Trond.Myklebust Myklebust" <trond.myklebust@fys.uio.no>,
	Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>,
	Mi Jinlong <mijinlong@cn.fujitsu.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45959 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935840AbZLQUOe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Dec 2009 15:14:34 -0500
In-Reply-To: <35D45F43-D98F-460E-8060-F7C5F3ADFCFE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 17, 2009 at 11:18:53AM -0500, Chuck Lever wrote:
> run_sm_notify() simply forks and execs the sm-notify program.  This =20
> program checks for the existence of a pid file.  If the pid file exis=
ts,=20
> then sm-notify exits.  If it does not, then sm-notify retires the rec=
ords=20
> in /var/lib/nfs/statd/sm and posts reboot notifications.
>
> Jeff Layton pointed out to me yesterday that Red Hat's nfslock script=
 =20
> unconditionally deletes sm-notify's pid file every time "service nfsl=
ock=20
> start" is done, which effectively defeats sm-notify's reboot detectio=
n.
>
> sm-notify was written by a developer at SuSE.  SuSE Linux uses a tmpf=
s =20
> for /var/run, but Red Hat uses permanent storage for this directory. =
 =20
> Thus on SuSE, the pid file gets deleted automatically by a reboot, bu=
t =20
> on Red Hat, the pid file must be deleted "by hand" or reboot =20
> notification never occurs.
>
> So the root cause of this problem is that the current mechanism sm-=20
> notify uses to detect a reboot is not portable across distributions.
>
> My new-statd prototype used a semaphor instead of a pid file to detec=
t =20
> reboots.  A semaphor is shared (visible to other processes) and will =
=20
> continue to exist until it is deleted or the system reboots.  It is a=
 =20
> resource that is not destroyed automatically when the sm-notify proce=
ss=20
> exits.  If creating the semaphor fails, sm-notify exits.  If creating=
 it=20
> succeeds, it runs.
>
> Would anyone strongly object to using a semaphor instead of a pid fil=
e =20
> here?  Is support for semaphors always built into kernels?  Would the=
re=20
> be any problems with the small size of the semaphor name space?  Is t=
here=20
> another similar facility that might be better?

I don't know much about those (except that I think there's an e at the
end); looks like sem_overview(7) is the place to start?

It says:

	" Prior to kernel 2.6, Linux only supported unnamed,
	thread-shared  sema=E2=80=90 phores.   On a system with Linux 2.6 and =
a
	glibc that provides the NPTL threading implementation, a
	complete implementation of POSIX semaphores is provided."

So would it mean dropping support for 2.4?

--b.
