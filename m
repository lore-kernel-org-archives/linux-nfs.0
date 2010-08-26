Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35126 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751116Ab0HZEMd convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Aug 2010 00:12:33 -0400
From: Ben Hutchings <ben@decadent.org.uk>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Justin Pryzby <justinpryzby@users.sourceforge.net>, 472341@bugs.debian.org,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 26 Aug 2010 05:12:20 +0100
Message-ID: <1282795940.22839.268.camel@localhost>
Subject: configure: Fix error message for Kerberos versions with suffixes
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Justin Pryzby reported (some time ago) that the following error message
appeared while configuring nfs-utils:

checking for Kerberos v5... ./configure: line 23606: test: 163-beta1-debian: integer expression expected
/usr
The current KRBDIR is /usr

This is because the Kerberos version check assumes that all version
components are separated by dots.  Change it to accept hyphens as
separators as well.

Reported-by: Justin Pryzby <justinpryzby@users.sourceforge.net>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
--- a/aclocal/kerberos5.m4
+++ b/aclocal/kerberos5.m4
@@ -32,7 +32,7 @@
     if test "$K5CONFIG" != ""; then
       KRBCFLAGS=`$K5CONFIG --cflags`
       KRBLIBS=`$K5CONFIG --libs gssapi`
-      K5VERS=`$K5CONFIG --version | head -n 1 | awk '{split($(4),v,"."); if (v@<:@"3"@:>@ == "") v@<:@"3"@:>@ = "0"; print v@<:@"1"@:>@v@<:@"2"@:>@v@<:@"3"@:>@ }'`
+      K5VERS=`$K5CONFIG --version | head -n 1 | awk '{split($(4),v,/@<:@.-@:>@/); if (v@<:@"3"@:>@ == "") v@<:@"3"@:>@ = "0"; print v@<:@"1"@:>@v@<:@"2"@:>@v@<:@"3"@:>@ }'`
       AC_DEFINE_UNQUOTED(KRB5_VERSION, $K5VERS, [Define this as the Kerberos version number])
       if test -f $dir/include/gssapi/gssapi_krb5.h -a \
                 \( -f $dir/lib/libgssapi_krb5.a -o \
---

-- 
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.
