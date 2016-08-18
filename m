Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53156 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932314AbcHSBnM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Aug 2016 21:43:12 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2B3077F7AB
        for <linux-nfs@vger.kernel.org>; Thu, 18 Aug 2016 18:37:18 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u7IIbGGU014077
        for <linux-nfs@vger.kernel.org>; Thu, 18 Aug 2016 14:37:17 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [RFC PATCH 3/3] nfs-utils: Update rpc.idmap and nfsidmap man pages
Date: Thu, 18 Aug 2016 14:37:15 -0400
Message-Id: <1471545435-15543-3-git-send-email-steved@redhat.com>
In-Reply-To: <1471545435-15543-1-git-send-email-steved@redhat.com>
References: <1471545435-15543-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Describe how the NFSv4 domain name can be
now be found using the _nfsv4idmapdomain DNS
TXT record

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/idmapd/idmapd.man     | 23 +++++++++++++++++++++++
 utils/nfsidmap/nfsidmap.man |  9 +++++++++
 2 files changed, 32 insertions(+)

diff --git a/utils/idmapd/idmapd.man b/utils/idmapd/idmapd.man
index b9200c7..d4ab894 100644
--- a/utils/idmapd/idmapd.man
+++ b/utils/idmapd/idmapd.man
@@ -23,6 +23,29 @@ is the NFSv4 ID <-> name mapping daemon.  It provides functionality to
 the NFSv4 kernel client and server, to which it communicates via
 upcalls, by translating user and group IDs to names, and vice versa.
 .Pp
+The system derives the
+.I user
+part of the string by performing a password or group lookup.
+The lookup mechanism is configured in
+.Pa /etc/idmapd.conf
+.Pp
+By default, the
+.I domain
+part of the string is the system's DNS domain name.
+It can also be specified in
+.Pa /etc/idmapd.conf
+if the system is multi-homed,
+or if the system's DNS domain name does
+not match the name of the system's Kerberos realm.
+.Pp
+When the domain is not specified in /etc/idmapd.conf
+the local DNS server will be queried for the 
+.Sy _nfsv4idmapdomain 
+text record. If the record exists
+that will be used as the domain. When the record
+does not exist, the domain part of the DNS domain
+will used. 
+.Pp
 Note that on more recent kernels only the NFSv4 server uses
 .Nm .
 The NFSv4 client instead uses
diff --git a/utils/nfsidmap/nfsidmap.man b/utils/nfsidmap/nfsidmap.man
index 2f17cf2..2af16f3 100644
--- a/utils/nfsidmap/nfsidmap.man
+++ b/utils/nfsidmap/nfsidmap.man
@@ -39,6 +39,15 @@ if the system is multi-homed,
 or if the system's DNS domain name does
 not match the name of the system's Kerberos realm.
 .PP
+When the domain is not specified in 
+.I /etc/idmapd.conf
+the local DNS server will be queried for the 
+.I _nfsv4idmapdomain 
+text record. If the record exists
+that will be used as the domain. When the record
+does not exist, the domain part of the DNS domain
+will used. 
+.PP
 The
 .I /usr/sbin/nfsidmap
 program performs translations on behalf of the kernel.
-- 
2.7.4

