Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:38761 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751124Ab2CUTeL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 15:34:11 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 0/2] NFS: Make v2 configurable
Date: Wed, 21 Mar 2012 15:34:07 -0400
Message-Id: <1332358449-16082-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

These patches were initially part of my modules patchset, but since they work
on their own I figured I would resend them as a standalone patch set while I
work on responding to comments for everything else.

- Bryan


Bryan Schumaker (2):
  NFS: Relocate the stat_to_errno() function
  NFS: Make v2 configurable

 fs/nfs/Kconfig   |    9 +++++++
 fs/nfs/Makefile  |    5 ++--
 fs/nfs/client.c  |   77 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs2xdr.c |   67 -----------------------------------------------
 fs/nfs/nfs3xdr.c |    3 ---
 5 files changed, 88 insertions(+), 73 deletions(-)

-- 
1.7.9.4

