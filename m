From: Benny Halevy <bhalevy@tonian.com>
Subject: Re: Unable to Compile Latest Kernel from Git
Date: Thu, 11 Aug 2011 15:17:14 +0300
Message-ID: <4E43C84A.1060402@tonian.com>
References: <CALPVbefsY4Ddw6QOZu9BckCx+Q0YJg8tgbjK6xN5sQxbpdD16w@mail.gmail.com> <CAN-5tyEmCx+1quj+545zDZ1ueQRVhHGgDzhdjZ1K1h6hCjOJvw@mail.gmail.com> <4E40F53A.2080303@tonian.com> <CALPVbedY4WV=Bsqr8Z0JUeYgrgVGLFc-NYdxJfewUAO0bJpR8A@mail.gmail.com> <4E42C9D3.2070006@netapp.com> <4E42CDF3.6090708@panasas.com> <CALPVbecSxKKbzo_CQqb075cZhiD5kOG7Aao71=cwktK1dSU2Zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Cc: Boaz Harrosh <bharrosh@panasas.com>,
	Bryan Schumaker <bjschuma@netapp.com>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	linux-nfs@vger.kernel.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Billy Hass <billdh16@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56282 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754127Ab1HKMRX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 08:17:23 -0400
In-Reply-To: <CALPVbecSxKKbzo_CQqb075cZhiD5kOG7Aao71=cwktK1dSU2Zg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-08-10 22:05, Billy Hass wrote:
> On Wed, Aug 10, 2011 at 2:29 PM, Boaz Harrosh <bharrosh@panasas.com> =
wrote:
>> On 08/10/2011 11:11 AM, Bryan Schumaker wrote:
>>> On 08/10/2011 01:29 PM, Billy Hass wrote:
>>>> [root@pdsi8 linux-pnfs]# make modules && make modules_install && m=
ake install
>>>>   CHK     include/linux/version.h
>>>>   CHK     include/generated/utsrelease.h
>>>>   CALL    scripts/checksyscalls.sh
>>>>   CC [M]  fs/xfs/linux-2.6/xfs_iops.o
>>>> fs/xfs/linux-2.6/xfs_iops.c: In function =91_xfs_vn_fallocate=92:
>>>> fs/xfs/linux-2.6/xfs_iops.c:1070:3: error: implicit declaration of
>>>> function =91xfs_setattr=92 [-Werror=3Dimplicit-function-declaratio=
n]
>>>> cc1: some warnings being treated as errors
>>>> make[2]: *** [fs/xfs/linux-2.6/xfs_iops.o] Error 1
>>>> make[1]: *** [fs/xfs] Error 2
>>>> make: *** [fs] Error 2
>>>
>>> This looks like an XFS problem now... did you see if any of the NFS=
 code compiled this time?
>>>
>>> I've had these issues before, and it's usually caused by something =
in my .config.  Generating a new one usually fixes it for me.
>>>
>>> - Bryan
>>>
>>
>> Please try v3.1-rc1 (git checkout v3.1-rc1) if it persists I'm sure =
the xfs guys
>> would like to fix it.
>>
>> Send this report with an attached .config file to:
>>        linux-fsdevel <linux-fsdevel@vger.kernel.org>
>>
>> Thanks
>> Boaz
>>
>=20
> I tried v3.1-rc1 and it compiled successfully.
>=20
> Thanks for the help.
> --

The problem was a bad merge/rebase on my side.
Should be fixed now.

Thanks for reporting!

Benny
