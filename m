From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: nfs-utils 1.1.3 and glibc 2.2
Date: Tue, 29 Jul 2008 11:13:40 -0400
Message-ID: <76bd70e30807290813l438414e5q4c61cf9f42eeae36@mail.gmail.com>
References: <x6vdyqkrnm@gzp>
	 <76bd70e30807281024q19b59f13j9466231afe9154e6@mail.gmail.com>
	 <x6ej5d11u5@gzp>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Gabor Z. Papp" <gzp-2g/1Y3AqmNE@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.185]:26086 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034AbYG2PNn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2008 11:13:43 -0400
Received: by mu-out-0910.google.com with SMTP id w8so6031800mue.1
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2008 08:13:40 -0700 (PDT)
In-Reply-To: <x6ej5d11u5@gzp>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 29, 2008 at 5:22 AM, Gabor Z. Papp <gzp-2g/1Y3AqmNE@public.gmane.org> wrote:
> | > make[2]: Entering directory
> | > `/home/gzp/src/nfs-utils-1.1.3/utils/mount'
> | > gcc -DHAVE_CONFIG_H -I. -I../../support/include
> | > -I../../support/include -D_GNU_SOURCE -Wall -Wstrict-prototypes  -pipe
> | > -g -O2 -MT network.o -MD -MP -MF .deps/network.Tpo -c -o network.o network.c
> | > network.c: In function 'nfs_name_to_address':
> | > network.c:154: error: 'AI_ADDRCONFIG' undeclared (first use in this function)
> | > network.c:154: error: (Each undeclared identifier is reported only once
> | > network.c:154: error: for each function it appears in.)
> | > network.c:160: error: 'AI_V4MAPPED' undeclared (first use in this function)
> | > network.c:160: error: 'AI_ALL' undeclared (first use in this function)
> | > make[2]: *** [network.o] Error 1
> | > make[2]: Leaving directory `/home/gzp/src/nfs-utils-1.1.3/utils/mount'
> | >
> | > 1.1.2 compiles fine.
>
> | Can you tell me what distribution you are using?
>
> No distro.
>
> | In my distribution (Fedora), these macros, along with getaddrinfo(3),
> | are defined in /usr/include/netdb.h.  utils/mount/network.c appears to
> | include this file directly, so I am still puzzled by this.
>
> I'll attach the glibc 2.2.5 netdb.h, and grep AI_ in /usr/include
> returns only this:
>
> $ grep AI_ *
> netdb.h:#  define GAI_WAIT      0
> netdb.h:#  define GAI_NOWAIT    1
> netdb.h:# define AI_PASSIVE     0x0001  /* Socket address is intended for `bind'.  */
> netdb.h:# define AI_CANONNAME   0x0002  /* Request for canonical name.  */
> netdb.h:# define AI_NUMERICHOST 0x0004  /* Don't use name resolution. */
> netdb.h:# define EAI_BADFLAGS     -1    /* Invalid value for `ai_flags' field.  */
> netdb.h:# define EAI_NONAME       -2    /* NAME or SERVICE is unknown.  */
> netdb.h:# define EAI_AGAIN        -3    /* Temporary failure in name resolution.  */
> netdb.h:# define EAI_FAIL         -4    /* Non-recoverable failure in name res.  */
> netdb.h:# define EAI_NODATA       -5    /* No address associated with NAME.  */
> netdb.h:# define EAI_FAMILY       -6    /* `ai_family' not supported. */
> netdb.h:# define EAI_SOCKTYPE     -7    /* `ai_socktype' not supported.  */
> netdb.h:# define EAI_SERVICE      -8    /* SERVICE not supported for `ai_socktype'.  */
> netdb.h:# define EAI_ADDRFAMILY   -9    /* Address family for NAME no tsupported.  */
> netdb.h:# define EAI_MEMORY       -10   /* Memory allocation failure. */
> netdb.h:# define EAI_SYSTEM       -11   /* System error returned in `errno'.  */
> netdb.h:#  define EAI_INPROGRESS  -100  /* Processing request in progress.  */
> netdb.h:#  define EAI_CANCELED    -101  /* Request canceled.  */
> netdb.h:#  define EAI_NOTCANCELED -102  /* Request not canceled.  */
> netdb.h:#  define EAI_ALLDONE     -103  /* All requests done.  */
> netdb.h:#  define EAI_INTR        -104  /* Interrupted by a signal. */
> netdb.h:/* Enqueue ENT requests from the LIST.  If MODE is GAI_WAIT wait until all
> netdb.h:   requests are handled.  If WAIT is GAI_NOWAIT return immediately after

I downloaded glibc-2.2.5 yesterday to take a look.

There is an "interesting" comment in glibc-2.2.5/include/netdb.h,
followed by all the missing AI_ macro definitions:

"/* The following declarations and definitions have been removed from
   the public header since we don't want people to use them.  */"

All of these are now included in /usr/include/netdb.h with no
qualification whatever, so at some point the glibc maintainers changed
their mind about this.

Likely the correct fix for this is to restore the old
nfs_gethostbyname() and have ./configure detect the presence of these
AI_ macros.  If they are not present, use the original function.  If
they are, use the new one.

Alternately, we can define these in utils/mount/network.c if they are
not already defined.  This would work if the actual value of these
macros has not changed over time.

I'll post a proposed fix as soon as I can, but some research will be
required to figure out why these were banned originally.

-- 
Chuck Lever
