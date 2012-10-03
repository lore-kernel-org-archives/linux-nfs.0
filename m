Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:42076 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753394Ab2JCMkj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Oct 2012 08:40:39 -0400
Received: by yenm12 with SMTP id m12so1960937yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 03 Oct 2012 05:40:38 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/3] nfsd: add a usermodehelper upcall for client id tracking
Date: Wed,  3 Oct 2012 08:40:28 -0400
Message-Id: <1349268031-16498-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a respin of the set with the same title that I sent on Monday
(Oct 1st). This one has a few bugfixes, and adds some code to allow the
upcall program to convert from the legacy database to the new one. I'll
also be posting a respin of the companion nfs-utils set too.

The idea here is to allow a one-way conversion from the legacy clientid
tracking code to the new one, which should allow for seamless kernel and
nfs-utils upgrades.

In order to handle that, this set also changes the heuristic that the
kernel uses to decide what client tracker to use. We now must now try
the usermodehelper upcall first and only fall back to other schemes if
its initialization fails.

Note that I'm not 100% sold on the idea to convert from the legacy db
format. It's doable but somewhat "fiddly" to handle. There are probably
corner cases where it will fall down, so it may be best not to even try
to do that. I won't be offended if you decide not to take the last
patch.

Comments? Discuss!

Jeff Layton (3):
  nfsd: add a usermodehelper upcall for NFSv4 client ID tracking
  nfsd: change heuristic for selecting the client_tracking_ops
  nfsd: pass info about the legacy recoverydir in environment variables

 fs/nfsd/nfs4recover.c | 250 ++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 240 insertions(+), 10 deletions(-)

-- 
1.7.11.4

