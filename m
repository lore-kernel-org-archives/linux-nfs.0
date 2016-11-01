Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47786 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751050AbcKAWDN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 Nov 2016 18:03:13 -0400
Subject: Re: [PATCH nfs-utils] nfs-server-generator: avoid using external
 services.
To: NeilBrown <neilb@suse.com>
References: <8737k0215d.fsf@notabene.neil.brown.name>
 <4a004767-e7cd-d427-706e-4e144b7bdbbb@RedHat.com>
 <87wpgnq8jx.fsf@notabene.neil.brown.name>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <d58fc30b-bd9a-c280-c8a3-0358e9f1de01@RedHat.com>
Date: Tue, 1 Nov 2016 18:03:12 -0400
MIME-Version: 1.0
In-Reply-To: <87wpgnq8jx.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/01/2016 03:55 PM, NeilBrown wrote:
> On Wed, Nov 02 2016, Steve Dickson wrote:
> 
>> Hello,
>>
>> On 10/13/2016 02:50 AM, NeilBrown wrote:
>>>
>>> nfs-server-generator is run very early when a lot of services
>>> are not yet started, so it mustn't depend on them.
>>> Currently it can try to use hostname lookup and syslog.
>>>
>>> Hostname-lookup is not needed, as we don't use the host issue,
>>> and sending message to stderr is sufficient for the generator.
>>>
>>> Disabling syslog is easy - call a function that sets a static variable.
>>>
>>> Disabling hostname lookup isn't quite so easy, so add a static variable
>>> which can be set to disable it.
>>>
>>> Signed-off-by: NeilBrown <neilb@suse.com>
>>> ---
>>>
>>> hi,
>>>  I contemplated passing another arg to export_read() and export_d_read()
>>>  to resolve this, but it didn't seem worth it.
>>>
>>>  Is this approach OK to people?
>> It's not the most eloquent interface I've 
>> ever seen... ;-) 
>>
>> What are the failures this is fixing? When a
>> hostname lookup is done what happens? Failure
>> hangs stopping the server from coming up?
> 
>  I never actually reproduced it myself, but I think that when hostname
>  lookup failed (possibly after a timeout) it tried to log an error via
>  syslog and writing to syslog blocked indefinitely.
>  The systemd.generator manpage explicitly rules out trying to talk to
>  syslog.
This makes sense... 

> 
> 
>>
>>  
>>>
>>> Thanks,
>>> NeilBrown
>>>
>>>
>>>  support/export/export.c        | 12 ++++++++++--
>>>  support/include/exportfs.h     |  1 +
>>>  systemd/nfs-server-generator.c |  4 ++++
>>>  3 files changed, 15 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/support/export/export.c b/support/export/export.c
>>> index 0b8a858c2c74..c65dc8807a4e 100644
>>> --- a/support/export/export.c
>>> +++ b/support/export/export.c
>>> @@ -67,6 +67,14 @@ static void warn_duplicated_exports(nfs_export *exp, struct exportent *eep)
>>>  	}
>>>  }
>> If we do have to stay with this approach, 
>> I definitely think comment explaining
>> why its needed and what it does.
> 
> That's sensible.  I'll resend with some nice friendly comments.
Thanks! 

> 
>>
>> Finally, on an unrelated issue I'm seeing 
>> SELinux preventing nfs-server-generator from 
>> accessing nfs-server.service.d/order-with-mounts.conf
>> because of a labeling issue. I guess the label
>> should be nfsd_unit_file_t not systemd_unit_file_t
> 
> I wouldn't know about that :-(
I'll figure this out... 

steved.

> 
> Thanks,
> NeilBrown
> 
