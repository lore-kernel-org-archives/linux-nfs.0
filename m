Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.gentoo.org ([140.211.166.183]:46725 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752109Ab3CXWFN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Mar 2013 18:05:13 -0400
From: Mike Frysinger <vapier@gentoo.org>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH [rpcbind]] rename configure.in to configure.ac
Date: Sun, 24 Mar 2013 18:09:27 -0400
Message-Id: <1364162967-9612-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Newer autotools wants this to end in .ac.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 configure.in => configure.ac | 0
 1 file changed, 0 insertions(+), 0 deletions(-)
 rename configure.in => configure.ac (100%)

diff --git a/configure.in b/configure.ac
similarity index 100%
rename from configure.in
rename to configure.ac
-- 
1.8.1.2

