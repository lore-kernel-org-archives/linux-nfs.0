Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:21103 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755569Ab3EHUOr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 May 2013 16:14:47 -0400
From: andros@netapp.com
To: trondmyklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/1] NFS4.1 Fix data server connection race
Date: Wed,  8 May 2013 16:13:49 -0400
Message-Id: <1368044030-2401-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

I encountered this sporatically on my VM setup. I instrumented nfs_put_client
and all of the atomic_inc's on the nfs_client->cl_count and noted that the
data server nfs_client has an additional reference due to a call to 
nfs_match_client.

With this patch, I no longer see the extra reference.

I'm writing a pynfs proxy test to verify, and sending the patch out for
comments.

-->Andy


Andy Adamson (1):
  NFS4.1 Fix data server connection race

 fs/nfs/nfs4filelayout.h    |  2 ++
 fs/nfs/nfs4filelayoutdev.c | 25 +++++++++++++++++++++++--
 2 files changed, 25 insertions(+), 2 deletions(-)

-- 
1.7.11.7

