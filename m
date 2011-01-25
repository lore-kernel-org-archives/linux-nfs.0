Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21485 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751281Ab1AYM6H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Jan 2011 07:58:07 -0500
Message-ID: <4D3EC8DC.602@RedHat.com>
Date: Tue, 25 Jan 2011 07:58:04 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Patrick Dignan <pdignan@nvidia.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Cross-compiling nfs-utils 1.1.4 for ARM
References: <4D3DF9FD.1050800@nvidia.com>
In-Reply-To: <4D3DF9FD.1050800@nvidia.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 01/24/2011 05:15 PM, Patrick Dignan wrote:
> Hi,
> 
> I'm attempting to cross-compile nfs-utils 1.1.4 for ARM on an x86_64 build machine.  I can cross-compile other software, but nfs-utils fails.  I get the following error:
> 
> gcc -DHAVE_CONFIG_H -I. -I../../support/include  -D_GNU_SOURCE -D_GNU_SOURCE  -O2 -pipe -I/build/tegra2_seaboard/usr/include/ -I/build/tegra2_seaboard/include/ -ggdb -march=armv7-a -mtune=cortex-a8 -mfpu=vfpv3-d16 -mfloat-abi=softfp -MT testlk-testlk.o -MD -MP -MF .deps/testlk-testlk.Tpo -c -o testlk-testlk.o `test -f 'testlk.c' || echo './'`testlk.c
> cc1: error: unrecognized command line option "-mfpu=vfpv3-d16"
> cc1: error: unrecognized command line option "-mfloat-abi=softfp"
> testlk.c:1: error: bad value (armv7-a) for -march= switch
> testlk.c:1: error: bad value (cortex-a8) for -mtune= switch
> 
> I'm guessing there's some sort of problem in Makefile.am that's causing it to fail, but I am not sure what changes I need to make.  Does anyone know the solution to this problem or where I might start looking to fix this?
My guess would be your cross-compiler is added those to the CFLAGS because
those flags are not set on a "normal" compilation... 

steved.

> 
> Best,
> 
> Patrick Dignan
> 
> -----------------------------------------------------------------------------------
> This email message is for the sole use of the intended recipient(s) and may contain
> confidential information.  Any unauthorized review, use, disclosure or distribution
> is prohibited.  If you are not the intended recipient, please contact the sender by
> reply email and destroy all copies of the original message.
> -----------------------------------------------------------------------------------
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
