From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/3] libnsm.a: Replace __attribute_noinline__
Date: Mon, 13 Dec 2010 14:59:55 -0500
Message-ID: <4D067B3B.4090900@RedHat.com>
References: <20101206160206.18361.26178.stgit@matisse.1015granger.net> <20101206160953.18361.21885.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57114 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754038Ab0LMT76 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Dec 2010 14:59:58 -0500
In-Reply-To: <20101206160953.18361.21885.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/06/2010 11:09 AM, Chuck Lever wrote:
> "Gabor Z. Papp" <gzp-2g/1Y3AqmNE@public.gmane.org> reports:
> 
> trying to compile nfs-utils 1.2.3 on linux kernel 2.4.37.10, glibc 2.2.5:
> 
> cc -DHAVE_CONFIG_H -I. -I../../support/include   -D_GNU_SOURCE -Wall
> -Wextra -Wstrict-prototypes  -pipe -g -O2 -MT file.o -MD -MP -MF
> .deps/file.Tpo -c -o file.o file.c
> file.c:638: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'static'
> file.c: In function 'nsm_insert_monitored_host':
> file.c:747: warning: implicit declaration of function 'nsm_create_monitor_record'
> file.c: At top level:
> file.c:788: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'static'
> file.c: In function 'nsm_read_line':
> file.c:842: warning: implicit declaration of function 'nsm_parse_line'
> make[3]: *** [file.o] Error 1
> make[3]: Leaving directory `/home/gzp/src/nfs-utils-1.2.3/support/nsm'
> make[2]: *** [all] Error 2
> make[2]: Leaving directory `/home/gzp/src/nfs-utils-1.2.3/support/nsm'
> make[1]: *** [all-recursive] Error 1
> make[1]: Leaving directory `/home/gzp/src/nfs-utils-1.2.3/support'
> make: *** [all-recursive] Error 1
> 
> [kernel]
> Linux gzpLinux 2.4.37.10-gzpLinux #1 Mon Oct 4 08:57:02 CEST 2010 i686 GNU/Linux
> 
> [glibc]
> GNU C Library stable release version 2.2.5, by Roland McGrath et al.
> Compiled by GNU CC version 3.3.6.
> Compiled on a Linux 2.4.36.2-gzpLinux system on 2008-03-22.
> 
> [gcc]
> gcc (GCC) 4.4.5
> 
> [binutils]
> GNU ld (Linux/GNU Binutils) 2.21.51.0.1.20101110
> 
> === cut here ===
> 
> sys/cdefs.c in glibc 2.2.5 does not define __attribute_noinline__.
> 
> Replace the __attribute_noinline__ form with
> 
>   __attribute__((__noinline__)).
> 
> Even though the compiler didn't complain about __attribute_malloc__,
> also replace those in order to maintain consistent style throughout the
> source file.
> 
> Fix for:
> 
>   https://bugzilla.linux-nfs.org/show_bug.cgi?id=194
> 
> Reported-by: "Gabor Z. Papp" <gzp-2g/1Y3AqmNE@public.gmane.org>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Committed.. 

steved.
