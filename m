Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:61924 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885Ab0KVQiV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Nov 2010 11:38:21 -0500
Received: by yxl31 with SMTP id 31so11203yxl.19
        for <linux-nfs@vger.kernel.org>; Mon, 22 Nov 2010 08:38:21 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NSM: Replace __attribute_noinline__
To: gzp@papp.hu
Cc: linux-nfs@vger.kernel.org
Date: Mon, 22 Nov 2010 11:38:16 -0500
Message-ID: <20101122163637.17565.13193.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

"Gabor Z. Papp" <gzp@papp.hu> reports:

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

=== cut here ===

This is curious, because this is a modern compiler (gcc 4.4.5) with
an old version of glibc.  I wouldn't expect a compiler attribute
complaint due to an old version of the C library, but what do I know.

To try to address this, replace the __attribute_noinline__ form with
__attribute__((noinline)).  Even though the compiler didn't complain
about __attribute_malloc__, also replace those in order to maintain
consistent style throughout the source file.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Gabor-

Can you try this out?  Either it will fix the problem, or it will tell
us more about the issue.

 support/nsm/file.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/support/nsm/file.c b/support/nsm/file.c
index f4baeb9..fd9171e 100644
--- a/support/nsm/file.c
+++ b/support/nsm/file.c
@@ -126,7 +126,7 @@ exact_error_check(const ssize_t len, const size_t buflen)
  * containing an appropriate pathname, or NULL if an error
  * occurs.  Caller must free the returned result with free(3).
  */
-__attribute_malloc__
+__attribute__((malloc))
 static char *
 nsm_make_record_pathname(const char *directory, const char *hostname)
 {
@@ -174,7 +174,7 @@ nsm_make_record_pathname(const char *directory, const char *hostname)
  * containing an appropriate pathname, or NULL if an error
  * occurs.  Caller must free the returned result with free(3).
  */
-__attribute_malloc__
+__attribute__((malloc))
 static char *
 nsm_make_pathname(const char *directory)
 {
@@ -204,7 +204,7 @@ nsm_make_pathname(const char *directory)
  * containing an appropriate pathname, or NULL if an error
  * occurs.  Caller must free the returned result with free(3).
  */
-__attribute_malloc__
+__attribute__((malloc))
 static char *
 nsm_make_temp_pathname(const char *pathname)
 {
@@ -634,7 +634,7 @@ nsm_priv_to_hex(const char *priv, char *buf, const size_t buflen)
 /*
  * Returns the length in bytes of the created record.
  */
-__attribute_noinline__
+__attribute__((noinline))
 static size_t
 nsm_create_monitor_record(char *buf, const size_t buflen,
 		const struct sockaddr *sap, const struct mon *m)
@@ -784,7 +784,7 @@ out:
 	return result;
 }
 
-__attribute_noinline__
+__attribute__((noinline))
 static _Bool
 nsm_parse_line(char *line, struct sockaddr_in *sin, struct mon *m)
 {

