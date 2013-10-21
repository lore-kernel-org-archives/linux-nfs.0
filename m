Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28316 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753626Ab3JUOS7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 10:18:59 -0400
Message-ID: <526537F3.2000303@RedHat.com>
Date: Mon, 21 Oct 2013 10:19:31 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@netapp.com>
CC: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mountstats: enforce new python syntax
References: <1382346241-20637-1-git-send-email-tigran.mkrtchyan@desy.de> <D009ABC0-C071-4597-8B67-11C7A0486383@netapp.com>
In-Reply-To: <D009ABC0-C071-4597-8B67-11C7A0486383@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 21/10/13 10:04, Weston Andros Adamson wrote:
> I posted a similar patch last week.
Which has been committed!

steved.
> 
> -dros
> 
> On Oct 21, 2013, at 5:04 AM, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de> wrote:
> 
>> $ mountstats
>>  File "/usr/sbin/mountstats", line 272
>>    (count, ((count * 100) / sends)), end=' ')
>>                                         ^
>> SyntaxError: invalid syntax
>>
>> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>> ---
>> tools/mountstats/mountstats.py | 1 +
>> 1 file changed, 1 insertion(+)
>>
>> diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
>> index 3f5fea5..351145e 100644
>> --- a/tools/mountstats/mountstats.py
>> +++ b/tools/mountstats/mountstats.py
>> @@ -1,5 +1,6 @@
>> #!/usr/bin/env python
>> # -*- python-mode -*-
>> +from __future__ import print_function
>> """Parse /proc/self/mountstats and display it in human readable form
>> """
>>
>> -- 
>> 1.8.3.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
