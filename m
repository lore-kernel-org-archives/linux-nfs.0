Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:49691 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758371Ab1FWCZy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 22:25:54 -0400
Received: by ywe9 with SMTP id 9so564770ywe.19
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jun 2011 19:25:53 -0700 (PDT)
From: Tom Haynes <loghyr@gmail.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, Tom Haynes <tdh@excfb.com>
Subject: [PATCH 0/2] minor patches to cthon tests for FreeBSD
Date: Wed, 22 Jun 2011 21:26:05 -0500
Message-Id: <1308795967-7605-1-git-send-email-tdh@excfb.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

First allows FreeBSD 9.0 to compile and second allows
for leading space in the time output.

Tom Haynes (2):
  Multiple clnt_broadcast, rename static reference
  Make the stat command handle leading blank spaces

 general/stat.c  |    4 +++-
 tools/pmapbrd.c |    7 ++++---
 2 files changed, 7 insertions(+), 4 deletions(-)

-- 
1.7.3.4

