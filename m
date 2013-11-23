Return-Path: linux-nfs-owner@vger.kernel.org
Received: from master.debian.org ([82.195.75.110]:36492 "EHLO
	master.debian.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945Ab3KWLeg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Nov 2013 06:34:36 -0500
Date: Sat, 23 Nov 2013 22:20:11 +1100
From: =?iso-8859-1?Q?An=EDbal?= Monsalve Salazar <anibal@debian.org>
To: linux-nfs@vger.kernel.org
Cc: Samuel Thibault <sthibault@debian.org>, 729177@bugs.debian.org
Subject: Re: [patch] librpcsecgss: FTBFS on hurd-i386
Message-ID: <20131123112011.GA15347@master.debian.org>
References: <20131109212446.GA24648@type.youpi.perso.aquilenet.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20131109212446.GA24648@type.youpi.perso.aquilenet.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Nov 09, 2013 at 10:24:46PM +0100, Samuel Thibault wrote:
> Package: librpcsecgss
> Version: 0.19-5
> Severity: important
> Tags: patch
> User: debian-hurd@lists.debian.org
> User-tags: hurd
> 
> Hello,
> 
> librpcsecgss currently FTBFS on hurd-i386, attached is a patch to fix
> it.
> 
> Samuel
> 
> -- System Information:
> Debian Release: jessie/sid
>   APT prefers testing
>   APT policy: (990, 'testing'), (500, 'unstable'), (500, 'stable'), (1, 'experimental')
> Architecture: amd64 (x86_64)
> Foreign Architectures: i386
> 
> Kernel: Linux 3.12.0 (SMP w/8 CPU cores)
> Locale: LANG=fr_FR.UTF-8, LC_CTYPE=fr_FR.UTF-8 (charmap=UTF-8)
> Shell: /bin/sh linked to /bin/bash
> 
> -- 
> Samuel
> <studdud> what the fuck is wtf

> --- src/svc_tcp.c	2013-11-09 21:22:12.000000000 +0000
> +++ src/svc_tcp.c	2013-11-09 21:21:45.000000000 +0000
> @@ -52,7 +52,7 @@
>  #include <netinet/in_systm.h>
>  #include <netinet/in.h>
>  #include <netinet/ip.h>
> -#ifndef __linux__
> +#if !defined(__linux__) && !defined(__GNU__)
>  #include <netinet/ip_var.h>
>  #endif
>  
> @@ -262,7 +262,7 @@
>  
>  #ifdef IP_OPTIONS
>  	{
> -#ifdef __linux__
> +#if defined(__linux__) || defined(__GNU__)
>  #define ipopt_list	ip_opts
>  		struct ip_opts opts;
>  #else

>From 6d6ec15cbad84124ecd190fe5fe28177fb131eb9 Mon Sep 17 00:00:00 2001
From: Samuel Thibault <sthibault@debian.org>
Date: Sat, 9 Nov 2013 22:24:46 +0100
Subject: Bug#729177: librpcsecgss: FTBFS on hurd-i386

librpcsecgss currently FTBFS on hurd-i386, attached is a patch to fix it.

Signed-off-by: Anibal Monsalve Salazar <anibal@debian.org>
---
 src/svc_tcp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/src/svc_tcp.c b/src/svc_tcp.c
index e5e0a7f..c6210c3 100644
--- a/src/svc_tcp.c
+++ b/src/svc_tcp.c
@@ -52,7 +52,7 @@ static char *rcsid = "$OpenBSD: svc_tcp.c,v 1.18 1998/05/22 04:23:01 deraadt Exp
 #include <netinet/in_systm.h>
 #include <netinet/in.h>
 #include <netinet/ip.h>
-#ifndef __linux__
+#if !defined(__linux__) && !defined(__GNU__)
 #include <netinet/ip_var.h>
 #endif
 
@@ -262,7 +262,7 @@ rendezvous_request(xprt)
 
 #ifdef IP_OPTIONS
 	{
-#ifdef __linux__
+#if defined(__linux__) || defined(__GNU__)
 #define ipopt_list	ip_opts
 		struct ip_opts opts;
 #else
-- 
1.8.4.2
