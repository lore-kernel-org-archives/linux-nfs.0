Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:35594 "EHLO
        mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750738AbdBKGXs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Feb 2017 01:23:48 -0500
From: David Windsor <dwindsor@gmail.com>
To: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Cc: kernel-hardening@lists.openwall.com, bfields@fieldses.org,
        jlayton@poochiereds.net, keescook@chromium.org,
        elena.reshetova@intel.com, dwindsor@gmail.com
Subject: [RFC][PATCH] nfsd: add +1 to reference counting scheme for struct nfsd4_session
Date: Thu,  9 Feb 2017 02:38:21 -0500
Message-Id: <1486625901-10094-1-git-send-email-dwindsor@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In furtherance of the KSPP effort to add overflow protection to kernel
reference counters, a new type (refcount_t) and API have been created.
Part of the refcount_t API is refcount_inc(), which will not increment a
refcount_t variable if its value is 0 (as this would indicate a possible
use-after-free condition). 

In auditing the kernel for refcounting corner cases, we've come across the
case of struct nfsd4_session.  
