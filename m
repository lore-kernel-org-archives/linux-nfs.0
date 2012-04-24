Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:39660 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755131Ab2DXS6w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 14:58:52 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 0/2] NFS: Make v2 configurable
Date: Tue, 24 Apr 2012 14:58:48 -0400
Message-Id: <1335293930-20215-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

These patches were initially part of my modules patchset, but since they work
on their own I figured I would resend them as a standalone patch set while I
work on responding to comments for everything else.

- Bryan

Bryan Schumaker (2):
  NFS: Create an NFS v3 stat_to_errno()
  NFS: Make v2 configurable

 fs/nfs/Kconfig    |    9 +++++
 fs/nfs/Makefile   |    5 +--
 fs/nfs/client.c   |   11 +++++-
 fs/nfs/internal.h |    1 -
 fs/nfs/nfs2xdr.c  |    3 +-
 fs/nfs/nfs3xdr.c  |  103 +++++++++++++++++++++++++++++++++++++++++++----------
 6 files changed, 109 insertions(+), 23 deletions(-)

-- 
1.7.10

