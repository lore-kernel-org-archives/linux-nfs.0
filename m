Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:33638 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755609AbeEaQOi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 31 May 2018 12:14:38 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: nfs-utils-2.3.2: glitch crashes build
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <965f2a16-dc1e-39e0-80f8-f55166a5106e@RedHat.com>
Date: Thu, 31 May 2018 12:14:17 -0400
Cc: gabriele balducci <balducci@units.it>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <83B1E5B4-6B7E-47B6-965D-4C49BEA15C8F@oracle.com>
References: <11745.1527438384@dschgrazlin2.units.it>
 <965f2a16-dc1e-39e0-80f8-f55166a5106e@RedHat.com>
To: Steve Dickson <SteveD@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 31, 2018, at 11:13 AM, Steve Dickson <SteveD@RedHat.com> wrote:
>=20
> Hello gabriele
>=20
> I wonder why I am not seeing these warnings...=20

fwiw, upstream nfs-utils no longer builds on RHEL 7 latest.
The recent commit that turned some compiler warnings into
errors causes a bunch of build failures on that platform.

In particular, %m is not portable, and it is used all over
in xlog, printf, and scanf formatting strings.


> Thank you very much for the patch... Would you
> mind if I added a=20
>   Signed-off-by: gabriele balducci <balducci@units.it>
>=20
> to the official patch?=20
>=20
> steved.
> On 05/27/2018 12:26 PM, gabriele balducci wrote:
>> hello
>>=20
>> building 2.3.2 fails with:
>>=20
>>  mountd.c:706:3: note: 'sprintf' output between 6 and 16 bytes into a =
destination of size 10
>>     sprintf(tag, "vers%d", vers);
>>     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
>>  cc1: some warnings being treated as errors
>>=20
>> and
>>=20
>>  nfsd.c:102:3: note: 'sprintf' output between 6 and 16 bytes into a =
destination of size 10
>>     sprintf(tag, "vers%d", i);
>>     ^~~~~~~~~~~~~~~~~~~~~~~~~
>>  cc1: some warnings being treated as errors
>>=20
>> I guess the reason is =
(https://marc.info/?l=3Dlinux-nfs&m=3D152718306728854&w=3D2):
>>=20
>>    * Most compile warnings are now fatal errors.
>>=20
>> and (configure):
>>=20
>>  checking whether CC supports -Werror=3Dformat-overflow=3D2... yes
>>=20
>> This fixes everything for me:
>>=20
>>  diff -c utils/mountd/mountd.c.FIX_VAR_DIM utils/mountd/mountd.c
>>  *** utils/mountd/mountd.c.FIX_VAR_DIM	Sun May 27 18:16:46 2018
>>  --- utils/mountd/mountd.c	Sun May 27 18:16:46 2018
>>  ***************
>>  *** 702,708 ****
>>          else
>>                  NFSCTL_TCPUNSET(_rpcprotobits);
>>          for (vers =3D 2; vers <=3D 4; vers++) {
>>  ! 		char tag[10];
>>                  sprintf(tag, "vers%d", vers);
>>                  if (conf_get_bool("nfsd", tag, =
NFSCTL_VERISSET(nfs_version, vers)))
>>                          NFSCTL_VERSET(nfs_version, vers);
>>  --- 702,708 ----
>>          else
>>                  NFSCTL_TCPUNSET(_rpcprotobits);
>>          for (vers =3D 2; vers <=3D 4; vers++) {
>>  ! 		char tag[20];
>>                  sprintf(tag, "vers%d", vers);
>>                  if (conf_get_bool("nfsd", tag, =
NFSCTL_VERISSET(nfs_version, vers)))
>>                          NFSCTL_VERSET(nfs_version, vers);
>>=20
>>=20
>>=20
>>  diff -c utils/nfsd/nfsd.c.FIX_VAR_DIM utils/nfsd/nfsd.c
>>  *** utils/nfsd/nfsd.c.FIX_VAR_DIM	Sun May 27 18:16:46 2018
>>  --- utils/nfsd/nfsd.c	Sun May 27 18:16:46 2018
>>  ***************
>>  *** 98,104 ****
>>          else
>>                  NFSCTL_TCPUNSET(protobits);
>>          for (i =3D 2; i <=3D 4; i++) {
>>  ! 		char tag[10];
>>                  sprintf(tag, "vers%d", i);
>>                  if (conf_get_bool("nfsd", tag, =
NFSCTL_VERISSET(versbits, i)))
>>                          NFSCTL_VERSET(versbits, i);
>>  --- 98,104 ----
>>          else
>>                  NFSCTL_TCPUNSET(protobits);
>>          for (i =3D 2; i <=3D 4; i++) {
>>  ! 		char tag[20];
>>                  sprintf(tag, "vers%d", i);
>>                  if (conf_get_bool("nfsd", tag, =
NFSCTL_VERISSET(versbits, i)))
>>                          NFSCTL_VERSET(versbits, i);
>>=20
>>=20
>> I thought the maintainers might be interested in fixing upstream
>>=20
>> ciao
>> gabriele
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



