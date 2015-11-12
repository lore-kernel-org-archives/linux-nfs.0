Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46609 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932312AbbKLLoJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Nov 2015 06:44:09 -0500
Subject: [PATCH 2/2] MAINTAINERS: linux-cachefs@redhat.com is moderated for
 non-subscribers
From: David Howells <dhowells@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-cachefs@vger.kernel.org,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        linux-fsdevel@vger.kernel.org
Date: Thu, 12 Nov 2015 11:44:05 +0000
Message-ID: <20151112114405.22379.69612.stgit@warthog.procyon.org.uk>
In-Reply-To: <20151112114344.22379.19320.stgit@warthog.procyon.org.uk>
References: <20151112114344.22379.19320.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 MAINTAINERS |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 35fe7ae0492e..470605885f01 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2545,7 +2545,7 @@ F:	arch/c6x/
 
 CACHEFILES: FS-CACHE BACKEND FOR CACHING ON MOUNTED FILESYSTEMS
 M:	David Howells <dhowells@redhat.com>
-L:	linux-cachefs@redhat.com
+L:	linux-cachefs@redhat.com (moderated for non-subscribers)
 S:	Supported
 F:	Documentation/filesystems/caching/cachefiles.txt
 F:	fs/cachefiles/
@@ -4558,7 +4558,7 @@ F:	include/linux/frontswap.h
 
 FS-CACHE: LOCAL CACHING FOR NETWORK FILESYSTEMS
 M:	David Howells <dhowells@redhat.com>
-L:	linux-cachefs@redhat.com
+L:	linux-cachefs@redhat.com (moderated for non-subscribers)
 S:	Supported
 F:	Documentation/filesystems/caching/
 F:	fs/fscache/

