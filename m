Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:47689 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120Ab0LFQJi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Dec 2010 11:09:38 -0500
Received: by ywl5 with SMTP id 5so6056279ywl.19
        for <linux-nfs@vger.kernel.org>; Mon, 06 Dec 2010 08:09:37 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] IPv6-related nfs-utils bugs and regressions
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 06 Dec 2010 11:09:33 -0500
Message-ID: <20101206160206.18361.26178.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Two of these are build regressions: the new code uses macros not
defined in glibc 2.2.5 headers.  The third fixes a longstanding bug
with how statd and sm-notify sweep the sm/ and sm.bak/ directories
looking for monitored host records.

---

Chuck Lever (3):
      sm-notify: Make use of AI_NUMERICSERV conditional
      libnsm.a: Replace __attribute_noinline__
      libnsm.a: sm-notify sometimes ignores monitored hosts


 support/nsm/file.c      |   48 ++++++++++++++++++++++++++++++++++-------------
 utils/statd/sm-notify.c |    6 ++++++
 2 files changed, 41 insertions(+), 13 deletions(-)

-- 
Chuck Lever
