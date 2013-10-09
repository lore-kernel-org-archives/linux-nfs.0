Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:42084 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986Ab3JIUWC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Oct 2013 16:22:02 -0400
Received: by mail-qc0-f173.google.com with SMTP id l13so536340qcy.32
        for <linux-nfs@vger.kernel.org>; Wed, 09 Oct 2013 13:22:01 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: ssorce@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/2] gssd: allow gssd to work with KEYRING: credcaches
Date: Wed,  9 Oct 2013 16:21:54 -0400
Message-Id: <1381350116-10464-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Changes since original set:
v3:
- have parent check to see if child was signalled and log a warning if so
- drop supplimentary groups and change gid before acquiring creds. Keep
  suid and sgid as well to hamper ptrace.

v2:
- fix bisectability. The original set added includes in the wrong
  place in patch #1 and then fixed it in patch #2. The final result
  of this set is the same but should bisect cleanly.

This patchset fixes up gssd to work with KEYRING: style credcaches. At
the same time, it also fixes gssd not to need to trawl through likely
credcache locations by allowing GSSAPI to find them in the intended
fashion.

The basic idea is to have gssd fork() after reading off the pipe, but
before handling the upcall and to do a more thorough job of changing
credentials.

Jeff Layton (2):
  gssd: have process_krb5_upcall fork before handling upcall
  gssd: do a more thorough change of identity after forking

 utils/gssd/gssd_proc.c | 106 +++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 89 insertions(+), 17 deletions(-)

-- 
1.8.3.1

