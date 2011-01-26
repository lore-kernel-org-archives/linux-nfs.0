Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:24146 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858Ab1AZPfl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jan 2011 10:35:41 -0500
Subject: Re: Cross-compiling nfs-utils 1.1.4 for ARM
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4D3F7DBE.9030804@RedHat.com>
Date: Wed, 26 Jan 2011 10:34:16 -0500
Cc: Patrick Dignan <pdignan@nvidia.com>, Kevin Coffman <kwc@citi.umich.edu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <9EE9BD4A-97D5-4E21-80E4-D2F79DBB7E23@oracle.com>
References: <4D3DF9FD.1050800@nvidia.com>	<4D3EC8DC.602@RedHat.com>	<4D3F2AE8.3010303@nvidia.com> <AANLkTi=tnLVwgYgPBgc=BrD5jAbqH7JfMhxOecc7K8cm@mail.gmail.com> <4D3F4DFF.6030808@nvidia.com> <92B00E1A-FBB1-467F-BBBD-63ACAC7C32ED@oracle.com> <4D3F7DBE.9030804@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jan 25, 2011, at 8:49 PM, Steve Dickson wrote:

> 
> 
> On 01/25/2011 05:44 PM, Chuck Lever wrote:
>> 
>> On Jan 25, 2011, at 5:26 PM, Patrick Dignan wrote:
>> 
>>> On 01/25/2011 12:32 PM, Kevin Coffman wrote:
>>>> On Tue, Jan 25, 2011 at 2:56 PM, Patrick Dignan<pdignan@nvidia.com>  wrote:
>>>>> On 01/25/2011 04:58 AM, Steve Dickson wrote:
>>>>>> On 01/24/2011 05:15 PM, Patrick Dignan wrote:
>>>>>>> Hi,
>>>>>>> 
>>>>>>> I'm attempting to cross-compile nfs-utils 1.1.4 for ARM on an x86_64
>>>>>>> build machine.  I can cross-compile other software, but nfs-utils fails.  I
>>>>>>> get the following error:
>>>>>>> 
>>>>>>> gcc -DHAVE_CONFIG_H -I. -I../../support/include  -D_GNU_SOURCE
>>>>>>> -D_GNU_SOURCE  -O2 -pipe -I/build/tegra2_seaboard/usr/include/
>>>>>>> -I/build/tegra2_seaboard/include/ -ggdb -march=armv7-a -mtune=cortex-a8
>>>>>>> -mfpu=vfpv3-d16 -mfloat-abi=softfp -MT testlk-testlk.o -MD -MP -MF
>>>>>>> .deps/testlk-testlk.Tpo -c -o testlk-testlk.o `test -f 'testlk.c' || echo
>>>>>>> './'`testlk.c
>>>>>>> cc1: error: unrecognized command line option "-mfpu=vfpv3-d16"
>>>>>>> cc1: error: unrecognized command line option "-mfloat-abi=softfp"
>>>>>>> testlk.c:1: error: bad value (armv7-a) for -march= switch
>>>>>>> testlk.c:1: error: bad value (cortex-a8) for -mtune= switch
>>>>>>> 
>>>>>>> I'm guessing there's some sort of problem in Makefile.am that's causing
>>>>>>> it to fail, but I am not sure what changes I need to make.  Does anyone know
>>>>>>> the solution to this problem or where I might start looking to fix this?
>>>>>> My guess would be your cross-compiler is added those to the CFLAGS because
>>>>>> those flags are not set on a "normal" compilation...
>>>>>> 
>>>>>> steved.
>>>>>> 
>>>>>>> Best,
>>>>>>> 
>>>>>>> Patrick Dignan
>>>>> I believe you are correct, however I think it should be using the ARM
>>>>> specific compiler when trying to cross-compile.  I don't know enough about
>>>>> automake and cross-compiling to be sure, but I think that it doesn't set the
>>>>> CC variable correctly.  It does seem to configure correctly though, since it
>>>>> shows the proper compiler being found: "checking for
>>>>> armv7a-cros-linux-gnueabi-gcc... (cached) armv7a-cros-linux-gnueabi-gcc",
>>>>> but then it uses the normal gcc.
>>>>> 
>>>>> Thanks for the help!
>>>>> 
>>>>> Best,
>>>>> 
>>>>> Patrick Dignan
>>>> This is just a guess, but I'm suspicious of these lines in
>>>> tools/locktest/Makefile.am:
>>>> 
>>>> CC=$(CC_FOR_BUILD)
>>>> LIBTOOL = @LIBTOOL@ --tag=CC
>>>> 
>>>> This might have been an oversite when the original conversion to
>>>> automake was done.  What happens if you comment those lines out (and
>>>> then re-run autogen.sh)?  Note that Makefile.am for rpcgen and
>>>> rpcdebug also have these lines, but they may not need to be built when
>>>> cross-compiling?
>> 
>> When all is said and done, rpcgen needs to run on the build host, not on the target.
>> I thought this was here for building on platforms that don't have rpcgen installed...
>> (I think we should consider removing rpcgen from nfs-utils, in favor of requiring 
>> the officially installed rpcgen to be available).
>> 
>> Does nfs-utils actually install rpcgen on the target?  If it does, then ignore me.
> Good question... 
> 
> It turns out that rpcgen will be built and installed if the --with-rpcgen=internal
> configure flag is set which is not set in the Red Hat distros... 
> 
> This means, when nfs-utils is built on a Red Hat distros, the /usr/bin/rpcgen 
> command is used which is a part of the glibc-common package...
> 
> So I guess the suggestion is to remove the rpcgen bits from nfs-utils
> and use the ones from glibc-common which I am not against but this
> really need to be a community wide decision... IMHO... 

Agreed.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




