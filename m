From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [RFC] After nfs restart, locks can't be recovered which record
 by lockd before
Date: Wed, 13 Jan 2010 07:51:55 -0500
Message-ID: <20100113075155.5c409567@barsoom.rdu.redhat.com>
References: <4B4D979D.6090307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38552 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753473Ab0AMMwO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jan 2010 07:52:14 -0500
In-Reply-To: <4B4D979D.6090307@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 13 Jan 2010 17:51:25 +0800
Mi Jinlong <mijinlong@cn.fujitsu.com> wrote:

> Hi,
>=20
> When testing the nfs's lock at NFSv3, I get a problem.
> So I want someone help me, thanks!
>=20
> Test Process:
>   Step1, ClientA get an exclusive lock success.
>   Step2, Using command "service nfs restart" to restart server's nfs =
service.

"service nfs restart" on an RH-derived distro is the same as running
"/etc/init.d/nfs restart". Init scripts vary between distros (and even
between releases on the same distro). Since you're asking this in a
more generic forum, you should probably be specific about what's
actually being restarted (and in what order). Understanding that may
also help you answer your own question here.

>   Step3. ClientB get lock should fail, but success.
>=20
> I think after step2 (nfs service restart), clientA's lock should be r=
ecovered.
> But like above, clientA's lock doesn=E2=80=99t be recovered.
>=20
> When tracing the kernel, I find nfsd will cause lockd stop when it st=
op.
> When lockd stop, all locks will be release which is record before at =
lockd.
>=20
> When nfsd start, the lockd will start also, but the statd don't know =
what happened
>  at kernel, so after that, locks will be lost.
>=20
> Is it right when nfs stop, the lockd will stop too?=20
> If it's right, should locks be recovered after lockd start?
>=20

Assuming you're using a RH-derived distro like Fedora or RHEL, then no.
statd is controlled by a separate init script (nfslock) and when you
run "service nfs restart" you're not restarting it. NSM notifications
are not sent and clients generally won't reclaim their locks.

IOW, "you're doing it wrong". If you want locks to be reclaimed then
you probably need to restart the nfslock service too.

--=20
Jeff Layton <jlayton@redhat.com>
