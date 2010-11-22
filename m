From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: compiling nfs-utils 1.2.3
Date: Mon, 22 Nov 2010 10:45:53 -0500
Message-ID: <CFB95A58-CF7C-4E9B-B3E7-FB3FB279DA67@oracle.com>
References: <x6wro9r11c@gzp>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "Gabor Z. Papp" <gzp-2g/1Y3AqmNE@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:25907 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211Ab0KVPrK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Nov 2010 10:47:10 -0500
In-Reply-To: <x6wro9r11c@gzp>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'll take a look.

On Nov 19, 2010, at 6:43 AM, Gabor Z. Papp wrote:

> lo lo,
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




