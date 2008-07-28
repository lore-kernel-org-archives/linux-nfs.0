From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: nfs-utils 1.1.3 and glibc 2.2
Date: Mon, 28 Jul 2008 12:36:47 -0400
Message-ID: <76bd70e30807280936u71b13955i15d44d9c7185f2f4@mail.gmail.com>
References: <x6vdyqkrnm@gzp>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Gabor Z. Papp" <gzp-2g/1Y3AqmNE@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:43354 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192AbYG1Qgu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jul 2008 12:36:50 -0400
Received: by ug-out-1314.google.com with SMTP id h2so62375ugf.16
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jul 2008 09:36:47 -0700 (PDT)
In-Reply-To: <x6vdyqkrnm@gzp>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 28, 2008 at 10:30 AM, Gabor Z. Papp <gzp-2g/1Y3AqmNE@public.gmane.org> wrote:
> Hello,
>
> seems like nfs-utils no more compatible with glibc 2.2?

Does glibc 2.2 have getaddrinfo(3)?  If so, it should have these
macros defined somewhere.

Other parts of nfs-utils already use getaddrinfo, and ./configure is
designed to blow up if getaddrinfo(3) isn't present, so I find this a
little odd.

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

--
Chuck Lever
