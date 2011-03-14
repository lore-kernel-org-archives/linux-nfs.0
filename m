Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37310 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751278Ab1CNN6l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Mar 2011 09:58:41 -0400
From: Karel Zak <kzak@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>, Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: mount.nfs libmount support (v3)
Date: Mon, 14 Mar 2011 14:58:26 +0100
Message-Id: <1300111108-13137-1-git-send-email-kzak@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is the third version of the mount.nfs with libmount support. The code
depends on util-linux >= v2.19 (e.g. Fedora 15).

v3:
  - call umount_error() on mount(2) error

v2:
  - move nfs_umount_do_umnt() to network.c
  - use union nfs_sockaddr
  - add missing GPL address paragraph
  - use abstract function the storing and retrieval mount options
  - use "static const" for struct option
  - use "strncmp() == 0" everywhere


