From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: Unable to Compile Latest Kernel from Git
Date: Wed, 10 Aug 2011 11:29:07 -0700
Message-ID: <4E42CDF3.6090708@panasas.com>
References: <CALPVbefsY4Ddw6QOZu9BckCx+Q0YJg8tgbjK6xN5sQxbpdD16w@mail.gmail.com> <CAN-5tyEmCx+1quj+545zDZ1ueQRVhHGgDzhdjZ1K1h6hCjOJvw@mail.gmail.com> <4E40F53A.2080303@tonian.com> <CALPVbedY4WV=Bsqr8Z0JUeYgrgVGLFc-NYdxJfewUAO0bJpR8A@mail.gmail.com> <4E42C9D3.2070006@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Billy Hass <billdh16@gmail.com>, Benny Halevy <bhalevy@tonian.com>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	<linux-nfs@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4E42C9D3.2070006@netapp.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/10/2011 11:11 AM, Bryan Schumaker wrote:
> On 08/10/2011 01:29 PM, Billy Hass wrote:
>> [root@pdsi8 linux-pnfs]# make modules && make modules_install && mak=
e install
>>   CHK     include/linux/version.h
>>   CHK     include/generated/utsrelease.h
>>   CALL    scripts/checksyscalls.sh
>>   CC [M]  fs/xfs/linux-2.6/xfs_iops.o
>> fs/xfs/linux-2.6/xfs_iops.c: In function =E2=80=98_xfs_vn_fallocate=E2=
=80=99:
>> fs/xfs/linux-2.6/xfs_iops.c:1070:3: error: implicit declaration of
>> function =E2=80=98xfs_setattr=E2=80=99 [-Werror=3Dimplicit-function-=
declaration]
>> cc1: some warnings being treated as errors
>> make[2]: *** [fs/xfs/linux-2.6/xfs_iops.o] Error 1
>> make[1]: *** [fs/xfs] Error 2
>> make: *** [fs] Error 2
>=20
> This looks like an XFS problem now... did you see if any of the NFS c=
ode compiled this time?
>=20
> I've had these issues before, and it's usually caused by something in=
 my .config.  Generating a new one usually fixes it for me.
>=20
> - Bryan
>=20

Please try v3.1-rc1 (git checkout v3.1-rc1) if it persists I'm sure the=
 xfs guys
would like to fix it.

Send this report with an attached .config file to:
	linux-fsdevel <linux-fsdevel@vger.kernel.org>

Thanks
Boaz
--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
