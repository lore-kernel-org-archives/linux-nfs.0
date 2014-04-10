Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:55282 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934020AbaDJUjM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Apr 2014 16:39:12 -0400
Received: by mail-qc0-f173.google.com with SMTP id r5so4895403qcx.4
        for <linux-nfs@vger.kernel.org>; Thu, 10 Apr 2014 13:39:12 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] gssd: add the GSSAPI acceptor name to the info passed in downcall
Date: Thu, 10 Apr 2014 16:30:58 -0400
Message-Id: <1397161863-29266-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recently, I started a mailing list thread about some authentication
failures that I was seeing on the callback channel when krb5 was in use.

After a bit of discussion we determined that the right way to fix it
was to save off the GSSAPI acceptor name used in the SETCLIENT call,
and then ensure that the same principal is used in callback requests.

This patchset is the userland portion of that change. It basically
just adds the acceptor name to the downcall, immediately following
the context token. Older kernel will just ignore this data, so this
should be safe.

There is also a companion kernel patchset that will allow the kernel
to save off this info for later usage.

Jeff Layton (5):
  gssd: handle malloc failure appropriately in do_downcall
  gssd: make do_downcall a void return
  gssd: move hostbased name routines into separate file
  gssd: add new routine for generating a hostbased principal in a
    gss_buffer_t
  gssd: scrape the acceptor name out of the context

 utils/gssd/Makefile.am    |   2 +
 utils/gssd/gss_names.c    | 138 ++++++++++++++++++++++++++++++++++++++++++++++
 utils/gssd/gss_names.h    |  36 ++++++++++++
 utils/gssd/gssd_proc.c    |  52 +++++++++++------
 utils/gssd/svcgssd_proc.c |  66 +---------------------
 5 files changed, 213 insertions(+), 81 deletions(-)
 create mode 100644 utils/gssd/gss_names.c
 create mode 100644 utils/gssd/gss_names.h

-- 
1.9.0

