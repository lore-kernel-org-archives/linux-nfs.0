Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 183.141.211.66.inaddr.G4.NET ([66.211.141.183]:36584 "EHLO
	Dobby.4dicksons.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753370Ab3DMOJz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Apr 2013 10:09:55 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: Simo Sorce <simo@redhat.com>
Subject: [PATCH] Alternative patchset to avoid PTR lookups (take 2)
Date: Sat, 13 Apr 2013 10:09:52 -0400
Message-Id: <1365862193-21986-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here is how I think we should handle the avoiding of
PTR lookups. Logically its the same as Simo's original 
patch but does change the following:

* Not doing the DNS lookups is now the default behavior
* the -D options can be used to restore the old behavior
* I changes some of the variable names to, hopefully, be
  more obvious as to what the code is doing.

Simo Sorce (1):
  Avoid DNS reverse resolution for server names

 utils/gssd/gss_util.h  |  2 ++
 utils/gssd/gssd.c      |  7 +++++--
 utils/gssd/gssd.man    |  8 +++++++-
 utils/gssd/gssd_proc.c | 29 +++++++++++++++++++++++++----
 4 files changed, 39 insertions(+), 7 deletions(-)

-- 
1.8.1.4

