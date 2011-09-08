Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailservice.tudelft.nl ([130.161.131.5]:34110 "EHLO
	mailservice.tudelft.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932322Ab1IHIT4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Sep 2011 04:19:56 -0400
Message-ID: <4E687AA8.6000706@tudelft.nl>
Date: Thu, 08 Sep 2011 10:19:52 +0200
From: Richard Smits <R.Smits@tudelft.nl>
To: NeilBrown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: rpc.mountd switch not working
References: <4E64C8A0.6020806@tudelft.nl> <20110907160933.2a26ef3a@notabene.brown>
In-Reply-To: <20110907160933.2a26ef3a@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/07/2011 08:09 AM, NeilBrown wrote:
> On Mon, 05 Sep 2011 15:03:28 +0200 Richard Smits<R.Smits@tudelft.nl>  wrote:
>
>> Hello,
>>
>> I have a question about the use of the following switch with rpc.mountd.
>>
>> -g  or  --manage-gids
>>
>> It has come to my attention that the use of this switch is not working
>> well in Redhat v6. When I have a user who has a large group membership,
>> the following errors appear, and the "cd" command hangs.
>>
>> Sep  5 14:50:04 srv043 rpc.mountd[2563]: qword_eol: fflush failed: errno
>> 22 (Invalid argument)
>>
>> Process :
>>
>> root      2563     1  0 14:44 ?        00:00:00 rpc.mountd -g
>>
>> The use of 60 groups is working well, but we have some users with more
>> than 100 groups, and those fails. For uid mapping we use Winbind.
>>
>> /etc/exports :
>>
>> /export  server.company.com(rw,no_subtree_check,no_root_squash)
>>
>> Client fstab :
>>
>> server.company.com:/export   /data           nfs
>> nolock,defaults,user        1 2
>>
>> Can anyone tell me what this error means ?
>
> Probably means that the redhat package is missing upstream commit
> 9274e94db85bac04e170414cb8e0f4be271cde90
> (which is from April this year, so not unlikely).
>
> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=commitdiff;h=5604b35a61e22930873ffc4e9971002f578e7978
>
> NeilBrown

Yes, the nfsd is from april this year, so i think you're right.

-rwxr-xr-x. 1 root root 19960 Apr 20 19:21 /usr/sbin/rpc.nfsd

nfs-utils-1.2.3-7.el6.x86_64

I wil try to find a solution. Thank you for the information.

Greetings .. Richard
