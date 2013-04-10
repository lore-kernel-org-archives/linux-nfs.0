Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f169.google.com ([209.85.214.169]:45014 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933969Ab3DJNIJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2013 09:08:09 -0400
Received: by mail-ob0-f169.google.com with SMTP id wp18so378464obc.28
        for <linux-nfs@vger.kernel.org>; Wed, 10 Apr 2013 06:08:08 -0700 (PDT)
MIME-Version: 1.0
From: Dirkjan Ochtman <dirkjan@ochtman.nl>
Date: Wed, 10 Apr 2013 15:07:48 +0200
Message-ID: <CAKmKYaBgoqEsejJm+WO-q2HuW7gi3YMx3vCn3NEPWS9vKiHwcg@mail.gmail.com>
Subject: Very slow NFS reads from within Apache
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I hope this is a good list to write to; I've spent a day on trying to
debug this and can't seem to come up with anything useful. Please let
me know if another venue would be more appropriate.

I have a web application written in Python (2.7.3), running under
Apache (2.2.24) that sometimes reads data from a (72M) file on a
NFS-mounted filesystem. Both the web server and the file server are
running Linux 3.6.11; the filesystem is mounted with rw,nfsvers=3 as
options, and it's on a local 1Gb network.

This used to work fine, with requests to the web page completing in
about 3s -- not very fast, but fast enough for us. However, since
yesterday, it started becoming much slower, on the order of 90-100s.
I've monitored top and iotop, but found nothing out of the ordinary.

>From outside the web server, reading from the same file in the same
exact manner, these are some of the strace results:

4596  14:39:33.790999 open("/home/user/share/file", O_RDONLY) = 3 <0.000471>
4596  14:39:33.791523 fstat(3, {st_mode=S_IFREG|0644,
st_size=70306195, ...}) = 0 <0.000013>
4596  14:39:33.791585 fstat(3, {st_mode=S_IFREG|0644,
st_size=70306195, ...}) = 0 <0.000009>
4596  14:39:33.791646 mmap(NULL, 1048576, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fbcf3b38000 <0.000012>
4596  14:39:33.791692 read(3,
"\200\2}q\1(U\nda-2004-04q\2]q\3(}q\4(U\6ra"..., 1048576) = 1048576
<0.000495>
4596  14:39:33.831513 brk(0x1c41000)    = 0x1c41000 <0.000012>
4596  14:39:33.832101 brk(0x1c63000)    = 0x1c63000 <0.000014>
4596  14:39:33.832692 brk(0x1c85000)    = 0x1c85000 <0.000008>
4596  14:39:33.833272 read(3,
"G?\271\202r\311\27\372\302h\265G@`@\0\0\0\0\0h\266G?\306\354\222\356Z\215\375h"...,
1048576) = 1048576 <0.000240>
4596  14:39:33.833565 brk(0x1ca6000)    = 0x1ca6000 <0.000012>
4596  14:39:33.834166 brk(0x1cc8000)    = 0x1cc8000 <0.000012>
4596  14:39:33.834733 brk(0x1cea000)    = 0x1cea000 <0.000011>
4596  14:39:33.835317 brk(0x1d0c000)    = 0x1d0c000 <0.000012>
4596  14:39:33.835815 mmap(NULL, 266240, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fbcf52f9000 <0.000013>
4596  14:39:37.539952 munmap(0x7fbcf34ec000, 3149824) = 0 <0.000171>
4596  14:39:37.540186 close(3)          = 0 <0.000019>
4596  14:39:37.540249 munmap(0x7fbcf3b38000, 1048576) = 0 <0.000066>
4596  14:39:37.654260 munmap(0x7fbcf37ed000, 266240) = 0 <0.000042>
4596  14:39:37.673038 munmap(0x7fbcf38b0000, 266240) = 0 <0.000042>

For the web server case, I use mod_wsgi to proxy requests over a UNIX
socket to Python daemon running the actual application. From stracing
through child processes, I get this:

5183  14:42:01.477362 open("/home/user/share/file", O_RDONLY <unfinished ...>
5183  14:42:01.478168 <... open resumed> ) = 17 <0.000794>
5183  14:42:01.478192 fstat(17,  <unfinished ...>
5183  14:42:01.478218 <... fstat resumed> {st_mode=S_IFREG|0644,
st_size=70306195, ...}) = 0 <0.000017>
5183  14:42:01.478278 fstat(17,  <unfinished ...>
5183  14:42:01.478320 <... fstat resumed> {st_mode=S_IFREG|0644,
st_size=70306195, ...}) = 0 <0.000032>
5183  14:42:01.478351 mmap(NULL, 1048576, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0 <unfinished ...>
5183  14:42:01.478403 <... mmap resumed> ) = 0x7f3cc0783000 <0.000040>
5183  14:42:01.478428 read(17,  <unfinished ...>
5183  14:42:01.478972 <... read resumed>
"\200\2}q\1(U\nda-2004-04q\2]q\3(}q\4(U\6ra"..., 1048576) = 1048576
<0.000535>
5183  14:42:01.479621 futex(0x15a9b70, FUTEX_WAKE_PRIVATE, 1 <unfinished ...>
5183  14:42:01.479646 <... futex resumed> ) = 0 <0.000016>
5183  14:42:01.479684 futex(0x15a9b70, FUTEX_WAIT_PRIVATE, 0, NULL
<unfinished ...>
5183  14:42:01.479707 <... futex resumed> ) = -1 EAGAIN (Resource
temporarily unavailable) <0.000014>
5183  14:42:01.479788 futex(0x15a9b70, FUTEX_WAKE_PRIVATE, 1 <unfinished ...>
5183  14:42:01.479812 <... futex resumed> ) = 0 <0.000015>
5183  14:42:01.479851 futex(0x15a9b70, FUTEX_WAIT_PRIVATE, 0, NULL
<unfinished ...>
5183  14:42:01.479875 <... futex resumed> ) = -1 EAGAIN (Resource
temporarily unavailable) <0.000014>
5183  14:42:01.479957 futex(0x15a9b70, FUTEX_WAIT_PRIVATE, 0, NULL
<unfinished ...>
5183  14:42:01.479981 <... futex resumed> ) = -1 EAGAIN (Resource
temporarily unavailable) <0.000015>
5183  14:42:01.480035 mprotect(0x7f3cb81ea000, 4096,
PROT_READ|PROT_WRITE <unfinished ...>
5183  14:42:01.480059 <... mprotect resumed> ) = 0 <0.000015>
5183  14:42:01.480087 futex(0x15a9b70, FUTEX_WAKE_PRIVATE, 1 <unfinished ...>
5183  14:42:01.480133 <... futex resumed> ) = 1 <0.000037>
5183  14:42:01.480173 futex(0x15a9b70, FUTEX_WAIT_PRIVATE, 0, NULL
<unfinished ...>
5183  14:42:01.480197 <... futex resumed> ) = -1 EAGAIN (Resource
temporarily unavailable) <0.000014>
5183  14:42:01.480279 futex(0x15a9b70, FUTEX_WAIT_PRIVATE, 0, NULL
<unfinished ...>
5183  14:42:01.480318 <... futex resumed> ) = -1 EAGAIN (Resource
temporarily unavailable) <0.000029>
5183  14:42:01.480374 mprotect(0x7f3cb81eb000, 4096,
PROT_READ|PROT_WRITE <unfinished ...>
5183  14:42:01.480399 <... mprotect resumed> ) = 0 <0.000014>
5183  14:42:01.480427 mprotect(0x7f3cb81ec000, 12288,
PROT_READ|PROT_WRITE <unfinished ...>
5183  14:42:01.480453 <... mprotect resumed> ) = 0 <0.000016>
5183  14:42:01.480480 futex(0x15a9b70, FUTEX_WAKE_PRIVATE, 1 <unfinished ...>
5183  14:42:01.480517 <... futex resumed> ) = 1 <0.000029>
5183  14:42:01.480553 futex(0x15a9b70, FUTEX_WAIT_PRIVATE, 0, NULL
<unfinished ...>
5183  14:42:01.480577 <... futex resumed> ) = -1 EAGAIN (Resource
temporarily unavailable) <0.000015>
5183  14:42:01.480655 futex(0x15a9b70, FUTEX_WAIT_PRIVATE, 0, NULL
<unfinished ...>

I haven't been able to make it complete when running under strace.
Does anyone here have a clue what could cause this difference? I've
talked it over with the author of mod_wsgi (the Apache module), but he
doesn't have any good ideas.

Thanks in advance,

Dirkjan
