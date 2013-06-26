Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:44127 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751421Ab3FZQV5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Jun 2013 12:21:57 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 0/1] NFSv4.1 Do not overwrite negotiated session sizes
Date: Wed, 26 Jun 2013 12:21:48 -0400
Message-Id: <1372263709-2257-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Version 1 was 2 patches:
0001-NFSv4.1-Add-the-RPC-header-and-other-overhead-to-ses.patch
0002-NFSv4.1-Do-not-overwrite-negotiated-session-sizes.patch

These have been collapsed into "NFSv4.1 Refactor nfs4_init_session and nfs4_init_channel_attrs"

I have tested mounting NFSv4.1, pNFS,  LIF moves, and pynfs SESSIONRESET1, SESSIONRESET2 tests.

Andy Adamson (1):
  NFSv4.1 Refactor nfs4_init_session and nfs4_init_channel_attrs

 fs/nfs/nfs4client.c  |  2 +-
 fs/nfs/nfs4proc.c    | 17 +++++++----------
 fs/nfs/nfs4session.c | 41 +++--------------------------------------
 fs/nfs/nfs4session.h |  7 ++-----
 4 files changed, 13 insertions(+), 54 deletions(-)

-- 
1.7.11.7

