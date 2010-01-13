From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC] After nfs restart, locks can't be recovered which record
 by lockd before
Date: Wed, 13 Jan 2010 13:53:55 -0500
Message-ID: <4B4E16C3.4050206@oracle.com>
References: <4B4D979D.6090307@cn.fujitsu.com> <20100113075155.5c409567@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Cc: Mi Jinlong <mijinlong@cn.fujitsu.com>,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:64203 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752885Ab0AMSyg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jan 2010 13:54:36 -0500
In-Reply-To: <20100113075155.5c409567-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/13/2010 07:51 AM, Jeff Layton wrote:
> On Wed, 13 Jan 2010 17:51:25 +0800
> Mi Jinlong<mijinlong@cn.fujitsu.com>  wrote:
>
>> Hi,
>>
>> When testing the nfs's lock at NFSv3, I get a problem.
>> So I want someone help me, thanks!
>>
>> Test Process:
>>    Step1, ClientA get an exclusive lock success.
>>    Step2, Using command "service nfs restart" to restart server's nf=
s service.
>
> "service nfs restart" on an RH-derived distro is the same as running
> "/etc/init.d/nfs restart". Init scripts vary between distros (and eve=
n
> between releases on the same distro). Since you're asking this in a
> more generic forum, you should probably be specific about what's
> actually being restarted (and in what order). Understanding that may
> also help you answer your own question here.
>
>>    Step3. ClientB get lock should fail, but success.
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
>>   at kernel, so after that, locks will be lost.
>>
>> Is it right when nfs stop, the lockd will stop too?
>> If it's right, should locks be recovered after lockd start?
>>
>
> Assuming you're using a RH-derived distro like Fedora or RHEL, then n=
o.
> statd is controlled by a separate init script (nfslock) and when you
> run "service nfs restart" you're not restarting it. NSM notifications
> are not sent and clients generally won't reclaim their locks.
>
> IOW, "you're doing it wrong". If you want locks to be reclaimed then
> you probably need to restart the nfslock service too.

Mi Jinlong is exercising another case we know doesn't work right, but w=
e=20
don't expect admins will ever perform this kind of "down-up" on a norma=
l=20
production server.  In other words, we expect it to work this way, and=20
it's been good enough, so far.

As Jeff points out, the "nfs" and the "nfslock" services are separate.=20
This is because "nfslock" is required for both client and server side=20
NFS, but "nfs" is required only on the server.  This split also dictate=
s=20
the way sm-notify works, since it has to behave differently on NFS=20
clients and servers.

Two other points:

   + lockd would not restart itself in this case if there happened to b=
e=20
NFS mounts on that system

   + lockd doesn't currently poke statd when it restarts to tell it to=20
send reboot notifications, but it probably should

We know that lockd will start up when someone mounts the first NFS=20
share, or when the NFS server is started.  If lockd sent statd an=20
SM_SIMU_CRASH (or something like it) every time it cold started, statd=20
could send reboot notifications at the right time on both servers and=20
clients without extra logic in the init scripts, and we wouldn't need=20
that kludge in sm-notify to know when a machine has rebooted.

--=20
chuck[dot]lever[at]oracle[dot]com
