Return-Path: linux-nfs-owner@vger.kernel.org
Received: from master.debian.org ([82.195.75.110]:48817 "EHLO
	master.debian.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683Ab3KXFTN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Nov 2013 00:19:13 -0500
Date: Sun, 24 Nov 2013 16:19:04 +1100
From: =?iso-8859-1?Q?An=EDbal?= Monsalve Salazar <anibal@debian.org>
To: linux-nfs@vger.kernel.org
Subject: Re: librpcsecgss: FTBFS on GNU/kFreeBSD
Message-ID: <20131124051904.GA16651@master.debian.org>
References: <20090703133142.14887.33854.reportbug@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20090703133142.14887.33854.reportbug@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 03, 2009 at 03:31:42PM +0200, Cyril Brulebois wrote:
> Package: librpcsecgss
> Version: 0.18-1
> Severity: important
> Tags: patch pending
> User: glibc-bsd-devel@lists.alioth.debian.org
> Usertags: kfreebsd
> 
> Hi,
> 
> please find attached a trivial patch to fix the FTBFS on GNU/kFreeBSD:
> [...] 

I've carried the patch below in Debian for a long time. Please consider
merging it.

>From dc2b55a7f83d6c505ba79b83089f365bb0c24bf1 Mon Sep 17 00:00:00 2001
From: Cyril Brulebois <kibi@debian.org>
Date: Fri, 3 Jul 2009 15:31:42 +0200
Subject: librpcsecgss: FTBFS on GNU/kFreeBSD

Fix FTBFS on GNU/kFreeBSD by using getpid() (rather than arc4random())                                                               
not only if __linux__ is defined, but also if __GLIBC__ is defined.

Signed-off-by: Anibal Monsalve Salazar <anibal@debian.org>
---
 src/clnt_tcp.c | 2 +-
 src/clnt_udp.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/src/clnt_tcp.c b/src/clnt_tcp.c
index 4da0d31..f2c3da0 100644
--- a/src/clnt_tcp.c
+++ b/src/clnt_tcp.c
@@ -225,7 +225,7 @@ clnttcp_create(raddr, prog, vers, sockp, sendsz, recvsz)
 	 * Initialize call message
 	 */
 	(void)gettimeofday(&now, (struct timezone *)0);
-#ifdef __linux__
+#if defined (__linux__) || defined(__GLIBC__)
 	call_msg.rm_xid = getpid() ^ now.tv_sec ^ now.tv_usec;
 #else
 	call_msg.rm_xid = arc4random();
diff --git a/src/clnt_udp.c b/src/clnt_udp.c
index fc803b2..fe95ed2 100644
--- a/src/clnt_udp.c
+++ b/src/clnt_udp.c
@@ -153,7 +153,7 @@ clntudp_bufcreate(raddr, program, version, wait, sockp, sendsz, recvsz)
 	cu->cu_total.tv_usec = -1;
 	cu->cu_sendsz = sendsz;
 	cu->cu_recvsz = recvsz;
-#ifdef __linux__
+#if defined (__linux__) || defined(__GLIBC__)
 	call_msg.rm_xid = getpid() ^ now.tv_sec ^ now.tv_usec;
 #else
 	call_msg.rm_xid = arc4random();
-- 
1.8.4.2

