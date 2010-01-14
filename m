From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [RFC] After nfs restart, locks can't be recovered which record
 by lockd before
Date: Thu, 14 Jan 2010 18:06:42 +0800
Message-ID: <4B4EECB2.8050400@cn.fujitsu.com>
References: <4B4D979D.6090307@cn.fujitsu.com> <20100113075155.5c409567@barsoom.rdu.redhat.com> <4B4E16C3.4050206@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Layton <jlayton@redhat.com>,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59331 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750856Ab0ANKG7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 05:06:59 -0500
In-Reply-To: <4B4E16C3.4050206@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

Chuck Lever =E5=86=99=E9=81=93:
> On 01/13/2010 07:51 AM, Jeff Layton wrote:
>> On Wed, 13 Jan 2010 17:51:25 +0800
>> Mi Jinlong<mijinlong@cn.fujitsu.com>  wrote:
>>
>> Assuming you're using a RH-derived distro like Fedora or RHEL, then =
no.
>> statd is controlled by a separate init script (nfslock) and when you
>> run "service nfs restart" you're not restarting it. NSM notification=
s
>> are not sent and clients generally won't reclaim their locks.
>>
>> IOW, "you're doing it wrong". If you want locks to be reclaimed then
>> you probably need to restart the nfslock service too.
>=20
> Mi Jinlong is exercising another case we know doesn't work right, but=
 we
> don't expect admins will ever perform this kind of "down-up" on a nor=
mal
> production server.  In other words, we expect it to work this way, an=
d
> it's been good enough, so far.
>=20
> As Jeff points out, the "nfs" and the "nfslock" services are separate=
=2E
> This is because "nfslock" is required for both client and server side
> NFS, but "nfs" is required only on the server.  This split also dicta=
tes
> the way sm-notify works, since it has to behave differently on NFS
> clients and servers.
>=20
> Two other points:
>=20
>   + lockd would not restart itself in this case if there happened to =
be
> NFS mounts on that system

  When testing, i find nfs restart will cause lockd restart.
  I find some codes which cause the lock stop when nfs stop.

 At kernel 2.6.18, fs/lockd/svc.c
 ...
 354         if (nlmsvc_users) {
 355                 if (--nlmsvc_users)
 356                         goto out;
 357         } else
 358                 printk(KERN_WARNING "lockd_down: no users! pid=3D%=
d\n", nlmsvc_pid);
 ...
 366=20
 367         kill_proc(nlmsvc_pid, SIGKILL, 1);
 ...
=20
 At kernel 2.6.18, fs/lockd/svc.c
 ...
 344         if (nlmsvc_users) {
 345                 if (--nlmsvc_users)
 346                         goto out;
 347         } else {
 348                 printk(KERN_ERR "lockd_down: no users! task=3D%p\n=
",
 349                         nlmsvc_task);
 350                 BUG();
 351         }
 ....
 357         kthread_stop(nlmsvc_task);
 358         svc_exit_thread(nlmsvc_rqst);
 ...

 As above, when nlmsvc_users <=3D 1, the lockd will be killed.

>=20
>   + lockd doesn't currently poke statd when it restarts to tell it to
> send reboot notifications, but it probably should

  Yes, I agree with you. But now, when some reason cause lockd restart =
but
  statd not restart, locks which hold before will lost.

  Maybe, the kernel should fix this.

>=20
> We know that lockd will start up when someone mounts the first NFS
> share, or when the NFS server is started.  If lockd sent statd an
> SM_SIMU_CRASH (or something like it) every time it cold started, stat=
d
> could send reboot notifications at the right time on both servers and
> clients without extra logic in the init scripts, and we wouldn't need
> that kludge in sm-notify to know when a machine has rebooted.

  What's the meaning of cold start?? System reboot? Or statd reboot?

  I want to know when using cammond "service nfslock restart" restart t=
he=20
  nfslock service(means restart statd and lockd), will the statd call s=
m-notify=20
  to notify other client? Or don't?

  At RHEL5 and Fedora, the sm-notify will be call and send SM-NOTIFY ev=
ery time=20
  when nfslock restart.

thanks,
Mi Jinlong

