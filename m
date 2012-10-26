Return-Path: linux-nfs-owner@vger.kernel.org
Received: from c2beaomr06.btconnect.com ([213.123.26.184]:18142 "EHLO
	mail.btconnect.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S964985Ab2JZQF4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2012 12:05:56 -0400
From: "lux-integ" <lux-integ@btconnect.com>
To: Steve Dickson <SteveD@redhat.com>
Subject: Re: nfs-utils, --enable-gss   librpcsecgss.so glitch
Date: Fri, 26 Oct 2012 18:01:06 +0100
Cc: linux-nfs@vger.kernel.org
References: <201210260234.04247.lux-integ@btconnect.com> <508A6C46.2070309@RedHat.com>
In-Reply-To: <508A6C46.2070309@RedHat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201210261801.06308.lux-integ@btconnect.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Friday 26 October 2012 11:56:06 Steve Dickson wrote:

> >  with the --disable-gss ,  compilation sicceeds
> > 
> > BUT
> > with --enable-gss (the default)
> > make ends like so.
> > #########
> > /usr/lib/librpcsecgss.so: undefined reference to `__rpc_thread_svc_fdset'
> > collect2: ld returned 1 exit status
> > make[2]: *** [gssd] Error 1
> > ########
> 
> This was define in glibc... I wonder if its deprecated
> 
> steved.
> 
I forgot to mention that my setup has glibc-2.15.

So the problem maybe the installation of libtirpc which uses depreciated 
headers ( post glibc-2.15 ).
I followed this recipe:-
http://www.linuxfromscratch.org/blfs/view/svn/basicnet/libtirpc.html

SO 
Do you
(or enyone else on list )
 know of a recipe to   compile/install libtirpc-0.2.2  on a setup with 
glibc-2.15/gcc-4.6.3/linux-3.6.3 ?

Alternatively do you know of an available   nfs-1.2.6(+)-useable version  of  
libtirpc that   compiles/installs on  a setup with 
glibc-2.15/gcc-4.6.3/linux-3.6.3 ?

thanks in advance

sincerely
lux-integ
