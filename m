From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [RFC] After nfs restart, locks can't be recovered which record
 by lockd before
Date: Thu, 14 Jan 2010 17:41:13 +0800
Message-ID: <4B4EE6B9.8090104@cn.fujitsu.com>
References: <4B4D979D.6090307@cn.fujitsu.com> <20100113075155.5c409567@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61330 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751313Ab0ANJlV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 04:41:21 -0500
In-Reply-To: <20100113075155.5c409567-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,

Jeff Layton =E5=86=99=E9=81=93:
> On Wed, 13 Jan 2010 17:51:25 +0800
> Mi Jinlong <mijinlong@cn.fujitsu.com> wrote:
>=20
>> Hi,
>>
>> When testing the nfs's lock at NFSv3, I get a problem.
>> So I want someone help me, thanks!
>>
>> Test Process:
>>   Step1, ClientA get an exclusive lock success.
>>   Step2, Using command "service nfs restart" to restart server's nfs=
 service.
>=20
> "service nfs restart" on an RH-derived distro is the same as running
> "/etc/init.d/nfs restart". Init scripts vary between distros (and eve=
n
> between releases on the same distro). Since you're asking this in a
> more generic forum, you should probably be specific about what's
> actually being restarted (and in what order). Understanding that may
> also help you answer your own question here.

  I test it on RHEL5(kernel 2.6.18, nfs-utils 1.0.9) and Fedora 12(kern=
el 2.6.33-rc3,
   nfs-utils 1.2.0).

>=20
>>   Step3. ClientB get lock should fail, but success.
>>
>> I think after step2 (nfs service restart), clientA's lock should be =
recovered.
>> But like above, clientA's lock doesn=E2=80=99t be recovered.
>>
>> When tracing the kernel, I find nfsd will cause lockd stop when it s=
top.
>> When lockd stop, all locks will be release which is record before at=
 lockd.
>>
>> When nfsd start, the lockd will start also, but the statd don't know=
 what happened
>>  at kernel, so after that, locks will be lost.
>>
>> Is it right when nfs stop, the lockd will stop too?=20
>> If it's right, should locks be recovered after lockd start?
>>
>=20
> Assuming you're using a RH-derived distro like Fedora or RHEL, then n=
o.
> statd is controlled by a separate init script (nfslock) and when you
> run "service nfs restart" you're not restarting it. NSM notifications
> are not sent and clients generally won't reclaim their locks.

  Yes, the statd don't restart when nfs restart. But, nfs restart will
  cause lockd restart. If lockd restart, locks which record before will=
 be lost.

> IOW, "you're doing it wrong". If you want locks to be reclaimed then
> you probably need to restart the nfslock service too.
>=20

  Don't you think it's more reasonable that locks should be recovered=20
  when nfs restart cause lockd restart?

--=20
Regards
Mi Jinlong

