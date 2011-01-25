Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.121.140]:3311 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936Ab1AYWZ5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jan 2011 17:25:57 -0500
Message-ID: <4D3F4DFF.6030808@nvidia.com>
Date: Tue, 25 Jan 2011 14:26:07 -0800
From: Patrick Dignan <pdignan@nvidia.com>
To: Kevin Coffman <kwc@citi.umich.edu>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Cross-compiling nfs-utils 1.1.4 for ARM
References: <4D3DF9FD.1050800@nvidia.com>	<4D3EC8DC.602@RedHat.com>	<4D3F2AE8.3010303@nvidia.com> <AANLkTi=tnLVwgYgPBgc=BrD5jAbqH7JfMhxOecc7K8cm@mail.gmail.com>
In-Reply-To: <AANLkTi=tnLVwgYgPBgc=BrD5jAbqH7JfMhxOecc7K8cm@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 01/25/2011 12:32 PM, Kevin Coffman wrote:
> On Tue, Jan 25, 2011 at 2:56 PM, Patrick Dignan<pdignan@nvidia.com>  wrote:
>> On 01/25/2011 04:58 AM, Steve Dickson wrote:
>>> On 01/24/2011 05:15 PM, Patrick Dignan wrote:
>>>> Hi,
>>>>
>>>> I'm attempting to cross-compile nfs-utils 1.1.4 for ARM on an x86_64
>>>> build machine.  I can cross-compile other software, but nfs-utils fails.  I
>>>> get the following error:
>>>>
>>>> gcc -DHAVE_CONFIG_H -I. -I../../support/include  -D_GNU_SOURCE
>>>> -D_GNU_SOURCE  -O2 -pipe -I/build/tegra2_seaboard/usr/include/
>>>> -I/build/tegra2_seaboard/include/ -ggdb -march=armv7-a -mtune=cortex-a8
>>>> -mfpu=vfpv3-d16 -mfloat-abi=softfp -MT testlk-testlk.o -MD -MP -MF
>>>> .deps/testlk-testlk.Tpo -c -o testlk-testlk.o `test -f 'testlk.c' || echo
>>>> './'`testlk.c
>>>> cc1: error: unrecognized command line option "-mfpu=vfpv3-d16"
>>>> cc1: error: unrecognized command line option "-mfloat-abi=softfp"
>>>> testlk.c:1: error: bad value (armv7-a) for -march= switch
>>>> testlk.c:1: error: bad value (cortex-a8) for -mtune= switch
>>>>
>>>> I'm guessing there's some sort of problem in Makefile.am that's causing
>>>> it to fail, but I am not sure what changes I need to make.  Does anyone know
>>>> the solution to this problem or where I might start looking to fix this?
>>> My guess would be your cross-compiler is added those to the CFLAGS because
>>> those flags are not set on a "normal" compilation...
>>>
>>> steved.
>>>
>>>> Best,
>>>>
>>>> Patrick Dignan
>> I believe you are correct, however I think it should be using the ARM
>> specific compiler when trying to cross-compile.  I don't know enough about
>> automake and cross-compiling to be sure, but I think that it doesn't set the
>> CC variable correctly.  It does seem to configure correctly though, since it
>> shows the proper compiler being found: "checking for
>> armv7a-cros-linux-gnueabi-gcc... (cached) armv7a-cros-linux-gnueabi-gcc",
>> but then it uses the normal gcc.
>>
>> Thanks for the help!
>>
>> Best,
>>
>> Patrick Dignan
> This is just a guess, but I'm suspicious of these lines in
> tools/locktest/Makefile.am:
>
> CC=$(CC_FOR_BUILD)
> LIBTOOL = @LIBTOOL@ --tag=CC
>
> This might have been an oversite when the original conversion to
> automake was done.  What happens if you comment those lines out (and
> then re-run autogen.sh)?  Note that Makefile.am for rpcgen and
> rpcdebug also have these lines, but they may not need to be built when
> cross-compiling?
>
> K.C.
Hi Kevin,

You're absolutely right.  After I removed those lines from 
tools/locktest/Makefile.am, tools/rpcdebug/Makefile.am, and 
tools/rpcgen/Makefile.am the compile worked successfully.

Thanks for the help!

Here's the patch.  I haven't tested it yet, but it allowed me to compile 
nfs-utils, so it may at least help others out.

Best,

Patrick Dignan

diff -Naurb nfs-utils-1.1.4.orig/tools/locktest/Makefile.am 
nfs-utils-1.1.4.mod/tools/locktest/Makefile.am
--- nfs-utils-1.1.4.orig/tools/locktest/Makefile.am    2008-10-17 
07:20:09.000000000 -0700
+++ nfs-utils-1.1.4.mod/tools/locktest/Makefile.am    2011-01-25 
13:43:13.166298908 -0800
@@ -1,8 +1,5 @@
  ## Process this file with automake to produce Makefile.in

-CC=$(CC_FOR_BUILD)
-LIBTOOL = @LIBTOOL@ --tag=CC
-
  noinst_PROGRAMS = testlk
  testlk_SOURCES = testlk.c
  testlk_CFLAGS=$(CFLAGS_FOR_BUILD)
diff -Naurb nfs-utils-1.1.4.orig/tools/rpcdebug/Makefile.am 
nfs-utils-1.1.4.mod/tools/rpcdebug/Makefile.am
--- nfs-utils-1.1.4.orig/tools/rpcdebug/Makefile.am    2008-10-17 
07:20:09.000000000 -0700
+++ nfs-utils-1.1.4.mod/tools/rpcdebug/Makefile.am    2011-01-25 
13:43:23.567549833 -0800
@@ -1,8 +1,5 @@
  ## Process this file with automake to produce Makefile.in

-CC=$(CC_FOR_BUILD)
-LIBTOOL = @LIBTOOL@ --tag=CC
-
  man8_MANS = rpcdebug.man
  EXTRA_DIST = $(man8_MANS)

diff -Naurb nfs-utils-1.1.4.orig/tools/rpcgen/Makefile.am 
nfs-utils-1.1.4.mod/tools/rpcgen/Makefile.am
--- nfs-utils-1.1.4.orig/tools/rpcgen/Makefile.am    2008-10-17 
07:20:09.000000000 -0700
+++ nfs-utils-1.1.4.mod/tools/rpcgen/Makefile.am    2011-01-25 
13:43:34.836298823 -0800
@@ -1,8 +1,5 @@
  ## Process this file with automake to produce Makefile.in

-CC=$(CC_FOR_BUILD)
-LIBTOOL = @LIBTOOL@ --tag=CC
-
  noinst_PROGRAMS = rpcgen
  rpcgen_SOURCES = rpc_clntout.c rpc_cout.c rpc_hout.c rpc_main.c \
                  rpc_parse.c rpc_scan.c rpc_svcout.c rpc_tblout.c \



-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
