From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: About configure error
Date: Mon, 28 Jun 2010 10:22:30 -0400
Message-ID: <4C28B026.5010702@oracle.com>
References: <74B0AE1BA53C37449DE49BB274F9A2DB2B3DA2@orion8.netlogicmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
	Jeff Layton <jlayton@redhat.com>
To: Henry Shao <hshao-oSioyQM9ZPnuBjGU1YDckgC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:46291 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753202Ab0F1OXQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jun 2010 10:23:16 -0400
In-Reply-To: <74B0AE1BA53C37449DE49BB274F9A2DB2B3DA2-eoZZxEticU+jYOuY2elzORyIOQ/kevag@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
