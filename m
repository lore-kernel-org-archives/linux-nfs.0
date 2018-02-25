Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:41015 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751505AbeBYSR0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Feb 2018 13:17:26 -0500
Received: by mail-io0-f196.google.com with SMTP id q24so7555060ioh.8
        for <linux-nfs@vger.kernel.org>; Sun, 25 Feb 2018 10:17:25 -0800 (PST)
Subject: [PATCH v3 0/4] Avoid IANA-assigned port numbers
From: Chuck Lever <chuck.lever@oracle.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, libtirpc-devel@lists.sourceforge.net
Date: Sun, 25 Feb 2018 13:17:23 -0500
Message-ID: <20180225180530.2983.82980.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Following up on https://bugzilla.linux-nfs.org/show_bug.cgi?id=320 .

Here's a possible way to get libtirpc to avoid IANA-assigned port
numbers when a caller requests a dynamically-assigned port. This
approach also reduces the number of reserved ports used by long
running user space RPC daemons, and can be applied in combination
with changing bindresvport(3) to skip port numbers that appear in
/etc/services.

Changes since v2:
- make port assignment more random across serial callers and
  processes

Changes since RFC:
- fixed bugs
- re-organized the patches slightly
- clarified the patch descriptions

---

Chuck Lever (4):
      Add an internal helper for binding to a dynamically-assigned port
      Avoid choosing reserved ports in svc_tli_create(3)
      Avoid choosing reserved ports in clnt_tli_create(3)
      Avoid choosing reserved ports in legacy RPC APIs


 src/Makefile.am    |    5 +-
 src/binddynport.c  |  139 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 src/clnt_generic.c |    4 +
 src/rpc_soc.c      |   10 +---
 src/svc_generic.c  |   12 +---
 5 files changed, 153 insertions(+), 17 deletions(-)
 create mode 100644 src/binddynport.c

--
Chuck Lever
