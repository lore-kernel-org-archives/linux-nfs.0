Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33759 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750952AbeFCQa0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Jun 2018 12:30:26 -0400
Received: by mail-wr0-f196.google.com with SMTP id k16-v6so13474052wro.0
        for <linux-nfs@vger.kernel.org>; Sun, 03 Jun 2018 09:30:25 -0700 (PDT)
Received: from [192.168.25.210] (dslb-002-203-092-011.002.203.pools.vodafone-ip.de. [2.203.92.11])
        by smtp.gmail.com with ESMTPSA id w14-v6sm5850658wmc.15.2018.06.03.09.30.23
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 03 Jun 2018 09:30:24 -0700 (PDT)
Message-ID: <1528043420.3598.4.camel@gmail.com>
Subject: tools/locktest/testlk.c:84: argument 4 has type
 =?UTF-8?Q?=E2=80=98=5F=5Foff64=5Ft?= {aka long long
 =?UTF-8?Q?int}=E2=80=99?=
From: Philipp Psurek <philipp.psurek@gmail.com>
To: linux-nfs@vger.kernel.org
Date: Sun, 03 Jun 2018 18:30:20 +0200
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I got this error on 32 bit ARM:

make[2]: Entering directory
'/home/portage/portage/net-fs/nfs-utils-2.3.2/work/nfs-utils-
2.3.2/tools/locktest'
armv7a-hardfloat-linux-gnueabi-gcc -DHAVE_CONFIG_H -I.
-I../../support/include 
-I/usr/include/tirpc -D_GNU_SOURCE -pipe  -Wall  -Wextra 
-Werror=strict-prototypes  -Werror=missing-prototypes 
-Werror=missing-declarations  -Werror=format=2  -Werror=undef 
-Werror=missing-include-dirs  -Werror=strict-aliasing=2  -Werror=init-
self 
-Werror=implicit-function-declaration  -Werror=return-type  -
Werror=switch 
-Werror=overflow  -Werror=parentheses  -Werror=aggregate-return 
-Werror=unused-result  -fno-strict-aliasing  -Werror=format-overflow=2
-Werror=int-conversion -Werror=incompatible-pointer-types
-Werror=misleading-indentation -O3 -pipe -fomit-frame-pointer
-mcpu=cortex-a7
-mtune=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -ffast-math -c -o
testlk.o
testlk.c
testlk.c: In function ‘main’:
testlk.c:84:45: error: format ‘%ld’ expects argument of type ‘long
int’, but
argument 4 has type ‘__off64_t {aka long long int}’ [-Werror=format=]
    printf("%s: conflicting lock by %d on (%ld;%ld)\n",
                                           ~~^
                                           %lld
     fname, fl.l_pid, fl.l_start, fl.l_len);
                      ~~~~~~~~~~              
testlk.c:84:49: error: format ‘%ld’ expects argument of type ‘long
int’, but
argument 5 has type ‘__off64_t {aka long long int}’ [-Werror=format=]
    printf("%s: conflicting lock by %d on (%ld;%ld)\n",
                                               ~~^
                                               %lld
     fname, fl.l_pid, fl.l_start, fl.l_len);

You can not assume long is 64 bit wide on 32 bit architectures. You
have to use
long long. Please apply the patch below

* 2nd change removes whitespace
* 3rd change is this bug
* 1st change suppress this warning from gcc-7 and higher:

testlk.c: In function 'main':
testlk.c:30:4: warning: this statement may fall through
[-Wimplicit-fallthrough=]
    usage(0);
    ^~~~~~~~
testlk.c:31:3: note: here
   case 'r':
   ^~~~

see
https://gcc.gnu.org/onlinedocs/gcc-7.3.0/gcc/Warning-Options.html#index
-Wimplicit-fallthrough_003d

I provide you this bug via email, because I can not upload files into
Bugzilla
https://bugzilla.linux-nfs.org/show_bug.cgi?id=325

Your Bugzilla has also an invalid security certificate
https://bugzilla.linux-nfs.org/show_bug.cgi?id=323

The Bug described in this email is
https://bugzilla.linux-nfs.org/show_bug.cgi?id=324

------------------------------------------------------
fl.l_start and fl.l_len are 64 bit wide. It has been assumed that long
is 64 bit in a printf(), which is incorrect on a 32 bit archtecture

* 1st change suppress fall through warning from gcc-7 and higher
* 2nd change removes whitespace
* 3rd change is this bug and changes this into a long long

Signed-off-by: Philipp Psurek <philipp.psurek@gmail.com>
---

--- a/tools/locktest/testlk.c    2018-05-22 20:33:01.000000000 +0200
+++ b/tools/locktest/testlk.c    2018-06-03 17:26:36.800202901 +0200
@@ -28,6 +28,7 @@
 		switch (c) {
 		case 'h':
 			usage(0);
+			/* fall through */
 		case 'r':
 			cmd = F_SETLK;
 			typ = F_RDLCK;
@@ -75,13 +76,13 @@
 	if (fcntl(fd, cmd, &fl) < 0)
 		fatal("fcntl");
 	printf("fcntl: ok\n");
-	
+
 	/* printf("TP2\n"); */
 	if (cmd == F_GETLK) {
 		if (fl.l_type == F_UNLCK) {
 			printf("%s: no conflicting lock\n", fname);
 		} else {
-			printf("%s: conflicting lock by %d on
(%ld;%ld)\n",
+			printf("%s: conflicting lock by %d on
(%lld;%lld)\n",
 				fname, fl.l_pid, fl.l_start,
fl.l_len);
 		}
 		return 0;

