Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:47709 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752620Ab0HDRMy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 13:12:54 -0400
Received: by gxk23 with SMTP id 23so2071760gxk.19
        for <linux-nfs@vger.kernel.org>; Wed, 04 Aug 2010 10:12:53 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] nfs-utils: fix check_netgroup()
To: steved@redhat.com
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
Date: Wed, 04 Aug 2010 13:12:48 -0400
Message-ID: <20100804171036.2657.8657.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This is the patch I posted yesterday, split into two smaller changes
and with Neil's comments addressed.  This is reviewed and compile-
tested, but needs testing by someone who has real netgroup test cases,
which I don't have.

Steve, this fix should be included in the upcoming release of
nfs-utils (after appropriate testing, of course).

---

Chuck Lever (2):
      libexport: Fix IP address check in check_netgroup()
      libexport: Add a common exit label to check_netgroup()


 support/export/client.c |   39 +++++++++++++++++++++++++++++----------
 1 files changed, 29 insertions(+), 10 deletions(-)

--
Chuck Lever
