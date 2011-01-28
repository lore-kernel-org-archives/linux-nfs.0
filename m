Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:61043 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755061Ab1A1Rkt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Jan 2011 12:40:49 -0500
Received: by vws16 with SMTP id 16so1220887vws.19
        for <linux-nfs@vger.kernel.org>; Fri, 28 Jan 2011 09:40:48 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Fix Cthon basic test 6 failure
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 28 Jan 2011 12:40:44 -0500
Message-ID: <20110128173624.3235.74504.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi-

Here's what I came up with to address the failure of Cthon basic test
six with NFSv4.  The first patch is mere clean up that I noticed
while investigating the problem; the second addresses the problem.

I've applied your lockdep splat fix from yesterday, and have not seen
a recurrence of the splat.  I did not have a 100% reproducer.

---

Chuck Lever (2):
      NFS: NFSv4 readdir loses entries
      NFS: Micro-optimize nfs4_decode_dirent()


 fs/nfs/nfs4xdr.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

-- 
Chuck Lever
