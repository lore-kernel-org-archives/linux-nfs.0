Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:35351 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596AbbGaWNa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Jul 2015 18:13:30 -0400
Received: by qgii95 with SMTP id i95so55442119qgi.2
        for <linux-nfs@vger.kernel.org>; Fri, 31 Jul 2015 15:13:29 -0700 (PDT)
Subject: [PATCH 0/6] nfsidmap enhancements
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Cc: dhowells@redhat.com
Date: Fri, 31 Jul 2015 15:13:26 -0700
Message-ID: <20150731220914.50685.32887.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add "-d" and "-l" options, and clean up some error handling
problems.

These need testing. I'm still thinking about how to set the NFSv4
domain name.

---

Chuck Lever (6):
      nfsidmap: Display the effective NFSv4 domain name
      nfsidmap: Use find_key_by_type_and_desc() if available
      nfsidmap: List cached ID mapping results
      nfsidmap: Fix error handling in id_lookup()
      nfsidmap: Fix error handling in name_lookup()
      nfsidmap: Clean up other exit status cases


 utils/nfsidmap/nfsidmap.c   |  298 ++++++++++++++++++++++++++++++-------------
 utils/nfsidmap/nfsidmap.man |   74 +++++++++--
 2 files changed, 271 insertions(+), 101 deletions(-)

--
Chuck Lever
