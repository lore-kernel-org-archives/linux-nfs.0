Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17063 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753516Ab1GAUkR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2011 16:40:17 -0400
Message-ID: <4E0E30A7.90209@RedHat.com>
Date: Fri, 01 Jul 2011 16:40:07 -0400
From: Steve Dickson <SteveD@redhat.com>
To: "Gabor Z. Papp" <gzp@papp.hu>
CC: linux-nfs@vger.kernel.org
Subject: Re: nfs-utils 1.2.4
References: <x6tyb65wxk@gzp>
In-Reply-To: <x6tyb65wxk@gzp>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/01/2011 02:36 AM, Gabor Z. Papp wrote:
> lo lo,
> 
> trying to configure nfs-utils 1.2.4 with the options below:
> 
> --disable-gss --disable-kprefix --enable-mount --enable-nfsv3
> --disable-nfsv4 --with-statduser=nobody --with-statedir=/var/lib/nfs"
> --without-tcp-wrappers --disable-tirpc
> 
> but getting the following error:
> 
> [...]
> checking size of socklen_t... 4
> configure: error: conditional "CONFIG_NFSIDMAP" was never defined.
> Usually this means the macro was only invoked conditionally.
The following patch seems to take care of the problem... The 
problem stemmed from the use of the --disable-nfsv4, which
I will throw into my unit tests... Please let me know
if this fixes the problem... 

steved.


[PATCH] Make sure CONFIG_NFSIDMAP is always defined.

CONFIG_NFSIDMAP always need to be define either
negatively or positive whether nfsv4 is or is not
defined.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/configure.ac b/configure.ac
index ca12f9e..f8b0796 100644
--- a/configure.ac
+++ b/configure.ac
@@ -249,6 +249,9 @@ AC_CHECK_FUNC([getservbyname], ,
 
 AC_CHECK_LIB([crypt], [crypt], [LIBCRYPT="-lcrypt"])
 
+dnl enable nfsidmap when its support by libnfsidmap
+AM_CONDITIONAL(CONFIG_NFSIDMAP, [test "$enable_nfsidmap" = "yes"])
+
 if test "$enable_nfsv4" = yes; then
   dnl check for libevent libraries and headers
   AC_LIBEVENT
@@ -256,9 +259,6 @@ if test "$enable_nfsv4" = yes; then
   dnl check for nfsidmap libraries and headers
   AC_LIBNFSIDMAP
 
-  dnl enable nfsidmap when its support by libnfsidmap
-  AM_CONDITIONAL(CONFIG_NFSIDMAP, [test "$enable_nfsidmap" = "yes"])
-
   dnl check for the keyutils libraries and headers
   AC_KEYUTILS
 
