Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:59947 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879Ab1KPV4G convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Nov 2011 16:56:06 -0500
Received: by yenq3 with SMTP id q3so226915yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 16 Nov 2011 13:56:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EC41B46.60002@netapp.com>
References: <loom.20111114T180637-632@post.gmane.org>
	<4EC1678D.902@netapp.com>
	<4EC18E5F.4080101@netapp.com>
	<loom.20111115T142111-739@post.gmane.org>
	<4EC2DE49.5070000@netapp.com>
	<20111115221623.GA12453@fieldses.org>
	<4EC3C7BD.6060407@netapp.com>
	<20111116153052.GA20545@fieldses.org>
	<4EC3F4E3.7050803@netapp.com>
	<CAA-yEOLYRSxxOWPEe+e_C4T=qkQcKenzw=PNjq4cACYYXA8ncA@mail.gmail.com>
	<20111116200837.GD2955@pad.fieldses.org>
	<4EC41B46.60002@netapp.com>
Date: Wed, 16 Nov 2011 23:56:05 +0200
Message-ID: <CAA-yEOL=vsCzVfYicpwgTqYuq6m5LUQ0inzMJ_uz8mynV=vuAw@mail.gmail.com>
Subject: Re: clients fail to reclaim locks after server reboot or manual sm-notify
From: Pavel A <free.lan.c2.718r@gmail.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2011/11/16 Bryan Schumaker <bjschuma@netapp.com>:
> On 11/16/2011 03:08 PM, J. Bruce Fields wrote:
>> On Wed, Nov 16, 2011 at 09:09:07PM +0200, Pavel A wrote:
>>> I've read about this issue here:
>>> http://www.time-travellers.org/shane/papers/NFS_considered_harmful.html
>>>
>>> /*-----
>>> In the event of server failure (e.g. server reboot or lock daemon
>>> restart), all client locks are lost. However, the clients are not
>>> informed of this, and because the other operations (read, write, and
>>> so on) are not visibly interrupted, they have no reliable way to
>>> prevent other clients from obtaining a lock on a file they think they
>>> have locked.
>>> -----*/
>>
>> That's incorrect.  Perhaps the article is out of date, I don't know.
>
> Looks like it was written about 11 years ago, so I'll believe that it's out of date.

Yes, should have watched out for that.

>
> - Bryan
>
>>
>>> Can't get this. If there is a grace period after reboot and clients
>>> can successfully reclaim locks, then how other clients can obtain
>>> locks?
>>
>> That's right, in the absence of bugs, if a client succesfully reclaims a
>> lock, then it knows that no other client can have acquired that lock in
>> the interim: since the reclaim succeeded, that means the server is still
>> in the grace period, which means the only other locks that it has
>> allowed are also reclaims.  If some reclaim conflicts with this lock,
>> then the other client must have reclaimed a lock that it didn't actually
>> hold before (hence must be buggy).
>>
>>>> You need to restart nfsd on the node that is taking over.  That means
>>>> that clients usings both filesystems (A and B) will have to do lock
>>>> recovery, when in theory only those using volume B should have to, and
>>>> that is suboptimal.  But it is also correct.
>>>>
>>>
>>> Seems to work. As of a more optimal solution: what do you think of the
>>> contents of /proc/locks? May it be possible to use this info to then
>>> perform locking locally on the other node (after failover)?
>>
>> No, I don't think so.  And I'd be careful about using /proc/locks for
>> anything but debugging.
>>
>> --b.
>
>
Well, looks like this is it.
Thank you very much, Bruce, Bryan - you real helped me to keep this going :)
