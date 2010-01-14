From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC] After nfs restart, locks can't be recovered which record by lockd before
Date: Thu, 14 Jan 2010 11:13:26 -0500
Message-ID: <10874277-0968-420D-82DD-D61AB672C9C0@oracle.com>
References: <4B4D979D.6090307@cn.fujitsu.com> <20100113075155.5c409567@barsoom.rdu.redhat.com> <4B4E16C3.4050206@oracle.com> <4B4EECB2.8050400@cn.fujitsu.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=UTF-8;
	format=flowed	delsp=yes
Cc: Jeff Layton <jlayton@redhat.com>,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:52657 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754797Ab0ANQOp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 11:14:45 -0500
In-Reply-To: <4B4EECB2.8050400@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 14, 2010, at 5:06 AM, Mi Jinlong wrote:
> Hi Chuck,
>
> Chuck Lever =E5=86=99=E9=81=93:
>> On 01/13/2010 07:51 AM, Jeff Layton wrote:
>>> On Wed, 13 Jan 2010 17:51:25 +0800
>>> Mi Jinlong<mijinlong@cn.fujitsu.com>  wrote:
>>>
>>> Assuming you're using a RH-derived distro like Fedora or RHEL, =20
>>> then no.
>>> statd is controlled by a separate init script (nfslock) and when yo=
u
>>> run "service nfs restart" you're not restarting it. NSM =20
>>> notifications
>>> are not sent and clients generally won't reclaim their locks.
>>>
>>> IOW, "you're doing it wrong". If you want locks to be reclaimed the=
n
>>> you probably need to restart the nfslock service too.
>>
>> Mi Jinlong is exercising another case we know doesn't work right, =20
>> but we
>> don't expect admins will ever perform this kind of "down-up" on a =20
>> normal
>> production server.  In other words, we expect it to work this way, =20
>> and
>> it's been good enough, so far.
>>
>> As Jeff points out, the "nfs" and the "nfslock" services are =20
>> separate.
>> This is because "nfslock" is required for both client and server sid=
e
>> NFS, but "nfs" is required only on the server.  This split also =20
>> dictates
>> the way sm-notify works, since it has to behave differently on NFS
>> clients and servers.
>> Two other points:
>>
>>  + lockd would not restart itself in this case if there happened to =
=20
>> be
>> NFS mounts on that system
>
>  When testing, i find nfs restart will cause lockd restart.
>  I find some codes which cause the lock stop when nfs stop.
>
> At kernel 2.6.18, fs/lockd/svc.c
> ...
> 354         if (nlmsvc_users) {
> 355                 if (--nlmsvc_users)
> 356                         goto out;
> 357         } else
> 358                 printk(KERN_WARNING "lockd_down: no users! pid=3D=
%d=20
> \n", nlmsvc_pid);
> ...
> 366
> 367         kill_proc(nlmsvc_pid, SIGKILL, 1);
> ...
>
> At kernel 2.6.18, fs/lockd/svc.c
> ...
> 344         if (nlmsvc_users) {
> 345                 if (--nlmsvc_users)
> 346                         goto out;
> 347         } else {
> 348                 printk(KERN_ERR "lockd_down: no users! task=3D%p\=
n",
> 349                         nlmsvc_task);
> 350                 BUG();
> 351         }
> ....
> 357         kthread_stop(nlmsvc_task);
> 358         svc_exit_thread(nlmsvc_rqst);
> ...
>
> As above, when nlmsvc_users <=3D 1, the lockd will be killed.
>
>>
>>  + lockd doesn't currently poke statd when it restarts to tell it to
>> send reboot notifications, but it probably should
>
>  Yes, I agree with you. But now, when some reason cause lockd =20
> restart but
>  statd not restart, locks which hold before will lost.
>
>  Maybe, the kernel should fix this.

What did you have in mind?

>> We know that lockd will start up when someone mounts the first NFS
>> share, or when the NFS server is started.  If lockd sent statd an
>> SM_SIMU_CRASH (or something like it) every time it cold started, =20
>> statd
>> could send reboot notifications at the right time on both servers an=
d
>> clients without extra logic in the init scripts, and we wouldn't nee=
d
>> that kludge in sm-notify to know when a machine has rebooted.
>
>  What's the meaning of cold start?? System reboot? Or statd reboot?

cold start meaning that lockd is shutdown and rmmod'd, then started up =
=20
and re-loaded.

This can also happen on a client if all NFS mounts go away.  =20
lockd_down is invoked, and lockd.ko is removed.  On the next NFS =20
mount, lockd is loaded again.

>  I want to know when using cammond "service nfslock restart" restart =
=20
> the
>  nfslock service(means restart statd and lockd), will the statd call =
=20
> sm-notify
>  to notify other client? Or don't?

Currently "service nfslock restart" always causes a notification to be =
=20
sent.  Since "service nfslock restart" causes lockd to drop its locks =20
(I assume that's what that "killproc lockd" does) I guess we need to =20
force reboot notifications here.  (I still argue that removing the =20
pidfile in the "start" case is not correct).

It appears that both the nfs and nfslock start up scripts do something =
=20
to lockd (as well as the case when the number of NFS mounts goes to =20
zero).  However, only the nfslock script forces sm-notify to send =20
notifications.

I suppose a naive fix for your server restart issue might be to add an =
=20
"sm-notify -f" to the "restart" case in /etc/init.d/nfs.  This would =20
cause reboot notifications to be sent if the monitor list was not =20
empty during a server restart.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



