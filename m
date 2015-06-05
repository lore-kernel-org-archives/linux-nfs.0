Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.lysator.liu.se ([130.236.254.3]:33968 "EHLO
	mail.lysator.liu.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505AbbFEMYj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Jun 2015 08:24:39 -0400
Received: from mail.lysator.liu.se (localhost [127.0.0.1])
	by mail.lysator.liu.se (Postfix) with ESMTP id 14C174007C
	for <linux-nfs@vger.kernel.org>; Fri,  5 Jun 2015 14:18:36 +0200 (CEST)
From: Karl-Johan Karlsson <creideiki+linux-nfs@lysator.liu.se>
To: linux-nfs@vger.kernel.org, Steve Dickson <steved@redhat.com>
Subject: libtirpc-0.3.1 fails to build with Heimdal Kerberos
Date: Fri, 05 Jun 2015 14:18:33 +0200
Message-ID: <2431059.CVRe3y6Cse@orley>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm trying to debug a build failure for libtirpc-0.3.1 with GSSAPI support 
when using Heimdal 1.5.3 as Kerberos provider. Downstream bug report is at 
https://bugs.gentoo.org/show_bug.cgi?id=551036

src/svc_auth_gss.c has an unconditional
   #include <gssapi/gssapi_ext.h>
but Heimdal doesn't ship that file; MIT-Krb5 does, though. It looks like most 
(but not all) of the functions that MIT-Krb5 declares in <gssapi/gssapi_ext.h> 
are declared in Heimdal by <gssapi/gssapi.h>.

src/svc_auth_gss.c has
   #ifdef HAVE_KRB5
and
   #elif HAVE_HEIMDAL
sections, but nothing I can see in the Autoconf system defines those. 
configure.ac does have
   AC_CHECK_HEADER([gssapi/gssapi.h], [HAVE_GSSAPI_H=yes], [HAVE_GSSAPI_H=no])
but that's just used internally in the configure script.

Would it be correct to export HAVE_GSSAPI_H and HAVE_GSSAPI_EXT_H to config.h 
and have src/svc_auth_gss.c include gssapi.h and/or gssapi_ext.h depending on 
them?

By the way, the link to the libtirpc gitweb on http://linux-nfs.org/wiki/index.php/Main_Page is broken. It points to http://git.linux-nfs.org/?p=steved/libtirpc.git;a=summary which is a 404.

-- 
Karl-Johan Karlsson
