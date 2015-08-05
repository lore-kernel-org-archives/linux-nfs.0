Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:35472 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339AbbHEOp1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 10:45:27 -0400
Received: by qgj62 with SMTP id 62so6055646qgj.2
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 07:45:27 -0700 (PDT)
Subject: [PATCH v2 0/6] nfsidmap enhancements
From: Chuck Lever <chuck.lever@oracle.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 05 Aug 2015 10:45:23 -0400
Message-ID: <20150805143258.13266.92369.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add "-d" and "-l" options, and clean up some error handling
problems.

I've decided to think more about the mechanism which sets the NFSv4
domain. Neither conf_ nor libnfsidmap has any support for modifying
a configuration file. The naive approach is to open-code editing the
configuration file, which is kind of ugly.

Build and basic operational testing on Fedora 22 and on RHEL 6
passes. Steve, IMO these are ready to be merged.


Changes since the first version:
- Tested
- Various small clean ups
- "else" is gone

---

Chuck Lever (6):
      nfsidmap: Display the effective NFSv4 domain name
      nfsidmap: Use find_key_by_type_and_desc() if available
      nfsidmap: List cached ID mapping results
      nfsidmap: Fix error handling in id_lookup()
      nfsidmap: Fix error handling in name_lookup()
      nfsidmap: Clean up other exit status cases


 utils/nfsidmap/nfsidmap.c   |  299 ++++++++++++++++++++++++++++++-------------
 utils/nfsidmap/nfsidmap.man |   74 +++++++++--
 2 files changed, 271 insertions(+), 102 deletions(-)

--
Chuck Lever
