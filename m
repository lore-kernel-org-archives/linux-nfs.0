From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC] server's statd and lockd will not sync after its nfslock restart
Date: Thu, 17 Dec 2009 15:35:42 -0500
Message-ID: <5F4CA47C-B0D1-488C-8B91-FE26DC9AF01A@oracle.com>
References: <4B275EA3.9030603@cn.fujitsu.com> <F9F5EA38-B51C-44A4-9812-873EEE1891C9@oracle.com> <4B28B5FD.5000103@cn.fujitsu.com> <E6EC8330-4C4C-4917-AEE3-A2BEE35B9F8A@oracle.com> <4B2A02C6.6080501@cn.fujitsu.com> <35D45F43-D98F-460E-8060-F7C5F3ADFCFE@oracle.com> <20091217201430.GA20185@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=UTF-8;
	format=flowed	delsp=yes
Cc: "Trond.Myklebust Myklebust" <trond.myklebust@fys.uio.no>,
	Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>,
	Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:34687 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762781AbZLQUhM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Dec 2009 15:37:12 -0500
In-Reply-To: <20091217201430.GA20185@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 17, 2009, at 3:14 PM, J. Bruce Fields wrote:
> On Thu, Dec 17, 2009 at 11:18:53AM -0500, Chuck Lever wrote:
>> run_sm_notify() simply forks and execs the sm-notify program.  This
>> program checks for the existence of a pid file.  If the pid file =20
>> exists,
>> then sm-notify exits.  If it does not, then sm-notify retires the =20
>> records
>> in /var/lib/nfs/statd/sm and posts reboot notifications.
>>
>> Jeff Layton pointed out to me yesterday that Red Hat's nfslock scrip=
t
>> unconditionally deletes sm-notify's pid file every time "service =20
>> nfslock
>> start" is done, which effectively defeats sm-notify's reboot =20
>> detection.
>>
>> sm-notify was written by a developer at SuSE.  SuSE Linux uses a =20
>> tmpfs
>> for /var/run, but Red Hat uses permanent storage for this directory.
>> Thus on SuSE, the pid file gets deleted automatically by a reboot, =20
>> but
>> on Red Hat, the pid file must be deleted "by hand" or reboot
>> notification never occurs.
>>
>> So the root cause of this problem is that the current mechanism sm-
>> notify uses to detect a reboot is not portable across distributions.
>>
>> My new-statd prototype used a semaphor instead of a pid file to =20
>> detect
>> reboots.  A semaphor is shared (visible to other processes) and will
>> continue to exist until it is deleted or the system reboots.  It is =
a
>> resource that is not destroyed automatically when the sm-notify =20
>> process
>> exits.  If creating the semaphor fails, sm-notify exits.  If =20
>> creating it
>> succeeds, it runs.
>>
>> Would anyone strongly object to using a semaphor instead of a pid =20
>> file
>> here?  Is support for semaphors always built into kernels?  Would =20
>> there
>> be any problems with the small size of the semaphor name space?  Is =
=20
>> there
>> another similar facility that might be better?
>
> I don't know much about those (except that I think there's an e at th=
e
> end); looks like sem_overview(7) is the place to start?
>
> It says:
>
> 	" Prior to kernel 2.6, Linux only supported unnamed,
> 	thread-shared  sema=E2=80=90 phores.   On a system with Linux 2.6 an=
d a
> 	glibc that provides the NPTL threading implementation, a
> 	complete implementation of POSIX semaphores is provided."
>
> So would it mean dropping support for 2.4?

No, it would mean using them only on systems that supported shared =20
semaphores.

--=20
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




