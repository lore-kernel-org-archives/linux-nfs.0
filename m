Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:35156 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbaLOM7W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Dec 2014 07:59:22 -0500
Received: by mail-wg0-f44.google.com with SMTP id b13so14476783wgh.17
        for <linux-nfs@vger.kernel.org>; Mon, 15 Dec 2014 04:59:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.OSX.2.19.9992.1412150749290.1119@planck.local>
References: <CAF1in6QVkgyuC7VQ5QdYnYtPRJgArDwg5sXtKiAvyszCcQoZ-g@mail.gmail.com>
	<CAF1in6RCyK4VMM3j1ZD=1D25+cFU9YGg-UhR-kuYcNWNk+Stzg@mail.gmail.com>
	<alpine.OSX.2.19.9992.1412150749290.1119@planck.local>
Date: Mon, 15 Dec 2014 09:59:20 -0300
Message-ID: <CAF1in6QpHmj6Y3UurtZvjsvX2se3DqTWqNxVmYtd2i+xUnEVug@mail.gmail.com>
Subject: Re: Fwd: NFS and Memory Buffers
From: Pablo Silva <psilvao@gmail.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear Benajmin;

     A colleague sent me this information as is, but the curious thing
which does not release the memory buffer, except using the commands
that you can appreciate.

I am investigating if possible "know" that information is being stored
there, and from what I see there is a command linux-fTools that could
help me descubir the information being stored there, do not know if I
bring in my analysis but it is my first step, I do not know if you
have any other suggestions.

grateful

- Pablo

On Mon, Dec 15, 2014 at 9:52 AM, Benjamin Coddington
<bcodding@redhat.com> wrote:
> Dear Pablo,
>
>         Why are you restarting snmpd between flushing cache and reading
> memory values?  On a running system you can probably expect the
> cache to immediately start to fill after a flush anyway.
> y
> Ben
>
> On Mon, 15 Dec 2014, Pablo Silva wrote:
>
>> Dear Readers:
>>
>>      My boss has entrusted me to analyze why the memory buffers are
>> not released a Linux server with Centos 6.4.?
>>
>>     As informs me, the current reading is:
>>
>>
>> [root@bck ~]# free -m
>>              total       used       free     shared    buffers     cached
>> Mem:         15936      15788        147          0       6746        438
>> -/+ buffers/cache:       8604       7332
>> Swap:         2047          0       2047
>> [root@bck ~]#
>> [root@bck ~]#
>> [root@bck ~]# echo 3 > /proc/sys/vm/drop_caches && service snmpd
>> restart && free -m
>> Stopping snmpd:                                            [  OK  ]
>> Starting snmpd:                                            [  OK  ]
>>              total       used       free     shared    buffers     cached
>> Mem:         15936        509      15426          0         93         16
>> -/+ buffers/cache:        400      15536
>> Swap:         2047          0       2047
>> [root@bck ~]#
>>
>>    I can not find the solution to release the memory buffer and cache
>> memory so grateful for any hint for finding the solution to this
>> "problem".
>>
>> -Paul
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
