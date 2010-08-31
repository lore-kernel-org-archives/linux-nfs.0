Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:57229 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404Ab0HaTLW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Aug 2010 15:11:22 -0400
Received: by ywh1 with SMTP id 1so2356272ywh.19
        for <linux-nfs@vger.kernel.org>; Tue, 31 Aug 2010 12:11:21 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Improvements to mount's autonegotiation
To: neilb@suse.de
Cc: linux-nfs@vger.kernel.org
Date: Tue, 31 Aug 2010 15:11:18 -0400
Message-ID: <20100831191006.10685.66951.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Neil-

While reviewing your proposed patch, a couple of ideas occurred to me
that might be helpful.  Compile-tested only.  Let me know what you
think.

---

Chuck Lever (2):
      mount.nfs: Don't try NFSv4 if UDP was requested
      mount.nfs: Refactor mount version and protocol autonegotiation


 utils/mount/stropts.c |   72 +++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 57 insertions(+), 15 deletions(-)

-- 
Chuck Lever
