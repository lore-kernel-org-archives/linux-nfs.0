Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51631 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758547AbaKUQoG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Nov 2014 11:44:06 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Tom Gundersen <teg@jklm.no>, Lennart Poettering <lennart@poettering.net>,
        systemd-devel@lists.freedesktop.org
Subject: [PATCH] rpcbind: systemd socket activation
Date: Fri, 21 Nov 2014 11:43:46 -0500
Message-Id: <1416588227-17245-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a re-post of Tom's patch he posted a while back.
I made the following changes.

* Reorganized the changes so the diff is more readable
  by using a goto instead of indenting 268 lines.

* Removed the systemd scripts because they just didn't
  work and won't going to work. I did spend some time 
  on them but debugging was not worth the time since 
  the current ones worked. I'm more than willing to 
  revisit this down the line.

Finally I would like to thank Tom for all of his help! 
It was much appreciated!

Tom Gundersen (1):
  rpcbind: add support for systemd socket activation

 Makefile.am   |  6 +++++
 configure.ac  | 10 ++++++++
 src/rpcbind.c | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 91 insertions(+), 6 deletions(-)

-- 
2.1.0

