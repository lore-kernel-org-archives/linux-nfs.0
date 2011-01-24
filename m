Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.121.140]:16458 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107Ab1AXWPZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Jan 2011 17:15:25 -0500
Message-ID: <4D3DF9FD.1050800@nvidia.com>
Date: Mon, 24 Jan 2011 14:15:25 -0800
From: Patrick Dignan <pdignan@nvidia.com>
To: <linux-nfs@vger.kernel.org>
Subject: Cross-compiling nfs-utils 1.1.4 for ARM
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I'm attempting to cross-compile nfs-utils 1.1.4 for ARM on an x86_64 
build machine.  I can cross-compile other software, but nfs-utils 
fails.  I get the following error:

gcc -DHAVE_CONFIG_H -I. -I../../support/include  -D_GNU_SOURCE 
-D_GNU_SOURCE  -O2 -pipe -I/build/tegra2_seaboard/usr/include/ 
-I/build/tegra2_seaboard/include/ -ggdb -march=armv7-a -mtune=cortex-a8 
-mfpu=vfpv3-d16 -mfloat-abi=softfp -MT testlk-testlk.o -MD -MP -MF 
.deps/testlk-testlk.Tpo -c -o testlk-testlk.o `test -f 'testlk.c' || 
echo './'`testlk.c
cc1: error: unrecognized command line option "-mfpu=vfpv3-d16"
cc1: error: unrecognized command line option "-mfloat-abi=softfp"
testlk.c:1: error: bad value (armv7-a) for -march= switch
testlk.c:1: error: bad value (cortex-a8) for -mtune= switch

I'm guessing there's some sort of problem in Makefile.am that's causing 
it to fail, but I am not sure what changes I need to make.  Does anyone 
know the solution to this problem or where I might start looking to fix 
this?

Best,

Patrick Dignan

-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
