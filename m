Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:51273 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030182AbbFEOPQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Jun 2015 10:15:16 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: libtirpc-0.3.1 fails to build with Heimdal Kerberos
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <2431059.CVRe3y6Cse@orley>
Date: Fri, 5 Jun 2015 10:17:29 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>
Message-Id: <446814BB-D4F9-4488-BA41-F0940E1CEBF2@oracle.com>
References: <2431059.CVRe3y6Cse@orley>
To: Karl-Johan Karlsson <creideiki+linux-nfs@lysator.liu.se>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 5, 2015, at 8:18 AM, Karl-Johan Karlsson <creideiki+linux-nfs@lysator.liu.se> wrote:

> Hi,
> 
> I'm trying to debug a build failure for libtirpc-0.3.1 with GSSAPI support 
> when using Heimdal 1.5.3 as Kerberos provider. Downstream bug report is at 
> https://bugs.gentoo.org/show_bug.cgi?id=551036
> 
> src/svc_auth_gss.c has an unconditional
>   #include <gssapi/gssapi_ext.h>
> but Heimdal doesn't ship that file; MIT-Krb5 does, though. It looks like most 
> (but not all) of the functions that MIT-Krb5 declares in <gssapi/gssapi_ext.h> 
> are declared in Heimdal by <gssapi/gssapi.h>.
> 
> src/svc_auth_gss.c has
>   #ifdef HAVE_KRB5
> and
>   #elif HAVE_HEIMDAL
> sections, but nothing I can see in the Autoconf system defines those. 

Looks like that’s dead code. But it’s just a debugging message, so no harm.
Should be cleaned up, eventually.

> configure.ac does have
>   AC_CHECK_HEADER([gssapi/gssapi.h], [HAVE_GSSAPI_H=yes], [HAVE_GSSAPI_H=no])
> but that's just used internally in the configure script.
> 
> Would it be correct to export HAVE_GSSAPI_H and HAVE_GSSAPI_EXT_H to config.h 
> and have src/svc_auth_gss.c include gssapi.h and/or gssapi_ext.h depending on 
> them?

Using the HAVE_GSSAPI_* macros in src/*.c is just fine. You’ll have to introduce
an AC_CHECK for gssapi_ext.h in configure.ac.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



