Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60812 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757288Ab0FUQyW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jun 2010 12:54:22 -0400
Received: by iwn36 with SMTP id 36so1063318iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jun 2010 09:54:21 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/7] Remaining IPv6 pre-requisites for mountd
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 21 Jun 2010 12:54:18 -0400
Message-ID: <20100621165114.4771.51575.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Steve-

As requested, here are the remaining seven patches that finish
mountd's conversion from gethostby{name,addr}(3) to
get{name,addr}info(3).

---

Chuck Lever (7):
      libexport.a: Remove unused hostent-based DNS helper functions
      libexport.a: Replace matchhostname()
      libexport.a: Add documenting comments
      libexport.a: Make export_add() static
      libexport.a: Make export_read() return void
      mountd: Replace "struct hostent" with "struct addrinfo"
      exportfs: Add a common exit label in exportfs()


 support/export/client.c    |  268 +++++++++++++++++++++----------------
 support/export/export.c    |   83 ++++++++---
 support/export/hostname.c  |  321 ++------------------------------------------
 support/export/rmtab.c     |   13 +-
 support/include/exportfs.h |   20 ++-
 support/include/misc.h     |    7 -
 utils/exportfs/exportfs.c  |  117 +++++++++++++---
 utils/mountd/auth.c        |   48 +++----
 utils/mountd/cache.c       |   66 +++++----
 utils/mountd/mountd.c      |   11 +-
 10 files changed, 405 insertions(+), 549 deletions(-)

-- 
Chuck Lever
