Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50572 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752263AbcKPKRX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 16 Nov 2016 05:17:23 -0500
Subject: Re: [Libtirpc-devel] [PATCH rpcbind v2] Move default state-dir to a
 subdirectory of /tmp
To: NeilBrown <neilb@suse.com>
References: <877f8almcf.fsf@notabene.neil.brown.name>
 <20161111210034.GM21655@vapier.lan> <87polzj7sx.fsf@notabene.neil.brown.name>
 <87vavqilre.fsf@notabene.neil.brown.name>
 <ed1f4f4c-fda6-6909-baab-5fbde2a5bc6c@RedHat.com>
 <8760noi4wi.fsf@notabene.neil.brown.name>
Cc: Mike Frysinger <vapier@gentoo.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <a602543b-d002-455c-9e62-10f6920204c8@RedHat.com>
Date: Wed, 16 Nov 2016 05:17:19 -0500
MIME-Version: 1.0
In-Reply-To: <8760noi4wi.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/15/2016 08:34 PM, NeilBrown wrote:
> On Wed, Nov 16 2016, Steve Dickson wrote:
>
>> On 11/14/2016 02:05 AM, NeilBrown wrote:
>>> rpcbind can save state in a file to allow restart without forgetting
>>> about running services.
>>>
>>> The default location is currently "/tmp" which is
>>> not ideal for system files.  It is particularly unpleasant
>>> to put simple files there rather than creating a directory
>>> to contain them.
>>>
>>> On a modern Linux system it is preferable to use /run, and there it is
>>> even more consistent with practice to use a subdirectory.
>>>
>>> This directory needs to be create one each boot, and while there are
>>> tools (e.g. systemd-tmpfiles) which can do that it is cleaner to keep
>>> rpcbind self-contained and have it create the directory.
>>>
>>> So change the default location to /tmp/rpcbind, and create that
>>> directory.  If a different user-id is used, we need to create
>>> and chown the directory before dropping privileges.  We do this
>>> with care so avoid chowning the wrong thing by mistake.
>>>
>>> Signed-off-by: NeilBrown <neilb@suse.com>
>>> ---
>>>
>>> hi,
>>>  I realized that I hadn't allowed for the fact that rpcbind changes
>>>  it's uid, and we need to mkdir and chown before that.
>>>  I've also reverted the move to /run, but moved to /tmp/rpcbind
>>>  instead.  A subdirectory is a good idea, even in /tmp.
>> I'm beginning to think put these files into a directory call /tmp/rpcbind
>> is not a good idea...  Because if something in /tmp is called rpcbind (like a
>> debugging binary ;-) ) the mkdirs will silently fail which is not good.
>>
>> Here is what I would like to do.
>>
>> Move the directory into /run then create the /run/rpcbind when it
>> does not exist... I think that should play nicely in both the
>> systemd worlds and non-systemd worlds
>>
>> Thoughts?
> /var/run rather than /run seems to be a safer universal default.
> Linux distros can run ./configure --with-statedir=/run/rcpbind
Fair enough... I can roll with that.
>
> Otherwise, I think we are in agreement.
>
> You want I should respin with /tmp/rpcbind -> /var/run/rpcbind ??
Sure...

thanks!

steved.

>
> Thanks,
> NeilBrown

