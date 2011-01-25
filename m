Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gossamer.nmsrv.com ([208.70.244.21]:39928 "EHLO
	gossamer.nmsrv.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936Ab1AYWi0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jan 2011 17:38:26 -0500
Message-ID: <4D3F50DA.3060208@gt.net>
Date: Tue, 25 Jan 2011 14:38:18 -0800
From: Nathan March <nathan@gt.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Stale file not being refreshed automatically?
References: <4D3F4A8A.7040003@gt.net> <1295994532.6867.12.camel@heimdal.trondhjem.org>
In-Reply-To: <1295994532.6867.12.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Ah ha, yes, it's using a stat call.

What would be the proper C call to check the file exists without 
incurring the stat()?

Thanks!

- Nathan

On 1/25/2011 2:28 PM, Trond Myklebust wrote:
> On Tue, 2011-01-25 at 14:11 -0800, Nathan March wrote:
>> Hi All,
>>
>> Having a strange issue, I've reproduced this both on nfs 3 and 4.
>> Currently using v4 with:
>>
>> exports:
>> /var/home/voyage
>> 10.2.1.0/24(rw,fsid=0,async,wdelay,secure,no_subtree_check,anonuid=1000,anongid=1006)
>>
>> fstab:
>> 10.2.1.1:/ /mnt/voyage nfs4
>> rsize=32768,wsize=32768,noatime,nosuid,rw,bg,hard,intr 0 0
>>
>> Can be produced using these two commands on 2 machines:
>>
>> perl -le '$| = 1 ; while (1) { sleep 1; $res = -e "/home/voyage/test";
>> if ($res) { print "-e : $res"; } else { print "-e : $res ($!)"; } }'
>> -e : 1
>>
>> perl -le '$| = 1 ; while (1) { sleep 5; open(F, ">",
>> "/home/voyage/test.foo"); close F; my $res =
>> rename("/home/voyage/test.foo", "/home/voyage/test"); print "rename
>> ($res)"; }'
>>
>> The first command will occasionally print out: -e :  (Stale NFS file handle)
>>
>> Now according to http://nfs.sourceforge.net/#faq_a10 as of 2.6.12 the
>> vfs should automatically retry when it gets a estale during path
>> resolution. This doesn't appear to be happening though based on the
>> errors I'm seeing.
>>
>> Anyone have any thoughts on what might be happening here? Or am I
>> misinterpreting that faq entry? (This is on ext3 if it matters)
> Does '-e' in perl only do a lookup, or does it result in a 'stat()'
> call? If the latter, then your test is flawed: a stat() is a lookup+a
> getattr, and the latter can definitely return ESTALE when you are
> constantly replacing the file.
>
> Cheers
>    Trond
