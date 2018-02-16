Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:43978 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758803AbeBPRDp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Feb 2018 12:03:45 -0500
Received: by mail-io0-f194.google.com with SMTP id 72so4761552iom.10
        for <linux-nfs@vger.kernel.org>; Fri, 16 Feb 2018 09:03:45 -0800 (PST)
Subject: [PATCH v2 0/4] Avoid IANA-assigned port numbers
From: Chuck Lever <chuck.lever@oracle.com>
To: steve.dickson@redhat.com
Cc: linux-nfs@vger.kernel.org, libtirpc-devel@lists.sourceforge.net
Date: Fri, 16 Feb 2018 12:03:43 -0500
Message-ID: <20180216164846.9986.58128.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Following up on https://bugzilla.linux-nfs.org/show_bug.cgi?id=320 .

Here's a possible way to get libtirpc to avoid well-known port
numbers when a caller requests a dynamically-assigned port. This
approach also reduces the number of reserved ports used by long
running user space RPC daemons, and could be applied in combination
with changing bindresvport(3) to skip port numbers that appear in
/etc/services.

I've done some light testing, fixed bugs, re-organized the patches
slightly, and clarified the patch descriptions.

---

Chuck Lever (4):
      Add an internal helper for binding to a dynamically-assigned port
      Avoid choosing reserved ports in svc_tli_create(3)
      Avoid choosing reserved ports in clnt_tli_create(3)
      Avoid choosing reserved ports in legacy RPC APIs


 src/Makefile.am    |    5 +-
 src/binddynport.c  |  133 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 src/clnt_generic.c |    4 +-
 src/rpc_soc.c      |   10 ++--
 src/svc_generic.c  |   12 ++---
 5 files changed, 147 insertions(+), 17 deletions(-)
 create mode 100644 src/binddynport.c

--
Chuck Lever
