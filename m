From: Billy Hass <billdh16@gmail.com>
Subject: Re: Unable to Compile Latest Kernel from Git
Date: Wed, 10 Aug 2011 15:05:02 -0400
Message-ID: <CALPVbecSxKKbzo_CQqb075cZhiD5kOG7Aao71=cwktK1dSU2Zg@mail.gmail.com>
References: <CALPVbefsY4Ddw6QOZu9BckCx+Q0YJg8tgbjK6xN5sQxbpdD16w@mail.gmail.com>
	<CAN-5tyEmCx+1quj+545zDZ1ueQRVhHGgDzhdjZ1K1h6hCjOJvw@mail.gmail.com>
	<4E40F53A.2080303@tonian.com>
	<CALPVbedY4WV=Bsqr8Z0JUeYgrgVGLFc-NYdxJfewUAO0bJpR8A@mail.gmail.com>
	<4E42C9D3.2070006@netapp.com>
	<4E42CDF3.6090708@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Cc: Bryan Schumaker <bjschuma@netapp.com>,
	Benny Halevy <bhalevy@tonian.com>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	linux-nfs@vger.kernel.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:41470 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753890Ab1HJTFE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2011 15:05:04 -0400
In-Reply-To: <4E42CDF3.6090708@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 10, 2011 at 2:29 PM, Boaz Harrosh <bharrosh@panasas.com> wr=
ote:
> On 08/10/2011 11:11 AM, Bryan Schumaker wrote:
>> On 08/10/2011 01:29 PM, Billy Hass wrote:
>>> [root@pdsi8 linux-pnfs]# make modules && make modules_install && ma=
ke install
>>> =A0 CHK =A0 =A0 include/linux/version.h
>>> =A0 CHK =A0 =A0 include/generated/utsrelease.h
>>> =A0 CALL =A0 =A0scripts/checksyscalls.sh
>>> =A0 CC [M] =A0fs/xfs/linux-2.6/xfs_iops.o
>>> fs/xfs/linux-2.6/xfs_iops.c: In function =91_xfs_vn_fallocate=92:
>>> fs/xfs/linux-2.6/xfs_iops.c:1070:3: error: implicit declaration of
>>> function =91xfs_setattr=92 [-Werror=3Dimplicit-function-declaration=
]
>>> cc1: some warnings being treated as errors
>>> make[2]: *** [fs/xfs/linux-2.6/xfs_iops.o] Error 1
>>> make[1]: *** [fs/xfs] Error 2
>>> make: *** [fs] Error 2
>>
>> This looks like an XFS problem now... did you see if any of the NFS =
code compiled this time?
>>
>> I've had these issues before, and it's usually caused by something i=
n my .config. =A0Generating a new one usually fixes it for me.
>>
>> - Bryan
>>
>
> Please try v3.1-rc1 (git checkout v3.1-rc1) if it persists I'm sure t=
he xfs guys
> would like to fix it.
>
> Send this report with an attached .config file to:
> =A0 =A0 =A0 =A0linux-fsdevel <linux-fsdevel@vger.kernel.org>
>
> Thanks
> Boaz
>

I tried v3.1-rc1 and it compiled successfully.

Thanks for the help.
