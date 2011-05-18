Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6350 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752675Ab1ERT5X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 May 2011 15:57:23 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: trond@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: NFS: pnfs ipv6 and multipath parsing
Date: Wed, 18 May 2011 15:57:12 -0400
Message-Id: <1305748634-28348-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These two patches add support for IPv6 dataserver connectivity and 
parsing all multipath addresses.

IPv6: basically same patch as before:
 - no longer calls kzalloc() while holding spinlock
 - i verified that everything works as expected when CONFIG_IPV6 is not defined

Multipath: this just parses multipath config.  It lays the groundwork for 
           true multipath support.
 - skips over DS addresses that are not supported (ie RDMA, or IPv6 if turned
   off)

-dros

