Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:33736 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004AbbLCPVb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Dec 2015 10:21:31 -0500
Received: by wmec201 with SMTP id c201so32145552wme.0
        for <linux-nfs@vger.kernel.org>; Thu, 03 Dec 2015 07:21:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <565F181C.201@RedHat.com>
References: <1449054998-19308-1-git-send-email-t.vivek@samsung.com>
	<565F181C.201@RedHat.com>
Date: Thu, 3 Dec 2015 20:51:29 +0530
Message-ID: <CAKX=r8CmZ7e-que43qHkg-c8Fo0QXcZmSpK2CxCaDRVMAfY3JA@mail.gmail.com>
Subject: Re: [PATCH 1/2] nfs-utils: libnsm.a: do not close file if open failed
From: Vivek Trivedi <vtrivedi018@gmail.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Vivek Trivedi <t.vivek@samsung.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

thanks for review!
actually, it fixed a coverity issue a while back, so I thought of
sharing this minor change.

thanks!

On Wed, Dec 2, 2015 at 9:41 PM, Steve Dickson <SteveD@redhat.com> wrote:
>
>
> On 12/02/2015 06:16 AM, Vivek Trivedi wrote:
>> If file open failed, no need to issue close system call in
>> nsm_get_state and closeall.
> I guess this makes sense... but what problem is this patch fixing?
>
> steved.
>
>>
>> Signed-off-by: Vivek Trivedi <t.vivek@samsung.com>
>> ---
>>  support/nfs/closeall.c |    3 ++-
>>  support/nsm/file.c     |    3 ++-
>>  2 files changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/support/nfs/closeall.c b/support/nfs/closeall.c
>> index 38fb162..a69bf35 100644
>> --- a/support/nfs/closeall.c
>> +++ b/support/nfs/closeall.c
>> @@ -31,6 +31,7 @@ closeall(int min)
>>       } else {
>>               int fd = sysconf(_SC_OPEN_MAX);
>>               while (--fd >= min)
>> -                     (void) close(fd);
>> +                     if(fd >= 0)
>> +                             (void) close(fd);
>>       }
>>  }
>> diff --git a/support/nsm/file.c b/support/nsm/file.c
>> index 4711c2c..7a8b504 100644
>> --- a/support/nsm/file.c
>> +++ b/support/nsm/file.c
>> @@ -536,7 +536,8 @@ nsm_get_state(_Bool update)
>>               state++;
>>
>>  update:
>> -     (void)close(fd);
>> +     if(fd >= 0)
>> +             (void)close(fd);
>>
>>       if (update) {
>>               state += 2;
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
