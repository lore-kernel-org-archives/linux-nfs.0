Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f173.google.com ([209.85.213.173]:41564 "EHLO
	mail-ye0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754582Ab3JCSmR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Oct 2013 14:42:17 -0400
Received: by mail-ye0-f173.google.com with SMTP id m3so689722yen.4
        for <linux-nfs@vger.kernel.org>; Thu, 03 Oct 2013 11:42:17 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] gssd: allow it to work with KEYRING: credcaches
Date: Thu,  3 Oct 2013 14:42:09 -0400
Message-Id: <1380825731-3314-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This set is comprised of a couple of patches that fix gssd so that it
works with KEYRING: style credcaches. It turns out that gssd already
tries to query GSSAPI to find the best credcache to use and only falls
back to trawling through likely locations for credcaches if that fails.

The problem is that the initial call into GSSAPI for this almost always
fails, so it ends up falling back to trawling in the common case. This
patch corrects this by making a number of changes:

1) credentials are switched sooner during the upcall and don't switch back

2) credentials are switched using setuid() instead of setfsuid(). The
   GSSAPI libs depend on the *real* uid being correct.

3) the daemon now forks before doing any credential switching to ensure
   that unprivileged users can't do anything nefarious to it while it's
   running under a different uid.

With this set of changes, and a bleeding-edge version of the krb5 and
keyutils libs, I can now successfully use KEYRING: style credcaches.

Jeff Layton (2):
  gssd: have process_krb5_upcall fork before handling upcall
  gssd: switch real uid instead of just fsuid when looking for user
    creds

 utils/gssd/gssd_proc.c | 47 ++++++++++++++++++++++++++++++-----------------
 1 file changed, 30 insertions(+), 17 deletions(-)

-- 
1.8.3.1

