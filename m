Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37832 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004AbbLCPWa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Dec 2015 10:22:30 -0500
Received: by wmww144 with SMTP id w144so26709988wmw.0
        for <linux-nfs@vger.kernel.org>; Thu, 03 Dec 2015 07:22:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <565F1953.1060103@RedHat.com>
References: <1449054998-19308-1-git-send-email-t.vivek@samsung.com>
	<1449054998-19308-2-git-send-email-t.vivek@samsung.com>
	<565F1953.1060103@RedHat.com>
Date: Thu, 3 Dec 2015 20:52:29 +0530
Message-ID: <CAKX=r8AqB=wcO9WjZ4t65=EmSaeng5hLu2NteLykYn6nV7vh1w@mail.gmail.com>
Subject: Re: [PATCH 2/2] nfs-utils: mount.nfs: fix null pointer derefernce in nfs_parse_simple_hostname
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

On Wed, Dec 2, 2015 at 9:46 PM, Steve Dickson <SteveD@redhat.com> wrote:
> hello,
>
> On 12/02/2015 06:16 AM, Vivek Trivedi wrote:
>> In function nfs_parse_simple_hostname, hostname can be NULL,
>> dereferncing it while passing it to free(*hostname) may result in segfault.
> Again I can see the logic but I wondering why/how a NULL hostname
> is being passed. I don't see how a NULL hostname can be passed
> in esp during a mount....
>
> steved.
>
>>
>> Signed-off-by: Vivek Trivedi <t.vivek@samsung.com>
>> ---
>>  utils/mount/parse_dev.c |    3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/utils/mount/parse_dev.c b/utils/mount/parse_dev.c
>> index d64b83d..0d3bcb9 100644
>> --- a/utils/mount/parse_dev.c
>> +++ b/utils/mount/parse_dev.c
>> @@ -118,7 +118,8 @@ static int nfs_parse_simple_hostname(const char *dev,
>>       if (pathname) {
>>               *pathname = strndup(colon, path_len);
>>               if (*pathname == NULL) {
>> -                     free(*hostname);
>> +                     if (hostname)
>> +                             free(*hostname);
>>                       return nfs_pdn_nomem_err();
>>               }
>>       }
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
