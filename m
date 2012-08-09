Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35948 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754019Ab2HISBO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Aug 2012 14:01:14 -0400
Date: Thu, 9 Aug 2012 14:01:03 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: steved@redhat.com
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Zdenek Salvet <salvet@ics.muni.cz>,
        Lukas Hejtmanek <xhejtman@ics.muni.cz>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH] README: note gssd/svcgssd may be needed on both sides
Message-ID: <20120809180103.GA9914@fieldses.org>
References: <20120806135517.GS25979@ics.muni.cz>
 <20120807154114.GA21460@fieldses.org>
 <1344355148.5781.31.camel@lade.trondhjem.org>
 <20120808075813.GW604@horn.ics.muni.cz>
 <1344431887.3423.4.camel@lade.trondhjem.org>
 <20120809080642.GE604@horn.ics.muni.cz>
 <20120809144530.GB6592@fieldses.org>
 <1344527573.25447.17.camel@lade.trondhjem.org>
 <20120809165035.GB8230@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120809165035.GB8230@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Administrators and distributors have been confused about this.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 README |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/README b/README
index e55b2dd..9bb69d7 100644
--- a/README
+++ b/README
@@ -71,18 +71,21 @@ scripts can be written to work correctly.
 
 
    A/  mount -t nfsd /proc/fs/nfsd
-      This filesystem needs to be mount before most daemons,
+      This filesystem needs to be mounted before most daemons,
       particularly exportfs, mountd, svcgssd, idmapd.
       It could be mounted once, or the script that starts each daemon
       could test if it is mounted and mount it if not.
 
-   B/ svcgssd ; idmapd
+   B/ svcgssd ; gssd; idmapd
        These supply services to nfsd and so should be started before
        rpc.nfsd.  Where they come between mounting the nfsd filesystem
        and starting the nfsd server is not important.
        idmapd is only needed for NFSv4 support.
-       svcgssd is only needed if exportfs NFS filesystem with crypto-
-       security (Kerberos).
+       svcgssd is needed to export filesystems with Kerberos.
+       gssd should also be started to support granting delegations to
+       NFSv4.0 clients using Kerberos.  However, if it is not started
+       this will only mean that delegations will not be granted.  This
+       will not prevent NFSv4.0 clients from functioning normally.
 
    C/ exportfs -av ; rpc.mountd
        It is important that exportfs be run before mountd so that
@@ -148,10 +151,15 @@ scripts can be written to work correctly.
       filesystems can be mounted with "-o nolock" before sm-notify.
       This is appropriate for '/', '/usr', and '/var'.
 
-   B/ gssd ; idmapd
+   B/ gssd ; svcgssd; idmapd
       idmapd should be started before mounting any NFSv4 filesystems.
       gssd should be started before mounting any NFS filesystems
       securely (with Kerberos).
+      Before mounting any NFSv4.0 filesystems with Kerberos, svcgssd should
+      also be started to support the callbacks required for delegations.
+      However, a failure to start svcgssd will only mean that delegations
+      are turned off, and will not prevent such a mount from working
+      correctly.
 
    C/ statd should be run before any NFSv2 or NFSv3 filesystem is
       mounted with remote locking (i.e. without -o nolock).
-- 
1.7.9.5

