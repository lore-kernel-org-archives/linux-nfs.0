From: "Henry Shao" <hshao-oSioyQM9ZPnuBjGU1YDckgC/G2K4zDHf@public.gmane.org>
Subject: RE: About configure error
Date: Mon, 28 Jun 2010 16:32:25 -0700
Message-ID: <74B0AE1BA53C37449DE49BB274F9A2DB2B3DAA@orion8.netlogicmicro.com>
References: <74B0AE1BA53C37449DE49BB274F9A2DB2B3DA2@orion8.netlogicmicro.com> <4C28B026.5010702@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <linux-nfs@vger.kernel.org>, <steved@redhat.com>,
	"Jeff Layton" <jlayton@redhat.com>
To: "Chuck Lever" <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.netlogicmicro.com ([12.49.93.86]:1658 "EHLO
	orion5.netlogicmicro.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756380Ab0GQRwR convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 17 Jul 2010 13:52:17 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck:

      Thanks for the response. 
      Even I do "--disable-tirpc",  it give me another error,  can't find  libwrap
      Can you point to me where can I download libwrap source?   I searched google, can't find a linux version.
      Or how can I disable libwrap?
...
checking for stdint.h... yes
checking for unistd.h... yes
checking for prctl... yes
checking for cap_get_proc in -lcap... yes
checking sys/capability.h usability... yes
checking sys/capability.h presence... no
configure: WARNING: sys/capability.h: accepted by the compiler, rejected by the preprocessor!
configure: WARNING: sys/capability.h: proceeding with the compiler's result
checking for sys/capability.h... yes
checking for libwrap... configure: error: *** libwrap missing


      Thanks a million!

Henry


-----Original Message-----
From: Chuck Lever [mailto:chuck.lever@oracle.com]
Sent: Mon 6/28/2010 7:22 AM
To: Henry Shao
Cc: linux-nfs@vger.kernel.org; steved@redhat.com; Jeff Layton
Subject: Re: About configure error
 
On 06/26/10 03:37 PM, Henry Shao wrote:
>
> Hi Sir:
>
>      I try to compile nfs-utils-1.2.2 for our mips64 platform using cross compiler.  I keek get configure error:
> checking for clnt_tli_create in -ltirpc... no
> configure: error: libtirpc not found.
>
>       Then I download libtirpc  and compile it successfully and install it in  ../lib directory.   I try to use LIBS or exec_prefix ... to pass it in.   It did not successful.   Still keeping get this error.
>
>       Do you mind to tell me how can I pass this error and get it compiled for our mips target?
>
>      Thank you very much!
>
>
>
> # CC=mipsisa64r2rmi-linux-gcc ./configure --host=mips-linux --disable-gss --disable-nfsv4

./configure should have noticed that libtirpc was missing and then 
automatically set --disable-tirpc.  As a workaround you could manually 
specify --disable-tirpc on your ./configure command line.

After installing libtirpc, though, maybe you need to run ./configure 
again from scratch:

   $ make distclean
   $ sh autogen.sh
   $ ./configure ....

If you are trying to install and use a local copy of libtirpc (ie one 
that is not installed in /usr/lib), that may not be supported.

