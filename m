From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/3] Should truncated READDIR replies return -EIO?
Date: Fri, 22 Feb 2008 14:49:58 -0500
Message-ID: <1203709801-20055-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43162 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757458AbYBVTuV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Feb 2008 14:50:21 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This patchset is a follow up to the discussion by the same title. I've
broken them out by NFS version. I've only really tested the NFSv2
version of this patch against the buggy server I have, but it does work
there as expected. The others have only had basic testing, but I didn't
see any obvious breakage there.

I don't see this patchset as particularly high priority, so 2.6.26 is
probably reasonable.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
