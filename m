Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f174.google.com ([209.85.210.174]:56988 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755390Ab2JKPKm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Oct 2012 11:10:42 -0400
Received: by mail-ia0-f174.google.com with SMTP id y32so1303750iag.19
        for <linux-nfs@vger.kernel.org>; Thu, 11 Oct 2012 08:10:41 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/8] Junctions should inherit parent's export options
To: steved@redhat.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Date: Thu, 11 Oct 2012 11:10:39 -0400
Message-ID: <20121011150421.4665.35964.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Following suggestions by Steve and Bruce, I've at long last
implemented a mechanism by which junctions inherit the export
options of their parent exports.

While I was there, I took the opportunity to clean up the junction
resolution logic.

---

Chuck Lever (8):
      mountd: Simplify "no junction support" case
      mountd: Dynamically allocate exportent that represents junctions
      mountd: Add exportent_release()
      mountd: Junctions inherit parent export's options
      mountd: Add lookup_export_parent()
      mountd: Set e_fslocdata field directly
      mountd: Use static buffer when constructing junction export options
      mountd: Warn when a broken junction is encountered


 support/export/export.c    |   19 ++--
 support/include/exportfs.h |    1 
 utils/mountd/cache.c       |  217 ++++++++++++++++++++++++++++++--------------
 3 files changed, 162 insertions(+), 75 deletions(-)

-- 
Chuck Lever
