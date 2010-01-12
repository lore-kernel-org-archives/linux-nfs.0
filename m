Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:62649 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372Ab0ALWmg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Jan 2010 17:42:36 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Fix IPv6 address handling in addr.c
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 12 Jan 2010 17:40:59 -0500
Message-ID: <20100112223826.3167.13900.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Two minor patches to net/sunrpc/addr.c to fix how sunrpc.ko handles
certain types of IPv6 addresses.  Please consider these for 2.6.34.

---

Chuck Lever (2):
      SUNRPC: Don't display zero scope IDs
      SUNRPC: Deprecate support for site-local addresses


 net/sunrpc/addr.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

-- 
chuck[dot]lever[at]oracle[dot]com
