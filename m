Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out03.mta.xmission.com ([166.70.13.233]:53438 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756592AbaJXSTM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2014 14:19:12 -0400
From: ebiederm@xmission.com (Eric W. Biederman)
To: Hans de Bruin <jmdebruin@xmsnet.nl>
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
References: <543ED24D.4070905@xmsnet.nl> <5443F5A1.1050004@xmsnet.nl>
	<544A7933.3010702@xmsnet.nl> <544A7D5C.5060804@xmsnet.nl>
Date: Fri, 24 Oct 2014 13:18:22 -0500
In-Reply-To: <544A7D5C.5060804@xmsnet.nl> (Hans de Bruin's message of "Fri, 24
	Oct 2014 18:25:00 +0200")
Message-ID: <871tpx1gcx.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: 3.17.0+ files disappearing after playing old dos game on nfsroot laptop
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hans de Bruin <jmdebruin@xmsnet.nl> writes:

> On 10/19/2014 07:32 PM, Hans de Bruin wrote:
>> On 10/15/2014 10:00 PM, Hans de Bruin wrote:
>>> After playing an old dos game i am missing files on my nfsroot installed
>>> laptop. Which one, wel /bin/ls is at least one of them. After a reboot
>>> there all back again.  But not al is well. Some icons on my kde panel
>>> where gone. I have seen this twice in the last day's
>>>
>>
>> The problem appears immediately after starting dosemu so this bisectable
>>
>
>
> My bisect ended here:
>
> commit 8ed936b5671bfb33d89bc60bdcc7cf0470ba52fe
> Author: Eric W. Biederman <ebiederman@twitter.com>
> Date:   Tue Oct 1 18:33:48 2013 -0700
>
>
>      vfs: Lazily remove mounts on unlinked files and directories.
>
>
> I haven reverted it yet.
>
>
>
> Eric,
>
> Immediately after starting dosemu all files under mount point /usr are
> gone. When I play a old dos game for a while (binaries are under /home)
> even /bin/ls disappears. Al mounts are nfs, even /.
>
> Could you look in to this and cc this to the relevant kernel
> mailinglist?

At this point I don't know enough to reproduce this.
What does /proc/mounts look like before you start dosemu?

My expectation is that you should only see this if the mount points are
removed on the nfs server (which does not sound like it is the case).

Although a transient malfunction of the nfs server or misplaced call to
check_submounts_and_drop could cause mounts to disappear as well.  
During testing autofs was observed to have an inappropriate call
to d_invalidate and it is unlikely but possible something like
that is going on with nfs as well.

Are your nfs mounts read-only or read-write?

What is your nfs-server and what is it exporting?
Which distro are you running?
Which version of dosemu are you running?
How is dosemu configured to access files on your filesystem?

Eric
