From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC] After nfs restart, locks can't be recovered which record by lockd before
Date: Fri, 15 Jan 2010 11:12:14 -0500
Message-ID: <2479069D-FCE0-42B5-9531-A3B7BA231E2F@oracle.com>
References: <4B4D979D.6090307@cn.fujitsu.com> <20100113075155.5c409567@barsoom.rdu.redhat.com> <4B4E16C3.4050206@oracle.com> <4B4EECB2.8050400@cn.fujitsu.com> <10874277-0968-420D-82DD-D61AB672C9C0@oracle.com> <4B5036FB.8020905@cn.fujitsu.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=UTF-8;
	format=flowed	delsp=yes
Cc: Jeff Layton <jlayton@redhat.com>,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:24521 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159Ab0AOQNx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jan 2010 11:13:53 -0500
In-Reply-To: <4B5036FB.8020905@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 15, 2010, at 4:35 AM, Mi Jinlong wrote:
> Hi Chuck,
>
> Chuck Lever =E5=86=99=E9=81=93:
>> On Jan 14, 2010, at 5:06 AM, Mi Jinlong wrote:
>>> Hi Chuck,
>>>
>>> Chuck Lever =E5=86=99=E9=81=93:
>>>> On 01/13/2010 07:51 AM, Jeff Layton wrote:
>>>>> On Wed, 13 Jan 2010 17:51:25 +0800
>>>>> Mi Jinlong<mijinlong@cn.fujitsu.com>  wrote:
>>>>>
>>>>> Assuming you're using a RH-derived distro like Fedora or RHEL, =20
>>>>> then no.
>>>>> statd is controlled by a separate init script (nfslock) and when =
=20
>>>>> you
>>>>> run "service nfs restart" you're not restarting it. NSM =20
>>>>> notifications
>>>>> are not sent and clients generally won't reclaim their locks.
>>>>>
>>>>> IOW, "you're doing it wrong". If you want locks to be reclaimed =20
>>>>> then
>>>>> you probably need to restart the nfslock service too.
>>>>
>>>> Mi Jinlong is exercising another case we know doesn't work right, =
=20
>>>> but we
>>>> don't expect admins will ever perform this kind of "down-up" on a =
=20
>>>> normal
>>>> production server.  In other words, we expect it to work this =20
>>>> way, and
>>>> it's been good enough, so far.
>>>>
>>>> As Jeff points out, the "nfs" and the "nfslock" services are =20
>>>> separate.
>>>> This is because "nfslock" is required for both client and server =20
>>>> side
>>>> NFS, but "nfs" is required only on the server.  This split also =20
>>>> dictates
>>>> the way sm-notify works, since it has to behave differently on NFS
>>>> clients and servers.
>>>> Two other points:
>>>>
>>>> + lockd would not restart itself in this case if there happened =20
>>>> to be
>>>> NFS mounts on that system
>>>
>>> When testing, i find nfs restart will cause lockd restart.
>>> I find some codes which cause the lock stop when nfs stop.
>>>
>>> At kernel 2.6.18, fs/lockd/svc.c
>>> ...
>>> 354         if (nlmsvc_users) {
>>> 355                 if (--nlmsvc_users)
>>> 356                         goto out;
>>> 357         } else
>>> 358                 printk(KERN_WARNING "lockd_down: no users!
>>> pid=3D%d\n", nlmsvc_pid);
>>> ...
>>> 366
>>> 367         kill_proc(nlmsvc_pid, SIGKILL, 1);
>>> ...
>>>
>>> At kernel 2.6.18, fs/lockd/svc.c
>>> ...
>>> 344         if (nlmsvc_users) {
>>> 345                 if (--nlmsvc_users)
>>> 346                         goto out;
>>> 347         } else {
>>> 348                 printk(KERN_ERR "lockd_down: no users! task=3D%=
p=20
>>> \n",
>>> 349                         nlmsvc_task);
>>> 350                 BUG();
>>> 351         }
>>> ....
>>> 357         kthread_stop(nlmsvc_task);
>>> 358         svc_exit_thread(nlmsvc_rqst);
>>> ...
>>>
>>> As above, when nlmsvc_users <=3D 1, the lockd will be killed.
>>>
>>>>
>>>> + lockd doesn't currently poke statd when it restarts to tell it t=
o
>>>> send reboot notifications, but it probably should
>>>
>>> Yes, I agree with you. But now, when some reason cause lockd =20
>>> restart but
>>> statd not restart, locks which hold before will lost.
>>>
>>> Maybe, the kernel should fix this.
>>
>> What did you have in mind?
>
>  I think when lockd restart, statd should restart too and sent sm-=20
> notify to other client.

Sending notifications is likely the correct thing to do if lockd is =20
restarted while there are active locks.  A statd restart isn't =20
necessarily required to send reboot notifications, however.  You can =20
do it with "sm-notify -f".

The problem with "sm-notify -f" is that it deletes the on-disk monitor =
=20
list while statd is still running.  This means the on-disk monitor =20
list and statd's in-memory monitor list will be out of sync.  I seem =20
to recall that sm-notify is run by itself by cluster scripts, and that =
=20
could be a real problem.

As implemented on RH, "service nfslock restart" will restart statd and =
=20
force an sm-notify anyway, so no real harm done, but that's pretty =20
heavyweight (and requires that admins do "service nfs stop; service =20
nfslock restart; service nfs start" or something like that if they =20
want to get proper lock recovery).

A simple restart of statd (outside of the nfslock script) probably =20
won't be adequate, though.  It will respect the sm-notify pidfile, and =
=20
not send notifications when started up.  I don't see a flag on statd =20
to force it to send notifications on restart (-N only sends =20
notifications; it doesn't also start the statd daemon).

In a perfect world, when lockd restarts, it would send up an =20
SM_SIMU_CRASH, and statd would do the right thing:  if there are =20
monitored peers, it would send reboot notifications, and adjust it's =20
monitor list accordingly;  if there were no monitored peers, it would =20
do nothing.  Thus no statd restart would be needed.

>  But now, in kernel and nfs-uitls, it don't implemented.
>  As the communication style between lockd and statd, this is indeed =20
> not easy to implement it.
>
>  So, I think it's should more easy to implement it through the =20
> mechanism that exposes
>  the kernel's nlm_host cache via /sys you show me before.

>>> I want to know when using cammond "service nfslock restart" =20
>>> restart the
>>> nfslock service(means restart statd and lockd), will the statd call
>>> sm-notify
>>> to notify other client? Or don't?
>>
>> Currently "service nfslock restart" always causes a notification to =
=20
>> be
>> sent.  Since "service nfslock restart" causes lockd to drop its =20
>> locks (I
>> assume that's what that "killproc lockd" does) I guess we need to =20
>> force
>> reboot notifications here.  (I still argue that removing the =20
>> pidfile in
>> the "start" case is not correct).
>>
>> It appears that both the nfs and nfslock start up scripts do =20
>> something
>> to lockd (as well as the case when the number of NFS mounts goes to
>> zero).  However, only the nfslock script forces sm-notify to send
>> notifications.
>
>  But, at RHLE5 and Fedora, when using cammond "service nfslock =20
> restart" restart
>  the nfslock service, the lockd isn't shutdown and rmmod'd.
>
>  Is it a bug?

=46or the "no more NFS mounts case" and the server shutdown case, the =20
NFS client or server, both being in the kernel, call lockd_down enough =
=20
times to make the user count go to zero.  lockd.ko can be removed at =20
that point.  I seem to recall there being some kind of automatic =20
mechanism for module removal after a period of zero module refcount.  =20
In other words, lockd.ko is removed as a side effect, afaict.

The nfslock script doesn't stop either the kernel client or server =20
code, so it doesn't really cause a lockd_down call.  But, nfslock does =
=20
do a "killproc lockd".  My assumption is that causes all locks to be =20
dropped.  So it's not a cold restart of lockd, but we still =20
potentially lose a lot of lock state here.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

