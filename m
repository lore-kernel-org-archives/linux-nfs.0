From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/3] mount.nfs: fix background mount issues with binary mount options
Date: Sat, 29 Mar 2008 16:30:05 -0400
Message-ID: <1206822608-20154-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54732 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754168AbYC2UaN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 29 Mar 2008 16:30:13 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While text-based mount options are the future for NFS, we are still
carrying the legacy binary mount option code in nfs-utils for now.
This patchset comprises some fixes for backgrounded mounts that I
cooked up while working on some older code.

Comments welcome...

Signed-off-by: Jeff Layton <jlayton@redhat.com>
