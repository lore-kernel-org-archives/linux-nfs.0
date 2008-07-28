From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: nfs-utils 1.1.3 and glibc 2.2
Date: Mon, 28 Jul 2008 13:24:22 -0400
Message-ID: <76bd70e30807281024q19b59f13j9466231afe9154e6@mail.gmail.com>
References: <x6vdyqkrnm@gzp>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Gabor Z. Papp" <gzp-2g/1Y3AqmNE@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:61516 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757261AbYG1RYZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jul 2008 13:24:25 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1534891nfc.21
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jul 2008 10:24:22 -0700 (PDT)
In-Reply-To: <x6vdyqkrnm@gzp>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 28, 2008 at 10:30 AM, Gabor Z. Papp <gzp-2g/1Y3AqmNE@public.gmane.org> wrote:
> Hello,
>
> seems like nfs-utils no more compatible with glibc 2.2?

By the way, this wasn't by design.  :-)

> make[2]: Entering directory
> `/home/gzp/src/nfs-utils-1.1.3/utils/mount'
> gcc -DHAVE_CONFIG_H -I. -I../../support/include
> -I../../support/include -D_GNU_SOURCE -Wall -Wstrict-prototypes  -pipe
> -g -O2 -MT network.o -MD -MP -MF .deps/network.Tpo -c -o network.o network.c
> network.c: In function 'nfs_name_to_address':
> network.c:154: error: 'AI_ADDRCONFIG' undeclared (first use in this function)
> network.c:154: error: (Each undeclared identifier is reported only once
> network.c:154: error: for each function it appears in.)
> network.c:160: error: 'AI_V4MAPPED' undeclared (first use in this function)
> network.c:160: error: 'AI_ALL' undeclared (first use in this function)
> make[2]: *** [network.o] Error 1
> make[2]: Leaving directory `/home/gzp/src/nfs-utils-1.1.3/utils/mount'
>
> 1.1.2 compiles fine.

Can you tell me what distribution you are using?  I don't think I have
access to a glibc2.2-based distribution to do testing/debugging, but
if you are using a fairly contemporary distribution that is
glibc2.2-based, I might try setting up a temporary guest for testing.

In my distribution (Fedora), these macros, along with getaddrinfo(3),
are defined in /usr/include/netdb.h.  utils/mount/network.c appears to
include this file directly, so I am still puzzled by this.

-- 
Chuck Lever
