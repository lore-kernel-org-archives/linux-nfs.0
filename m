Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:40512 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755995AbeEaSBm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 31 May 2018 14:01:42 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: nfs-utils-2.3.2: glitch crashes build
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <e4ad8b72-1165-619a-3e2d-815ed65112b1@RedHat.com>
Date: Thu, 31 May 2018 13:22:25 -0400
Cc: gabriele balducci <balducci@units.it>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <5325B967-2A98-461D-9F58-F48E76F367AB@oracle.com>
References: <11745.1527438384@dschgrazlin2.units.it>
 <965f2a16-dc1e-39e0-80f8-f55166a5106e@RedHat.com>
 <83B1E5B4-6B7E-47B6-965D-4C49BEA15C8F@oracle.com>
 <5a7c1a19-9ca7-6f8e-5b5d-64324290cf79@RedHat.com>
 <7653539C-F184-441F-A827-0F2F7F7C7FE5@oracle.com>
 <e4ad8b72-1165-619a-3e2d-815ed65112b1@RedHat.com>
To: Steve Dickson <SteveD@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 31, 2018, at 1:01 PM, Steve Dickson <SteveD@RedHat.com> wrote:
>=20
>=20
>=20
> On 05/31/2018 12:48 PM, Chuck Lever wrote:
>>=20
>>=20
>>> On May 31, 2018, at 12:40 PM, Steve Dickson <SteveD@RedHat.com> =
wrote:
>>>=20
>>>=20
>>>=20
>>> On 05/31/2018 12:14 PM, Chuck Lever wrote:
>>>>=20
>>>>=20
>>>>> On May 31, 2018, at 11:13 AM, Steve Dickson <SteveD@RedHat.com> =
wrote:
>>>>>=20
>>>>> Hello gabriele
>>>>>=20
>>>>> I wonder why I am not seeing these warnings...=20
>>>>=20
>>>> fwiw, upstream nfs-utils no longer builds on RHEL 7 latest.
>>>> The recent commit that turned some compiler warnings into
>>>> errors causes a bunch of build failures on that platform.
>>> Yeah I know....
>>=20
>> Cool, this was just an fyi.
> Question what gcc are you using?=20
>=20
> The one I'm using 'gcc-4.8.5 does not support
> checking whether CC supports -Werror=3Dformat-overflow=3D2... no
> checking whether CC supports -Werror=3Dint-conversion... no
> checking whether CC supports -Werror=3Dincompatible-pointer-types... =
no
> checking whether CC supports -Werror=3Dmisleading-indentation... no

Neighborhood power outage today, so no access to my lab
systems. I don't believe I have a special version of gcc.

However, here's my build script:

142         /usr/bin/make distclean
143         /bin/sh autogen.sh
144         ./configure \
145                 CFLAGS=3D"-D_FILE_OFFSET_BITS=3D64 =
-Wp,-D_FORTIFY_SOURCE=3D2 \
146                 -Os -Wall -Wextra -pedantic -std=3Dc99 \
147                 -Wformat=3D2 -Wmissing-include-dirs \
148                 -Wunused -Wconversion -Wlogical-op \
149                 -Wmissing-prototypes -Wmissing-declarations =
-Wstrict-prototypes \
150                 -Wmissing-noreturn -Wshadow \
151                 -Wunreachable-code -Winline -Wdisabled-optimization =
\
152                 -Wstrict-aliasing=3D2 -Wstrict-overflow=3D4 =
-Wstack-protector \
153                 -fstrict-aliasing -fstrict-overflow \
154                 -fexceptions -fstack-protector \
155                 -fasynchronous-unwind-tables -fpie" \
156                 LDFLAGS=3D"-pie" \
157                 --enable-uuid --enable-mount --enable-nfsv4 =
--enable-gss \
158                 --enable-mountconfig =
--with-statdpath=3D/var/lib/nfs/statd \
159                 --enable-nfsdcltrack --enable-tirpc --enable-ipv6

It's possible I've got something enabled that is
triggering heartburn.

I seem to recall I removed "-pedantic -std=3Dc99" and
still had some problems, but I could be misremembering.


