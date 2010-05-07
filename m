Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f183.google.com ([209.85.221.183]:44423 "EHLO
	mail-qy0-f183.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755741Ab0EGRpX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 May 2010 13:45:23 -0400
Received: by qyk13 with SMTP id 13so1957785qyk.1
        for <linux-nfs@vger.kernel.org>; Fri, 07 May 2010 10:45:22 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Two more patches related to mountd IPv6 support
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 07 May 2010 13:45:17 -0400
Message-ID: <20100507174128.4221.36914.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steve-

Here are two more minor clean-up patches for IPv6 support in mountd.
The second patch defines the format in which IPv6 address are stored
in rmtab.  Since IPv6 addresses are new to this file, I hope there are
no backward-compatibility concerns about this change, but please let
me know if there might be a problem.

---

Chuck Lever (2):
      mountd: Convert colons in IPv6 presentation addresses to semicolons
      libexport.a: Refactor rmtab_read()


 support/export/rmtab.c |   64 +++++++++++++++++++++++++++++++-----------------
 support/nfs/rmtab.c    |   42 +++++++++++++++++++++++++++++---
 2 files changed, 80 insertions(+), 26 deletions(-)

-- 
Chuck Lever
