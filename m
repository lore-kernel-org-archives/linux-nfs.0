Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40943 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751059Ab1CCNoK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Mar 2011 08:44:10 -0500
From: Karel Zak <kzak@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: mount.nfs libmount support (v2)
Date: Thu,  3 Mar 2011 14:43:40 +0100
Message-Id: <1299159822-25190-1-git-send-email-kzak@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


This is the second version of the mount.nfs with libmount support. The code
depends on util-linux >= v2.19 (e.g. Fedora 15).

Chnages:
  - move nfs_umount_do_umnt() to network.c
  - use union nfs_sockaddr
  - add missing GPL address paragraph
  - use abstract function the storing and retrieval mount options
  - use "static const" for struct option
  - use "strncmp() == 0" everywhere


The locale issue is not fixed. It seems that _() macro from nls.h is used on
many places in the package, but ENABLE_NLS macro is nowhere defined and 
setlocale() is not called at all.

I believe that this issue should be fixed independently on the libmount
patches.
