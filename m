Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f198.google.com ([209.85.211.198]:45538 "EHLO
	mail-yw0-f198.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756488Ab0ECTX5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 May 2010 15:23:57 -0400
Received: by ywh36 with SMTP id 36so1337206ywh.4
        for <linux-nfs@vger.kernel.org>; Mon, 03 May 2010 12:23:57 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] Three more IPv6-related mountd patches
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 03 May 2010 15:23:51 -0400
Message-ID: <20100503192041.29316.35846.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Steve-

Here are two clean-up patches, and one patch that modifies the
nfs_client struct so it can store both IPv4 and IPv6 addresses
concurrently.

---

Chuck Lever (3):
      mountd/exportfs: Make m_addrlist field a nfs_sockaddr
      libexport.a: Clean up client_add()
      libexport.a: Refactor client_init()


 support/export/client.c    |  158 ++++++++++++++++++++++++++------------------
 support/export/nfsctl.c    |   17 ++++-
 support/include/exportfs.h |   50 +++++++++++++-
 utils/mountd/auth.c        |    2 -
 utils/mountd/cache.c       |    3 +
 5 files changed, 158 insertions(+), 72 deletions(-)

-- 
Chuck Lever
