From: Ihar Hrachyshka <ihar.hrachyshka@gmail.com>
Subject: Re: [PATCH] Fixed cross-compilation of nfs-utils tools.
Date: Tue, 3 Mar 2009 20:31:24 +0200
Message-ID: <fce2a370903031031o5abdeaear9cb3471134f59087@mail.gmail.com>
References: <1236102558-18099-1-git-send-email-ihar.hrachyshka@gmail.com>
	 <9DAB51AD-9EE9-4AC5-A77F-C261CBDAAD96@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f176.google.com ([209.85.220.176]:39503 "EHLO
	mail-fx0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428AbZCCSb3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 13:31:29 -0500
Received: by fxm24 with SMTP id 24so2563027fxm.37
        for <linux-nfs@vger.kernel.org>; Tue, 03 Mar 2009 10:31:25 -0800 (PST)
In-Reply-To: <9DAB51AD-9EE9-4AC5-A77F-C261CBDAAD96@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hm, it seems that the problem is not in nfs-utils though in my cross
build system - OpenEmbedded. Sorry for noise.

On Tue, Mar 3, 2009 at 8:03 PM, Chuck Lever <chuck.lever@oracle.com> wr=
ote:
> On Mar 3, 2009, at Mar 3, 2009, 12:49 PM, Ihar Hrachyshka wrote:
>>
>> Build nfs-utils tools with compiler defined by ./configure script.
>
> In the patch description, can you provide some information about the =
problem
> you encountered?
>
>> ---
>> tools/locktest/Makefile.am | =C2=A0 =C2=A04 ----
>> tools/rpcdebug/Makefile.am | =C2=A0 =C2=A04 ----
>> tools/rpcgen/Makefile.am =C2=A0 | =C2=A0 =C2=A05 -----
>> 3 files changed, 0 insertions(+), 13 deletions(-)
>>
>> diff --git a/tools/locktest/Makefile.am b/tools/locktest/Makefile.am
>> index 3156815..e89fbad 100644
>> --- a/tools/locktest/Makefile.am
>> +++ b/tools/locktest/Makefile.am
>> @@ -1,12 +1,8 @@
>> ## Process this file with automake to produce Makefile.in
>>
>> -CC=3D$(CC_FOR_BUILD)
>> LIBTOOL =3D @LIBTOOL@ --tag=3DCC
>>
>> noinst_PROGRAMS =3D testlk
>> testlk_SOURCES =3D testlk.c
>> -testlk_CFLAGS=3D$(CFLAGS_FOR_BUILD)
>> -testlk_CPPFLAGS=3D$(CPPFLAGS_FOR_BUILD)
>> -testlk_LDFLAGS=3D$(LDFLAGS_FOR_BUILD)
>>
>> MAINTAINERCLEANFILES =3D Makefile.in
>> diff --git a/tools/rpcdebug/Makefile.am b/tools/rpcdebug/Makefile.am
>> index 39b70c9..c627b01 100644
>> --- a/tools/rpcdebug/Makefile.am
>> +++ b/tools/rpcdebug/Makefile.am
>> @@ -1,6 +1,5 @@
>> ## Process this file with automake to produce Makefile.in
>>
>> -CC=3D$(CC_FOR_BUILD)
>> LIBTOOL =3D @LIBTOOL@ --tag=3DCC
>>
>> man8_MANS =3D rpcdebug.man
>> @@ -8,8 +7,5 @@ EXTRA_DIST =3D $(man8_MANS)
>>
>> sbin_PROGRAMS =3D rpcdebug
>> rpcdebug_SOURCES =3D rpcdebug.c
>> -rpcdebug_CFLAGS=3D$(CFLAGS_FOR_BUILD)
>> -rpcdebug_CPPFLAGS=3D$(CPPFLAGS_FOR_BUILD) -I$(top_srcdir)/support/i=
nclude
>> -rpcdebug_LDFLAGS=3D$(LDFLAGS_FOR_BUILD)
>>
>> MAINTAINERCLEANFILES =3D Makefile.in
>> diff --git a/tools/rpcgen/Makefile.am b/tools/rpcgen/Makefile.am
>> index 51a2bfa..fc75108 100644
>> --- a/tools/rpcgen/Makefile.am
>> +++ b/tools/rpcgen/Makefile.am
>> @@ -1,6 +1,5 @@
>> ## Process this file with automake to produce Makefile.in
>>
>> -CC=3D$(CC_FOR_BUILD)
>> LIBTOOL =3D @LIBTOOL@ --tag=3DCC
>>
>> noinst_PROGRAMS =3D rpcgen
>> @@ -9,10 +8,6 @@ rpcgen_SOURCES =3D rpc_clntout.c rpc_cout.c rpc_hou=
t.c
>> rpc_main.c \
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rpc_util.c r=
pc_sample.c rpc_output.h rpc_parse.h \
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rpc_scan.h r=
pc_util.h
>>
>> -rpcgen_CFLAGS=3D$(CFLAGS_FOR_BUILD)
>> -rpcgen_CPPLAGS=3D$(CPPFLAGS_FOR_BUILD)
>> -rpcgen_LDFLAGS=3D$(LDFLAGS_FOR_BUILD)
>> -
>
> Are you sure rpcgen should be built for the target system? =C2=A0rpcg=
en only
> needs to run on the build system; it's not installed on the target, a=
s far
> as I know. =C2=A0The rpcgen on my systems are from glibc-common.
>
>>
>> MAINTAINERCLEANFILES =3D Makefile.in
>>
>> EXTRA_DIST =3D rpcgen.new.1
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