> steved.
>>=20
>>=20
>>> It was suggested to me by some glibc
>>> guys.... I figured there would be some pain....=20
>>>=20
>>> I'll looking the rhel7 issue..=20
>>>=20
>>> steved.
>>>=20
>>>>=20
>>>> In particular, %m is not portable, and it is used all over
>>>> in xlog, printf, and scanf formatting strings.
>>>>=20
>>>>=20
>>>>> Thank you very much for the patch... Would you
>>>>> mind if I added a=20
>>>>> Signed-off-by: gabriele balducci <balducci@units.it>
>>>>>=20
>>>>> to the official patch?=20
>>>>>=20
>>>>> steved.
>>>>> On 05/27/2018 12:26 PM, gabriele balducci wrote:
>>>>>> hello
>>>>>>=20
>>>>>> building 2.3.2 fails with:
>>>>>>=20
>>>>>> mountd.c:706:3: note: 'sprintf' output between 6 and 16 bytes =
into a destination of size 10
>>>>>>   sprintf(tag, "vers%d", vers);
>>>>>>   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
>>>>>> cc1: some warnings being treated as errors
>>>>>>=20
>>>>>> and
>>>>>>=20
>>>>>> nfsd.c:102:3: note: 'sprintf' output between 6 and 16 bytes into =
a destination of size 10
>>>>>>   sprintf(tag, "vers%d", i);
>>>>>>   ^~~~~~~~~~~~~~~~~~~~~~~~~
>>>>>> cc1: some warnings being treated as errors
>>>>>>=20
>>>>>> I guess the reason is =
(https://marc.info/?l=3Dlinux-nfs&m=3D152718306728854&w=3D2):
>>>>>>=20
>>>>>>  * Most compile warnings are now fatal errors.
>>>>>>=20
>>>>>> and (configure):
>>>>>>=20
>>>>>> checking whether CC supports -Werror=3Dformat-overflow=3D2... yes
>>>>>>=20
>>>>>> This fixes everything for me:
>>>>>>=20
>>>>>> diff -c utils/mountd/mountd.c.FIX_VAR_DIM utils/mountd/mountd.c
>>>>>> *** utils/mountd/mountd.c.FIX_VAR_DIM	Sun May 27 18:16:46 2018
>>>>>> --- utils/mountd/mountd.c	Sun May 27 18:16:46 2018
>>>>>> ***************
>>>>>> *** 702,708 ****
>>>>>>        else
>>>>>>                NFSCTL_TCPUNSET(_rpcprotobits);
>>>>>>        for (vers =3D 2; vers <=3D 4; vers++) {
>>>>>> ! 		char tag[10];
>>>>>>                sprintf(tag, "vers%d", vers);
>>>>>>                if (conf_get_bool("nfsd", tag, =
NFSCTL_VERISSET(nfs_version, vers)))
>>>>>>                        NFSCTL_VERSET(nfs_version, vers);
>>>>>> --- 702,708 ----
>>>>>>        else
>>>>>>                NFSCTL_TCPUNSET(_rpcprotobits);
>>>>>>        for (vers =3D 2; vers <=3D 4; vers++) {
>>>>>> ! 		char tag[20];
>>>>>>                sprintf(tag, "vers%d", vers);
>>>>>>                if (conf_get_bool("nfsd", tag, =
NFSCTL_VERISSET(nfs_version, vers)))
>>>>>>                        NFSCTL_VERSET(nfs_version, vers);
>>>>>>=20
>>>>>>=20
>>>>>>=20
>>>>>> diff -c utils/nfsd/nfsd.c.FIX_VAR_DIM utils/nfsd/nfsd.c
>>>>>> *** utils/nfsd/nfsd.c.FIX_VAR_DIM	Sun May 27 18:16:46 2018
>>>>>> --- utils/nfsd/nfsd.c	Sun May 27 18:16:46 2018
>>>>>> ***************
>>>>>> *** 98,104 ****
>>>>>>        else
>>>>>>                NFSCTL_TCPUNSET(protobits);
>>>>>>        for (i =3D 2; i <=3D 4; i++) {
>>>>>> ! 		char tag[10];
>>>>>>                sprintf(tag, "vers%d", i);
>>>>>>                if (conf_get_bool("nfsd", tag, =
NFSCTL_VERISSET(versbits, i)))
>>>>>>                        NFSCTL_VERSET(versbits, i);
>>>>>> --- 98,104 ----
>>>>>>        else
>>>>>>                NFSCTL_TCPUNSET(protobits);
>>>>>>        for (i =3D 2; i <=3D 4; i++) {
>>>>>> ! 		char tag[20];
>>>>>>                sprintf(tag, "vers%d", i);
>>>>>>                if (conf_get_bool("nfsd", tag, =
NFSCTL_VERISSET(versbits, i)))
>>>>>>                        NFSCTL_VERSET(versbits, i);
>>>>>>=20
>>>>>>=20
>>>>>> I thought the maintainers might be interested in fixing upstream
>>>>>>=20
>>>>>> ciao
>>>>>> gabriele
>>>>>> --
>>>>>> To unsubscribe from this list: send the line "unsubscribe =
linux-nfs" in
>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at  =
http://vger.kernel.org/majordomo-info.html
>>>>>>=20
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe =
linux-nfs" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>=20
>>>> --
>>>> Chuck Lever
>>>>=20
>>>>=20
>>>>=20
>>=20
>> --
>> Chuck Lever
>>=20
>>=20
>>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



