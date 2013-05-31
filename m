Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46016 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751522Ab3EaArt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 May 2013 20:47:49 -0400
Date: Thu, 30 May 2013 20:47:48 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org
Subject: nfsd fixes for 3.10
Message-ID: <20130531004748.GA14555@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd fixes for 3.10:

  git://linux-nfs.org/~bfields/linux.git for-3.10

A couple minor fixes for the (new to 3.10) gss-proxy code.

And one regression from user-namespace changes.  (XBMC clients were
doing something admittedly weird--sending -1 gid's--but something that
we used to allow.)

--b.

----------------------------------------------------------------
Dan Carpenter (1):
      svcauth_gss: fix error code in use_gss_proxy()

J. Bruce Fields (2):
      svcrpc: implement O_NONBLOCK behavior for use-gss-proxy
      svcrpc: fix failures to handle -1 uid's and gid's

 net/sunrpc/auth_gss/svcauth_gss.c |    8 +++++---
 net/sunrpc/svcauth_unix.c         |   12 +++++++-----
 2 files changed, 12 insertions(+), 8 deletions(-)
