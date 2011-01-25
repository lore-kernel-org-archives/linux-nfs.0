Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.121.140]:3279 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753133Ab1AYT4P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jan 2011 14:56:15 -0500
Message-ID: <4D3F2AE8.3010303@nvidia.com>
Date: Tue, 25 Jan 2011 11:56:24 -0800
From: Patrick Dignan <pdignan@nvidia.com>
To: Steve Dickson <SteveD@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Cross-compiling nfs-utils 1.1.4 for ARM
References: <4D3DF9FD.1050800@nvidia.com> <4D3EC8DC.602@RedHat.com>
In-Reply-To: <4D3EC8DC.602@RedHat.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 01/25/2011 04:58 AM, Steve Dickson wrote:
>
> On 01/24/2011 05:15 PM, Patrick Dignan wrote:
>> Hi,
>>
>> I'm attempting to cross-compile nfs-utils 1.1.4 for ARM on an x86_64 build machine.  I can cross-compile other software, but nfs-utils fails.  I get the following error:
>>
>> gcc -DHAVE_CONFIG_H -I. -I../../support/include  -D_GNU_SOURCE -D_GNU_SOURCE  -O2 -pipe -I/build/tegra2_seaboard/usr/include/ -I/build/tegra2_seaboard/include/ -ggdb -march=armv7-a -mtune=cortex-a8 -mfpu=vfpv3-d16 -mfloat-abi=softfp -MT testlk-testlk.o -MD -MP -MF .deps/testlk-testlk.Tpo -c -o testlk-testlk.o `test -f 'testlk.c' || echo './'`testlk.c
>> cc1: error: unrecognized command line option "-mfpu=vfpv3-d16"
>> cc1: error: unrecognized command line option "-mfloat-abi=softfp"
>> testlk.c:1: error: bad value (armv7-a) for -march= switch
>> testlk.c:1: error: bad value (cortex-a8) for -mtune= switch
>>
>> I'm guessing there's some sort of problem in Makefile.am that's causing it to fail, but I am not sure what changes I need to make.  Does anyone know the solution to this problem or where I might start looking to fix this?
> My guess would be your cross-compiler is added those to the CFLAGS because
> those flags are not set on a "normal" compilation...
>
> steved.
>
>> Best,
>>
>> Patrick Dignan
>>
>> -----------------------------------------------------------------------------------
>> This email message is for the sole use of the intended recipient(s) and may contain
>> confidential information.  Any unauthorized review, use, disclosure or distribution
>> is prohibited.  If you are not the intended recipient, please contact the sender by
>> reply email and destroy all copies of the original message.
>> -----------------------------------------------------------------------------------
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
I believe you are correct, however I think it should be using the ARM 
specific compiler when trying to cross-compile.  I don't know enough 
about automake and cross-compiling to be sure, but I think that it 
doesn't set the CC variable correctly.  It does seem to configure 
correctly though, since it shows the proper compiler being found: 
"checking for armv7a-cros-linux-gnueabi-gcc... (cached) 
armv7a-cros-linux-gnueabi-gcc", but then it uses the normal gcc.

Thanks for the help!

Best,

Patrick Dignan

