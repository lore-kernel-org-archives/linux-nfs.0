Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21769 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753905Ab3HFVJb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Aug 2013 17:09:31 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/5] nfs4.1: Initial SP4_MACH_CRED implementation
Date: Tue, 6 Aug 2013 17:08:26 -0400
Message-ID: <1375823311-18457-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches are the initial client-side SP4_MACH_CRED implementation.

Patch 1 is a repost with a few cleanups

Patch 2 adds the sp4 handler that replaces the cred on an rpc message (and
picks the right rpc_clnt).  Note that for now, we always use the machine cred
if supported - we could only use it if the user cred expires, but this is
simple and spec compliant.

Patch 3-5 implement SP4_MACH_CRED "features":
  - cleanup - CLOSE and LOCKU use machine cred
  - secinfo - SECINFO and SECINFO_NO_NAME use machine cred
  - stateid - TEST_STATEID and FREE_STATEID use machine cred

There are three more features that I've been working on, but need to be tested
before I post:
  - commit - COMMIT uses machine cred
  - write - WRITE uses machine cred, forces stable writes unless commit feature
            is also enabled
  - recovery - OPEN and LOCK can use machine cred - only in recovery.

The commit and write cases should be easy to test against a hacked nfsd, but
I need to think more about how to test the recovery stuff...

-dros

