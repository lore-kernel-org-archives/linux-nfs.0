Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:45620 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750699Ab1BKK3j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 05:29:39 -0500
From: Jan Engelhardt <jengelh@medozas.de>
To: linux-nfs@vger.kernel.org
Subject: domainless lookups
Date: Fri, 11 Feb 2011 11:29:33 +0100
Message-Id: <1297420176-24960-1-git-send-email-jengelh@medozas.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Hi,


here are two patches. The first one is pretty simple, simply
reducing the requirement.

Second one is more of a suggestion, and its implementation being
limited to nss.c makes it more of a temporary hack than a
full solution. Anyway, I'll just sit back and wait for input :)

-

The following changes since commit 8752edac80a250095dc920a5a5c3bedc4cbeeb4b:

  Cleaned up some warnings (2011-01-14 10:43:53 -0500)

are available in the git repository at:
  git://dev.medozas.de/libnfsidmap master

Jan Engelhardt (2):
      configure: reduce minimum autoconf version to 2.65
      nss: allow domainless lookups

 configure.in |    2 +-
 nss.c        |   21 +++++++++++++++++++++
 2 files changed, 22 insertions(+), 1 deletions(-)
