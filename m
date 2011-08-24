Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:42819 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917Ab1HXPdr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Aug 2011 11:33:47 -0400
Received: by ewy4 with SMTP id 4so527255ewy.19
        for <linux-nfs@vger.kernel.org>; Wed, 24 Aug 2011 08:33:46 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] Possible fixes for statd / sm-notify / exportfs
To: linux-nfs@vger.kernel.org
Date: Wed, 24 Aug 2011 11:33:43 -0400
Message-ID: <20110824153024.3138.63294.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

While working on another fix, I noticed that the complex hostname
matching logic in statd, exportfs, and sm-notify appears to break with
the local hostname and IP addresses.  I propose the following to
address this.

---

Chuck Lever (5):
      sm-notify: sm-notify doesn't handle localhost properly
      exportfs: matchhostname() doesn't handle localhost properly
      statd: statd_matchhostname() doesn't handle localhost properly
      sm-notify: Disable syslog messages when debugging is enabled
      statd: Report count of loaded hosts correctly


 utils/exportfs/exportfs.c |   34 +++++++++++-
 utils/statd/hostname.c    |   55 ++++++++++++++++---
 utils/statd/monitor.c     |    2 -
 utils/statd/sm-notify.c   |  133 ++++++++++++++++++++++++++++++++++++---------
 4 files changed, 186 insertions(+), 38 deletions(-)

-- 
Chuck Lever
