Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from odpn1.odpn.net ([212.40.96.53]:33029 "EHLO odpn1.odpn.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932372Ab0KSXV7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Nov 2010 18:21:59 -0500
Received: from odpn1.odpn.net [212.40.96.53]
	by odpn1.odpn.net for linux-nfs@vger.kernel.org
	id 1PJPNn-0001Om-Vd; Fri, 19 Nov 2010 12:44:00 +0100
From: "Gabor Z. Papp" <gzp@papp.hu>
To: linux-nfs@vger.kernel.org
Subject: compiling nfs-utils 1.2.3
Date: Fri, 19 Nov 2010 12:43:59 +0100
Message-ID: <x6wro9r11c@gzp>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

lo lo,

trying to compile nfs-utils 1.2.3 on linux kernel 2.4.37.10, glibc 2.2.5:

cc -DHAVE_CONFIG_H -I. -I../../support/include   -D_GNU_SOURCE -Wall
-Wextra -Wstrict-prototypes  -pipe -g -O2 -MT file.o -MD -MP -MF
.deps/file.Tpo -c -o file.o file.c
file.c:638: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'static'
file.c: In function 'nsm_insert_monitored_host':
file.c:747: warning: implicit declaration of function 'nsm_create_monitor_record'
file.c: At top level:
file.c:788: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'static'
file.c: In function 'nsm_read_line':
file.c:842: warning: implicit declaration of function 'nsm_parse_line'
make[3]: *** [file.o] Error 1
make[3]: Leaving directory `/home/gzp/src/nfs-utils-1.2.3/support/nsm'
make[2]: *** [all] Error 2
make[2]: Leaving directory `/home/gzp/src/nfs-utils-1.2.3/support/nsm'
make[1]: *** [all-recursive] Error 1
make[1]: Leaving directory `/home/gzp/src/nfs-utils-1.2.3/support'
make: *** [all-recursive] Error 1

[kernel]
Linux gzpLinux 2.4.37.10-gzpLinux #1 Mon Oct 4 08:57:02 CEST 2010 i686 GNU/Linux

[glibc]
GNU C Library stable release version 2.2.5, by Roland McGrath et al.
Compiled by GNU CC version 3.3.6.
Compiled on a Linux 2.4.36.2-gzpLinux system on 2008-03-22.

[gcc]
gcc (GCC) 4.4.5

[binutils]
GNU ld (Linux/GNU Binutils) 2.21.51.0.1.20101110
