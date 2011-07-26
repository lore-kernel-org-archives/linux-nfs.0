Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:44548 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752890Ab1GZJTZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jul 2011 05:19:25 -0400
Received: from public by plane.gmane.org with local (Exim 4.69)
	(envelope-from <public@plane.gmane.org>)
	id 1QldnM-0007CU-NH
	for linux-nfs@vger.kernel.org; Tue, 26 Jul 2011 11:19:20 +0200
Message-ID: <4E2E64AA.1090408@linux.vnet.ibm.com>
Date: Mon, 25 Jul 2011 23:54:34 -0700
From: Venkateswararao Jujjuri <jvrao@linux.vnet.ibm.com>
To: Malahal Naineni
	<public-malahal-r/Jw6+rmf7HQT0dZR+AlfA@plane.gmane.org>
CC: public-linux-nfs-u79uwXL29TY76Z2rM5mHXA@plane.gmane.org
Subject: Re: [PATCH 1/2] nfs4-acl-tools: Fix segfault if format of the input
 file is incorrect
References: <1311280507-28957-1-git-send-email-malahal@us.ibm.com>
In-Reply-To: <1311280507-28957-1-git-send-email-malahal@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0




On 07/21/2011 01:35 PM, Malahal Naineni wrote:
> The sizeof operator, when applied to a parameter declared to have array,
> yields the size of the adjusted (pointer) type, even if the parameter
> declaration specifies a length.
>
> Signed-off-by: Malahal Naineni<malahal-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>   libnfs4acl/nfs4_ace_from_string.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/libnfs4acl/nfs4_ace_from_string.c b/libnfs4acl/nfs4_ace_from_string.c
> index 9d877fb..462fcc0 100644
> --- a/libnfs4acl/nfs4_ace_from_string.c
> +++ b/libnfs4acl/nfs4_ace_from_string.c
> @@ -100,7 +100,7 @@ parse_alloc_fields(char *buf, char *fields[NUMFIELDS])
>   	if (!buf)
>   		return -EINVAL;
>
> -	memset(fields, 0, sizeof(fields));
> +	memset(fields, 0, sizeof(char *) * NUMFIELDS);
>
>   	for (i = 0; buf[i] != '\0'; i++) {
>   		if (buf[i] == ':')

Could it be compiler specific? It is working fine for me


Test]$ cat sizeof.c
===========
#include <stdio.h>
#define NUMFIELDS 10
main()
{
	char *fields1[NUMFIELDS];
	char fields2[NUMFIELDS];

	printf("sizeof(fields1):%d sizeof(char *)*NUMFIELDS:%d\n", 
sizeof(fields1), sizeof(char *)*NUMFIELDS);
	printf("sizeof(fields2):%d sizeof(char)*NUMFIELDS:%d\n", 
sizeof(fields2), sizeof(char)*NUMFIELDS);
}
============

[jvrao Test]$ make sizeof
cc     sizeof.c   -o sizeof
[jvrao Test]$ ./sizeof
sizeof(fields1):80 sizeof(char *)*NUMFIELDS:80
sizeof(fields2):10 sizeof(char)*NUMFIELDS:10


[jvrao Test]$ cc -v
Using built-in specs.
Target: x86_64-redhat-linux
Configured with: ../configure --prefix=/usr --mandir=/usr/share/man 
--infodir=/usr/share/info 
--with-bugurl=http://bugzilla.redhat.com/bugzilla --enable-bootstrap 
--enable-shared --enable-threads=posix --enable-checking=release 
--with-system-zlib --enable-__cxa_atexit --disable-libunwind-exceptions 
--enable-gnu-unique-object 
--enable-languages=c,c++,objc,obj-c++,java,fortran,ada 
--enable-java-awt=gtk --disable-dssi 
--with-java-home=/usr/lib/jvm/java-1.5.0-gcj-1.5.0.0/jre 
--enable-libgcj-multifile --enable-java-maintainer-mode 
--with-ecj-jar=/usr/share/java/eclipse-ecj.jar 
--disable-libjava-multilib --with-ppl --with-cloog --with-tune=generic 
--with-arch_32=i686 --build=x86_64-redhat-linux
Thread model: posix
gcc version 4.4.4 20100726 (Red Hat 4.4.4-13) (GCC)










