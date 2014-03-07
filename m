Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15197 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753009AbaCGPCu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Mar 2014 10:02:50 -0500
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Stop Background mounts hang from hanging
Date: Fri,  7 Mar 2014 10:02:42 -0500
Message-Id: <1394204563-1166-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Background mounts hang forever due to the kernel not returning 
the time out error. The proposed fix is twofold, one in the kernel 
and one in the mounting code.

The kernel patch stop the server trunking code from endlessly 
looping in the kernel on -ETIMEDOUT errors. Instead, the code 
will now return the error, allowing the mount to go into 
the background.

Unfortunately, it takes over 5 mins for this timeout to 
happen, due the default retry strategy, which is unacceptable 
for background mounts. 

So the patch I will be proposing for the mount code will be 
to append the "retrans=1,timeo=100" mount options to the parent
mount of the background mount (when they don't exist). This
causes the parent mount to timeout in ~25sec. 

When parent mount times out, those options will be remove (when 
if they were added) before the child mount is done, in background.

Steve Dickson (1):
  NFSv4: Don't retry server trunking discovery on timeouts

 fs/nfs/nfs4state.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

