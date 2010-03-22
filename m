Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:38405 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753407Ab0CVAiA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Mar 2010 20:38:00 -0400
Received: by qyk9 with SMTP id 9so2899230qyk.1
        for <linux-nfs@vger.kernel.org>; Sun, 21 Mar 2010 17:38:00 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] mountd cleanup
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Sun, 21 Mar 2010 20:37:56 -0400
Message-ID: <20100322003317.30360.18289.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Steve-

These four patches clean up some spots in libexport.a.  They are
pre-requisites for mountd/exportfs IPv6 support.

---

Chuck Lever (4):
      libexport.a: e_fslocdata should be freed with free(3)
      libexport.a: Fix whitespace damage in support/export/export.c
      libexport.a: Clean up client_compose() and client_member()
      libexport.a: Remove dead code


 support/export/client.c    |   65 ++++++++++++++++++--------------------------
 support/export/export.c    |   13 +++++----
 support/include/exportfs.h |    5 +--
 3 files changed, 36 insertions(+), 47 deletions(-)

-- 
Chuck Lever
