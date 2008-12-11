From: "Thomas Garner" <thomas536@gmail.com>
Subject: Re: more nfsv4 lockups w/ nexenta
Date: Thu, 11 Dec 2008 16:30:20 -0500
Message-ID: <9ef864c50812111330v1c9dc200s49dacb5504bbfeca@mail.gmail.com>
References: <9ef864c50812110940o7ab17a2dvc83ac7653ad6dd21@mail.gmail.com>
	 <1229018528.6463.23.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f13.google.com ([209.85.218.13]:60222 "EHLO
	mail-bw0-f13.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756983AbYLKVlu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Dec 2008 16:41:50 -0500
Received: by bwz6 with SMTP id 6so2764418bwz.13
        for <linux-nfs@vger.kernel.org>; Thu, 11 Dec 2008 13:41:48 -0800 (PST)
In-Reply-To: <1229018528.6463.23.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The logs in particular are from Nov, but a lockup today prompted the
email.  Today's event does not appear to have been due to a reboot or
server restart (though I'm not as familiar with the intricacies of
Sun's daemon management), as both seem to have been up since Dec 2:

[root@filer0 ~]# uptime
  4:25pm  up 9 day(s), 12:23,  2 users,  load average: 0.26, 0.26, 0.27
[root@filer0 ~]# svcs nfs/server
STATE          STIME    FMRI
online         Dec_02   svc:/network/nfs/server:default

I can provide specific info from today (though I'll need to gather
it).  Just let me know.

Thomas

On Thu, Dec 11, 2008 at 1:02 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Thu, 2008-12-11 at 12:40 -0500, Thomas Garner wrote:
>> I have a Debian client running 2.6.27.5 connecting over nfsv4 to a
>> Nexenta nfs server running b85 (and even with b103) that is
>> experiencing nfs lockups.  The symptoms are basically that nfs stops
>> working (usually first noticed as Firefox locking up, but trying to
>> log in as a user w/ an nfs mounted home dir hangs as well, as does
>> trying to list said nfs mounted home directory).  Trying a `umount -f`
>> doesn't usually resolve the issue.  Unfortunately there are no logs
>> indicating what the issue is, so I've done some preliminary dumps.
>> Here is the relevant portion of the process list:
>>
>>  3295 ?        S<    24:55  \_ [rpciod/0]
>>  3296 ?        S<    46:14  \_ [rpciod/1]
>>  3297 ?        S<    55:17  \_ [rpciod/2]
>>  3298 ?        S<    19:01  \_ [rpciod/3]
>>  3315 ?        R<   185:15  \_ [nfsiod]
>>  4464 ?        D<     0:00  \_ [nfsv4-svc]
>> 25203 ?        S      0:00  \_ [pdflush]
>> 26618 ?        S      0:00  \_ [pdflush]
>> 27343 ?        R<   252:35  \_ [192.168.0.10-re]
>> 27344 ?        D      0:00  \_ [nfsv4-delegretu]
>>
>> I've also put up a /var/log/messages with `rpcdebug -m rpc -s all` and
>> `rpcdebug -m nfs -s all` turned on:
>>
>> http://s120158928.onlinehome.us/messages.2.gz
>>
>> And a `tcpdump -s 0 -w nfs_dump_argento5 -x -i eth0`:
>
> >From the logs, it looks like it is recovery related. Did the server
> reboot just before the hang?
>
> Cheers
>  Trond
>
>
