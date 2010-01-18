From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [RFC] After nfs restart, locks can't be recovered which record
 by lockd before
Date: Mon, 18 Jan 2010 18:51:50 +0800
Message-ID: <4B543D46.1070900@cn.fujitsu.com>
References: <4B4D979D.6090307@cn.fujitsu.com> <20100113075155.5c409567@barsoom.rdu.redhat.com> <4B4E16C3.4050206@oracle.com> <4B4EECB2.8050400@cn.fujitsu.com> <10874277-0968-420D-82DD-D61AB672C9C0@oracle.com> <4B5036FB.8020905@cn.fujitsu.com> <2479069D-FCE0-42B5-9531-A3B7BA231E2F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Layton <jlayton@redhat.com>,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55700 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751331Ab0ARKvt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jan 2010 05:51:49 -0500
In-Reply-To: <2479069D-FCE0-42B5-9531-A3B7BA231E2F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

Chuck Lever =E5=86=99=E9=81=93:
> On Jan 15, 2010, at 4:35 AM, Mi Jinlong wrote:

=2E..snip...

>>>>
>>>> Maybe, the kernel should fix this.
>>>
>>> What did you have in mind?
>>
>>  I think when lockd restart, statd should restart too and sent
>> sm-notify to other client.
>=20
> Sending notifications is likely the correct thing to do if lockd is
> restarted while there are active locks.  A statd restart isn't
> necessarily required to send reboot notifications, however.  You can =
do
> it with "sm-notify -f".
>=20
> The problem with "sm-notify -f" is that it deletes the on-disk monito=
r
> list while statd is still running.  This means the on-disk monitor li=
st
> and statd's in-memory monitor list will be out of sync.  I seem to
> recall that sm-notify is run by itself by cluster scripts, and that
> could be a real problem.
>=20
> As implemented on RH, "service nfslock restart" will restart statd an=
d
> force an sm-notify anyway, so no real harm done, but that's pretty
> heavyweight (and requires that admins do "service nfs stop; service
> nfslock restart; service nfs start" or something like that if they wa=
nt
> to get proper lock recovery).
>=20
> A simple restart of statd (outside of the nfslock script) probably wo=
n't
> be adequate, though.  It will respect the sm-notify pidfile, and not
> send notifications when started up.  I don't see a flag on statd to
> force it to send notifications on restart (-N only sends notification=
s;
> it doesn't also start the statd daemon).
>=20
> In a perfect world, when lockd restarts, it would send up an
> SM_SIMU_CRASH, and statd would do the right thing:  if there are
> monitored peers, it would send reboot notifications, and adjust it's
> monitor list accordingly;  if there were no monitored peers, it would=
 do
> nothing.  Thus no statd restart would be needed.

  Did this part have implemented at kernel?
  I don't find the codes about SM_SIMU_CRASH.

  IMO, if SM_SIMU_CRASH can work correctly, after lockd restart,
  the lockd and statd would work correctly (SYN) too.
  And the problem I asked above will not be happened.

>=20
>>  But now, in kernel and nfs-uitls, it don't implemented.
>>  As the communication style between lockd and statd, this is indeed
>> not easy to implement it.
>>
>>  So, I think it's should more easy to implement it through the
>> mechanism that exposes
>>  the kernel's nlm_host cache via /sys you show me before.
>=20
>>>> I want to know when using cammond "service nfslock restart" restar=
t the
>>>> nfslock service(means restart statd and lockd), will the statd cal=
l
>>>> sm-notify
>>>> to notify other client? Or don't?
>>>
>>> Currently "service nfslock restart" always causes a notification to=
 be
>>> sent.  Since "service nfslock restart" causes lockd to drop its loc=
ks (I
>>> assume that's what that "killproc lockd" does) I guess we need to f=
orce
>>> reboot notifications here.  (I still argue that removing the pidfil=
e in
>>> the "start" case is not correct).
>>>
>>> It appears that both the nfs and nfslock start up scripts do someth=
ing
>>> to lockd (as well as the case when the number of NFS mounts goes to
>>> zero).  However, only the nfslock script forces sm-notify to send
>>> notifications.
>>
>>  But, at RHLE5 and Fedora, when using cammond "service nfslock
>> restart" restart
>>  the nfslock service, the lockd isn't shutdown and rmmod'd.
>>
>>  Is it a bug?
>=20
> For the "no more NFS mounts case" and the server shutdown case, the N=
=46S
> client or server, both being in the kernel, call lockd_down enough ti=
mes
> to make the user count go to zero.  lockd.ko can be removed at that
> point.  I seem to recall there being some kind of automatic mechanism
> for module removal after a period of zero module refcount.  In other
> words, lockd.ko is removed as a side effect, afaict.
>=20
> The nfslock script doesn't stop either the kernel client or server co=
de,
> so it doesn't really cause a lockd_down call.  But, nfslock does do a
> "killproc lockd".  My assumption is that causes all locks to be
> dropped.  So it's not a cold restart of lockd, but we still potential=
ly
> lose a lot of lock state here.

 Thanks for your explain!

Thanks,
Mi Jinlong

