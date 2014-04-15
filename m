Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:52289 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754701AbaDOPTk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Apr 2014 11:19:40 -0400
Received: by mail-qc0-f171.google.com with SMTP id c9so10504782qcz.2
        for <linux-nfs@vger.kernel.org>; Tue, 15 Apr 2014 08:19:39 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/6] gssd: add the GSSAPI acceptor name to the info passed in downcall
Date: Tue, 15 Apr 2014 11:19:26 -0400
Message-Id: <1397575172-28377-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2:
- add patch to reset lifetime_rec if gss_inquire_context fails
- ensure that we always send the length in the downcall, even if
  there is no acceptor string.
- comment and error handling fixups (primarily in last patch)

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

Jeff Layton (6):
  gssd: handle malloc failure appropriately in do_downcall
  gssd: make do_downcall a void return
  gssd: move hostbased name routines into separate file
  gssd: add new routine for generating a hostbased principal in a
    gss_buffer_t
  gssd: explicitly set lifetime_rec to 0 when gss_inquire_context fails
  gssd: scrape the acceptor name out of the context

 utils/gssd/Makefile.am    |   2 +
 utils/gssd/gss_names.c    | 138 ++++++++++++++++++++++++++++++++++++++++++++++
 utils/gssd/gss_names.h    |  36 ++++++++++++
 utils/gssd/gssd_proc.c    |  53 ++++++++++++------
 utils/gssd/svcgssd_proc.c |  66 +---------------------
 5 files changed, 214 insertions(+), 81 deletions(-)
 create mode 100644 utils/gssd/gss_names.c
 create mode 100644 utils/gssd/gss_names.h

-- 
1.9.0

