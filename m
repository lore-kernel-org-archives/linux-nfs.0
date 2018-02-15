Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34030 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033275AbeBOUWB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Feb 2018 15:22:01 -0500
Received: by mail-it0-f66.google.com with SMTP id j21so1850614ita.1
        for <linux-nfs@vger.kernel.org>; Thu, 15 Feb 2018 12:22:01 -0800 (PST)
Subject: [PATCH RFC 0/3] Avoid well-known port numbers
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org, libtirpc-devel@lists.sourceforge.net
Date: Thu, 15 Feb 2018 15:21:59 -0500
Message-ID: <20180215201832.16924.28659.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Following up on https://bugzilla.linux-nfs.org/show_bug.cgi?id=320 .

Here's a possible way to get libtirpc to avoid well-known port
numbers when a caller requests a dynamically-assigned port. This
compiles without complaint, but I haven't tested it yet. I'm
interested in comments on the approach.

I understand that Fedora 28 is closing soon. It would be nice to
see a fix for this issue in libtirpc for that release.

---

Chuck Lever (3):
      Add an internal helper for binding to a dynamically-assigned port
      Avoid choosing reserved ports in svc_tli_create(3)
      Avoid choosing reserved ports in clnt_tli_create(3)


 src/Makefile.am    |    5 +-
 src/binddynport.c  |  132 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 src/clnt_generic.c |    4 +-
 src/rpc_soc.c      |    7 ++-
 src/svc_generic.c  |   12 ++---
 5 files changed, 147 insertions(+), 13 deletions(-)
 create mode 100644 src/binddynport.c

--
Chuck Lever
