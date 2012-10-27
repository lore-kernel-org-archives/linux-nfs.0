Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:53819 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966897Ab2J0APK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2012 20:15:10 -0400
Received: by mail-qa0-f53.google.com with SMTP id c1so592212qae.19
        for <linux-nfs@vger.kernel.org>; Fri, 26 Oct 2012 17:15:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFukC=7XWhwWFcwfs=fODk70OHbk8ioOw2KeqS7Ao2wKaqZpWg@mail.gmail.com>
References: <CAFukC=7aTHvXoD9tNhZ5w=3Ffzc-661DNxwAxXy6Lr08VGBO8g@mail.gmail.com>
 <CAFukC=7XWhwWFcwfs=fODk70OHbk8ioOw2KeqS7Ao2wKaqZpWg@mail.gmail.com>
From: Brock Noland <brock@cloudera.com>
Date: Fri, 26 Oct 2012 19:14:49 -0500
Message-ID: <CAFukC=4mfK4cR7D37cs3wwDvVmtTuz04GuW-ShUhqviG5akjvQ@mail.gmail.com>
Subject: Re: rpc.gssd segfault - real time event 32 in pol()
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Never mind. It must be segfauiting somewhere else and gdb just stopped me there.

On Fri, Oct 26, 2012 at 7:09 PM, Brock Noland <brock@cloudera.com> wrote:
> Also I am starting rpc.gssd in the foreground with -v flag.
>
> Brock
>
> On Fri, Oct 26, 2012 at 7:08 PM, Brock Noland <brock@cloudera.com> wrote:
>> Hi,
>>
>> I built nfs-utils, libgssglue, and librpcsecgss from scratch to debug
>> some other issue.
>>
>> However, whenever I try and mount a filesystem with sec=krb5p, I am
>> seeing the following:
>>
>> Program received signal SIG37, Real-time event 37.
>> 0x00000037b72e8b84 in poll () from /lib64/libc.so.6
>> (gdb) bt
>> #0  0x00000037b72e8b84 in poll () from /lib64/libc.so.6
>> #1  0x0000000000404764 in gssd_run () at gssd_main_loop.c:213
>> #2  0x00000000004036b3 in main (argc=<optimized out>, argv=<optimized
>> out>) at gssd.c:194
>>
>> At that point, it's waiting for DNOTIFY_SIGNAL. Is it possible that
>> DNOTIFY_SIGNAL is defined differently in the build versions the
>> runtime?
>>
>> Version info:
>>
>> Linux localhost.localdomain 3.6.2-4.fc17.x86_64 #1 SMP Wed Oct 17
>> 02:43:21 UTC 2012 x86_64 x86_64 x86_64 GNU/Linux
>>
>> nfs-utils-1.2.6
>> libgssglue-0.4
>> librpcsecgss-0.19
>>
>> Brock
>
>
>
> --
> Apache MRUnit - Unit testing MapReduce - http://incubator.apache.org/mrunit/



-- 
Apache MRUnit - Unit testing MapReduce - http://incubator.apache.org/mrunit/
