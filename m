Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:51100 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282Ab0H3TWz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 15:22:55 -0400
Message-ID: <4C7C0501.4020302@mudrichsystems.com>
Date: Mon, 30 Aug 2010 21:22:41 +0200
From: David Mudrich <dmudrich@mudrichsystems.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: sfjro@users.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: AUFS triggers Kernel BUG() in nfs_do_writepage (write.c:276)
References: <4C7960EE.6060304@mudrichsystems.com> <3217.1283139187@jrobl> <4C7B53F3.8010709@mudrichsystems.com> <7041.1283154060@jrobl> <4C7BB8C1.40906@mudrichsystems.com> <87900623-DF1B-42EA-8E95-B7D2768D1122@oracle.com>
In-Reply-To: <87900623-DF1B-42EA-8E95-B7D2768D1122@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  Am 30.08.2010 19:28, schrieb Chuck Lever:
> On Aug 30, 2010, at 9:57 AM, David Mudrich wrote:
>
>> Am 30.08.2010 09:41, schrieb sfjro@users.sourceforge.net:
>>> David Mudrich:
>>>> I attached the information you asked for. It seems difficult to have a
>>>> realistic test without AUFS, as it is mounted at the root directory.
>>> Thanx.
>>> It is difficult for me too.
>>> Although I am not confident, these commits (from latest mainline) are
>>> worth to try. If you have no way other than this, you should try.
>>>
>>>
>>> J. R. Okajima
>>>
>> Hello,
>>
>> I applied the patch, same issue.
>> I attached dmesg | tail -n 50.
>>
>> I just tried nfsvers=2 and it works.
>> The problem must be connected with nfs3 writeback.
> Two-phase NFSv3 writes are not like most other file system implementations, so it's not surprising that AUFS might be tripped up.
>
> A possible workaround: If you specify the "sync" mount option when the client mounts the NFS server, it will disable UNSTABLE NFSv3 writes.
mount -o sync was enabled all the time.
>> A copy of this mail goes to the linux-nfs list, maybe they can help to further narrow this.
>>
>>
>> Regards
>>
>> David Mudrich
>> <log.txt>
