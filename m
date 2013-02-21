Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 183.141.211.66.inaddr.G4.NET ([66.211.141.183]:58406 "EHLO
	Dobby.4dicksons.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709Ab3BUWPR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2013 17:15:17 -0500
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] NFS v4.2 support to both the server and client
Date: Thu, 21 Feb 2013 17:15:09 -0500
Message-Id: <1361484911-17537-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the first attempt to added v4.2 support to both
the server and client. Basically the v4.1 code is reused,
but the minor version is needed to enable features like
label NFS.

Steve Dickson (2):
  NFSv4.2: Added NFS v4.2 support to the NFS client
  NFSDv4.2: Added NFS v4.2 support to the NFS server

 fs/nfs/Kconfig       | 11 ++++++++++-
 fs/nfs/callback.c    |  3 +++
 fs/nfs/nfs4client.c  |  5 +++++
 fs/nfs/nfs4proc.c    |  3 +++
 fs/nfs/super.c       |  7 ++++++-
 fs/nfsd/nfs4xdr.c    |  1 +
 fs/nfsd/nfsd.h       |  2 +-
 include/linux/nfs4.h |  4 ++++
 8 files changed, 33 insertions(+), 3 deletions(-)

-- 
1.8.1.2

