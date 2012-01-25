Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56773 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357Ab2AYNR3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jan 2012 08:17:29 -0500
Received: by wgbed3 with SMTP id ed3so5252246wgb.1
        for <linux-nfs@vger.kernel.org>; Wed, 25 Jan 2012 05:17:28 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <4F1FF9A0.2000505@panasas.com>
References: <CAGue13ozQQ=qn-TqpLF093HbbnZdKAshrhHZ97OSj7u0SDVxng@mail.gmail.com>
	<4F1FF91B.3010708@panasas.com>
	<4F1FF9A0.2000505@panasas.com>
Date: Wed, 25 Jan 2012 14:17:27 +0100
Message-ID: <CAGue13ot0YWOxWZFT6BUnbHZdOnJs9eRxNpq2f=gvzCyxb03YA@mail.gmail.com>
Subject: Re: blacklisted DS with pnfs
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Boaz I will check.

I believe rhel6 kernel does not support  device notification.
Currently we just generated a new device id.

Tigran.

On Wed, Jan 25, 2012 at 1:46 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 01/25/2012 02:44 PM, Boaz Harrosh wrote:
>> On 01/25/2012 11:56 AM, Tigran Mkrtchyan wrote:
>>> Hi,
>>>
>>> we have observed that in some situations ( probably network glitches )
>>> the pnfs client blacklisted one of the data servers:
>>>
>>> NFS: data server 83a95099 connection error -12. Deviceid [22000000000]
>>> marked out of use.
>>>
>>> As a result, data server can't be used by this client anymore.
>>>
>>> Is there a way to let client to forget about data server?
>>> Some magic in /proc ?
>>>
>>> This is SL6.2 (RHEL 6.2):
>>> # uname -a
>>> Linux p3-wgs13 2.6.32-220.2.1.el6.x86_64 #1 SMP Thu Dec 22 11:15:52
>>> CST 2011 x86_64 x86_64 x86_64 GNU/Linux
>>> #
>>>
>>
>> Look in the source code, I think there is a RECALL that the server
>> can do to trash the all device cache. or one of the devices.
>>
>> What happens is that the device is marked with error but is in
>> cache so is not re-fetched.
>>
>> wait let me look ....
>>
>> I found it! The server sends a NOTIFY_DEVICEID4_CHANGE. The
>> client will remove the deviceid from cache and unmount if needed.
>> Next layout with that deviceid will re-establish the connection and
>> will put a new clean entry in the dev cache.
>>
>
> If you want to see for your self look at:
>  callback_proc.c::nfs4_callback_devicenotify()
>
> Boaz
>> [If you decide to enhance pynfs to send a NOTIFY_DEVICEID4_CHANGE as an admin
>>  tool. That would be interesting]
>>
>>> Regards,
>>>    Tigran.
>>
>> Cheers
>> Boaz
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
