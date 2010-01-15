From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [RFC] After nfs restart, locks can't be recovered which record
 by lockd before
Date: Fri, 15 Jan 2010 17:35:55 +0800
Message-ID: <4B5036FB.8020905@cn.fujitsu.com>
References: <4B4D979D.6090307@cn.fujitsu.com> <20100113075155.5c409567@barsoom.rdu.redhat.com> <4B4E16C3.4050206@oracle.com> <4B4EECB2.8050400@cn.fujitsu.com> <10874277-0968-420D-82DD-D61AB672C9C0@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Layton <jlayton@redhat.com>,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63035 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756998Ab0AOJfz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jan 2010 04:35:55 -0500
In-Reply-To: <10874277-0968-420D-82DD-D61AB672C9C0@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

Chuck Lever =E5=86=99=E9=81=93:
> On Jan 14, 2010, at 5:06 AM, Mi Jinlong wrote:
>> Hi Chuck,
>>
>> Chuck Lever =E5=86=99=E9=81=93:
>>> On 01/13/2010 07:51 AM, Jeff Layton wrote:
>>>> On Wed, 13 Jan 2010 17:51:25 +0800
>>>> Mi Jinlong<mijinlong@cn.fujitsu.com>  wrote:
>>>>
>>>> Assuming you're using a RH-derived distro like Fedora or RHEL, the=
n no.
>>>> statd is controlled by a separate init script (nfslock) and when y=
ou
>>>> run "service nfs restart" you're not restarting it. NSM notificati=
ons
>>>> are not sent and clients generally won't reclaim their locks.
>>>>
>>>> IOW, "you're doing it wrong". If you want locks to be reclaimed th=
en
>>>> you probably need to restart the nfslock service too.
>>>
>>> Mi Jinlong is exercising another case we know doesn't work right, b=
ut we
>>> don't expect admins will ever perform this kind of "down-up" on a n=
ormal
>>> production server.  In other words, we expect it to work this way, =
and
>>> it's been good enough, so far.
>>>
>>> As Jeff points out, the "nfs" and the "nfslock" services are separa=
te.
>>> This is because "nfslock" is required for both client and server si=
de
>>> NFS, but "nfs" is required only on the server.  This split also dic=
tates
>>> the way sm-notify works, since it has to behave differently on NFS
>>> clients and servers.
>>> Two other points:
>>>
>>>  + lockd would not restart itself in this case if there happened to=
 be
>>> NFS mounts on that system
>>
>>  When testing, i find nfs restart will cause lockd restart.
>>  I find some codes which cause the lock stop when nfs stop.
>>
>> At kernel 2.6.18, fs/lockd/svc.c
>> ...
>> 354         if (nlmsvc_users) {
>> 355                 if (--nlmsvc_users)
>> 356                         goto out;
>> 357         } else
>> 358                 printk(KERN_WARNING "lockd_down: no users!
>> pid=3D%d\n", nlmsvc_pid);
>> ...
>> 366
>> 367         kill_proc(nlmsvc_pid, SIGKILL, 1);
>> ...
>>
>> At kernel 2.6.18, fs/lockd/svc.c
>> ...
>> 344         if (nlmsvc_users) {
>> 345                 if (--nlmsvc_users)
>> 346                         goto out;
>> 347         } else {
>> 348                 printk(KERN_ERR "lockd_down: no users! task=3D%p=
\n",
>> 349                         nlmsvc_task);
>> 350                 BUG();
>> 351         }
>> ....
>> 357         kthread_stop(nlmsvc_task);
>> 358         svc_exit_thread(nlmsvc_rqst);
>> ...
>>
>> As above, when nlmsvc_users <=3D 1, the lockd will be killed.
>>
>>>
>>>  + lockd doesn't currently poke statd when it restarts to tell it t=
o
>>> send reboot notifications, but it probably should
>>
>>  Yes, I agree with you. But now, when some reason cause lockd restar=
t but
>>  statd not restart, locks which hold before will lost.
>>
>>  Maybe, the kernel should fix this.
>=20
> What did you have in mind?

  I think when lockd restart, statd should restart too and sent sm-noti=
fy to other client.
  But now, in kernel and nfs-uitls, it don't implemented.
  As the communication style between lockd and statd, this is indeed no=
t easy to implement it.

  So, I think it's should more easy to implement it through the mechani=
sm that exposes
  the kernel's nlm_host cache via /sys you show me before.

>=20
>>> We know that lockd will start up when someone mounts the first NFS
>>> share, or when the NFS server is started.  If lockd sent statd an
>>> SM_SIMU_CRASH (or something like it) every time it cold started, st=
atd
>>> could send reboot notifications at the right time on both servers a=
nd
>>> clients without extra logic in the init scripts, and we wouldn't ne=
ed
>>> that kludge in sm-notify to know when a machine has rebooted.
>>
>>  What's the meaning of cold start?? System reboot? Or statd reboot?
>=20
> cold start meaning that lockd is shutdown and rmmod'd, then started u=
p
> and re-loaded.
>=20
> This can also happen on a client if all NFS mounts go away.  lockd_do=
wn
> is invoked, and lockd.ko is removed.  On the next NFS mount, lockd is
> loaded again.

  Thanks.

>=20
>>  I want to know when using cammond "service nfslock restart" restart=
 the
>>  nfslock service(means restart statd and lockd), will the statd call
>> sm-notify
>>  to notify other client? Or don't?
>=20
> Currently "service nfslock restart" always causes a notification to b=
e
> sent.  Since "service nfslock restart" causes lockd to drop its locks=
 (I
> assume that's what that "killproc lockd" does) I guess we need to for=
ce
> reboot notifications here.  (I still argue that removing the pidfile =
in
> the "start" case is not correct).
>=20
> It appears that both the nfs and nfslock start up scripts do somethin=
g
> to lockd (as well as the case when the number of NFS mounts goes to
> zero).  However, only the nfslock script forces sm-notify to send
> notifications.

  But, at RHLE5 and Fedora, when using cammond "service nfslock restart=
" restart
  the nfslock service, the lockd isn't shutdown and rmmod'd.

  Is it a bug?

>=20
> I suppose a naive fix for your server restart issue might be to add a=
n
> "sm-notify -f" to the "restart" case in /etc/init.d/nfs.  This would
> cause reboot notifications to be sent if the monitor list was not emp=
ty
> during a server restart.

  Hehe. ^/^

thinks,
Mi Jinlong

