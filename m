Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:46546 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755131Ab1CYVit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Mar 2011 17:38:49 -0400
Received: by yxs7 with SMTP id 7so637804yxs.19
        for <linux-nfs@vger.kernel.org>; Fri, 25 Mar 2011 14:38:48 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] statd: Remove vestigial "-w" option from man page synopsis
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 25 Mar 2011 17:38:29 -0400
Message-ID: <20110325213829.27166.97569.stgit@matisse.1015granger.net>
In-Reply-To: <20110325213559.27166.71461.stgit@matisse.1015granger.net>
References: <20110325213559.27166.71461.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The synopsis of rpc.statd in its man page lists "-w" as a valid
option.  There is currently no support in the source code for a "-w"
option.

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=199

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/statd.man |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/statd/statd.man b/utils/statd/statd.man
index ca00e24..b72236c 100644
--- a/utils/statd/statd.man
+++ b/utils/statd/statd.man
@@ -12,7 +12,7 @@
 .SH NAME
 rpc.statd \- NSM service daemon
 .SH SYNOPSIS
-.BI "rpc.statd [-dh?FLNvVw] [-H " prog "] [-n " my-name "] [-o " outgoing-port "] [-p " listener-port "] [-P " path " ]
+.BI "rpc.statd [-dh?FLNvV] [-H " prog "] [-n " my-name "] [-o " outgoing-port "] [-p " listener-port "] [-P " path " ]
 .SH DESCRIPTION
 File locks are not part of persistent file system state.
 Lock state is thus lost when a host reboots.

