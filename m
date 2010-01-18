From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC] After nfs restart, locks can't be recovered which record by lockd before
Date: Mon, 18 Jan 2010 11:17:58 -0500
Message-ID: <395E7F65-4C4E-4426-A35C-C1A9D2855E0D@oracle.com>
References: <4B4D979D.6090307@cn.fujitsu.com> <20100113075155.5c409567@barsoom.rdu.redhat.com> <4B4E16C3.4050206@oracle.com> <4B4EECB2.8050400@cn.fujitsu.com> <10874277-0968-420D-82DD-D61AB672C9C0@oracle.com> <4B5036FB.8020905@cn.fujitsu.com> <2479069D-FCE0-42B5-9531-A3B7BA231E2F@oracle.com> <4B543D46.1070900@cn.fujitsu.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=UTF-8;
	format=flowed	delsp=yes
Cc: Jeff Layton <jlayton@redhat.com>,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:41999 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754544Ab0ARQTJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jan 2010 11:19:09 -0500
In-Reply-To: <4B543D46.1070900@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 18, 2010, at 5:51 AM, Mi Jinlong wrote:

> Hi Chuck,
>
> Chuck Lever =E5=86=99=E9=81=93:
>> On Jan 15, 2010, at 4:35 AM, Mi Jinlong wrote:
>
> ...snip...
>
>>>>>
>>>>> Maybe, the kernel should fix this.
>>>>
>>>> What did you have in mind?
>>>
>>> I think when lockd restart, statd should restart too and sent
>>> sm-notify to other client.
>>
>> Sending notifications is likely the correct thing to do if lockd is
>> restarted while there are active locks.  A statd restart isn't
>> necessarily required to send reboot notifications, however.  You =20
>> can do
>> it with "sm-notify -f".
>>
>> The problem with "sm-notify -f" is that it deletes the on-disk =20
>> monitor
>> list while statd is still running.  This means the on-disk monitor =20
>> list
>> and statd's in-memory monitor list will be out of sync.  I seem to
>> recall that sm-notify is run by itself by cluster scripts, and that
>> could be a real problem.
>>
>> As implemented on RH, "service nfslock restart" will restart statd =20
>> and
>> force an sm-notify anyway, so no real harm done, but that's pretty
>> heavyweight (and requires that admins do "service nfs stop; service
>> nfslock restart; service nfs start" or something like that if they =20
>> want
>> to get proper lock recovery).
>>
>> A simple restart of statd (outside of the nfslock script) probably =20
>> won't
>> be adequate, though.  It will respect the sm-notify pidfile, and not
>> send notifications when started up.  I don't see a flag on statd to
>> force it to send notifications on restart (-N only sends =20
>> notifications;
>> it doesn't also start the statd daemon).
>>
>> In a perfect world, when lockd restarts, it would send up an
>> SM_SIMU_CRASH, and statd would do the right thing:  if there are
>> monitored peers, it would send reboot notifications, and adjust it's
>> monitor list accordingly;  if there were no monitored peers, it =20
>> would do
>> nothing.  Thus no statd restart would be needed.
>
>  Did this part have implemented at kernel?
>  I don't find the codes about SM_SIMU_CRASH.

There isn't such code in the current kernel.  I'm simply suggesting a =20
possible solution.

I'm coding up a patch that does this so we can experiment with it.  =20
I'm a little worried that the current statd code won't do the right =20
thing, or even worse, it would crash.  That would make it difficult to =
=20
introduce such a patch without triggering regressions.

--=20
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




