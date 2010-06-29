Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:58971 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756416Ab0F2PXM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2010 11:23:12 -0400
Message-ID: <4C2A0FC8.2020607@oracle.com>
Date: Tue, 29 Jun 2010 11:22:48 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Henry Shao <hshao@netlogicmicro.com>
CC: linux-nfs@vger.kernel.org, steved@redhat.com,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: About configure error
References: <74B0AE1BA53C37449DE49BB274F9A2DB2B3DA2@orion8.netlogicmicro.com> <4C28B026.5010702@oracle.com> <74B0AE1BA53C37449DE49BB274F9A2DB2B3DAA@orion8.netlogicmicro.com>
In-Reply-To: <74B0AE1BA53C37449DE49BB274F9A2DB2B3DAA@orion8.netlogicmicro.com>
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/28/10 07:32 PM, Henry Shao wrote:
> Hi Chuck:
>
>        Thanks for the response.
>        Even I do "--disable-tirpc",  it give me another error,  can't find  libwrap
>        Can you point to me where can I download libwrap source?   I searched google, can't find a linux version.
>        Or how can I disable libwrap?
> ...
> checking for stdint.h... yes
> checking for unistd.h... yes
> checking for prctl... yes
> checking for cap_get_proc in -lcap... yes
> checking sys/capability.h usability... yes
> checking sys/capability.h presence... no
> configure: WARNING: sys/capability.h: accepted by the compiler, rejected by the preprocessor!
> configure: WARNING: sys/capability.h: proceeding with the compiler's result
> checking for sys/capability.h... yes
> checking for libwrap... configure: error: *** libwrap missing
>
>
>        Thanks a million!

libwrap refers to the tcp_wrappers library.  It is available in many if 
not all Linux distributions.  How you get it depends on how your 
distribution packages libraries for cross-compilation.

But I think you can disable that using --without-tcp-wrappers.

> -----Original Message-----
> From: Chuck Lever [mailto:chuck.lever@oracle.com]
> Sent: Mon 6/28/2010 7:22 AM
> To: Henry Shao
> Cc: linux-nfs@vger.kernel.org; steved@redhat.com; Jeff Layton
> Subject: Re: About configure error
>
> On 06/26/10 03:37 PM, Henry Shao wrote:
>>
>> Hi Sir:
>>
>>       I try to compile nfs-utils-1.2.2 for our mips64 platform using cross compiler.  I keek get configure error:
>> checking for clnt_tli_create in -ltirpc... no
>> configure: error: libtirpc not found.
>>
>>        Then I download libtirpc  and compile it successfully and install it in  ../lib directory.   I try to use LIBS or exec_prefix ... to pass it in.   It did not successful.   Still keeping get this error.
>>
>>        Do you mind to tell me how can I pass this error and get it compiled for our mips target?
>>
>>       Thank you very much!
>>
>>
>>
>> # CC=mipsisa64r2rmi-linux-gcc ./configure --host=mips-linux --disable-gss --disable-nfsv4
>
> ./configure should have noticed that libtirpc was missing and then
> automatically set --disable-tirpc.  As a workaround you could manually
> specify --disable-tirpc on your ./configure command line.
>
> After installing libtirpc, though, maybe you need to run ./configure
> again from scratch:
>
>     $ make distclean
>     $ sh autogen.sh
>     $ ./configure ....
>
> If you are trying to install and use a local copy of libtirpc (ie one
> that is not installed in /usr/lib), that may not be supported.
>

