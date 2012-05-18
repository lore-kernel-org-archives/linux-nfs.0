Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail160.messagelabs.com ([216.82.253.99]:28452 "EHLO
	mail160.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755329Ab2ERKuA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2012 06:50:00 -0400
Message-ID: <4FB62953.9000701@nexenta.com>
Date: Fri, 18 May 2012 14:49:55 +0400
From: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
MIME-Version: 1.0
To: <trond.myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: question about lost lock during reclaimation
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Trond!


Could you point to idea how userspace process can know about
lost lock on NFSv4 server (due to server reboot) ?

See "case -NFS4ERR_DENIED" at  nfs4_reclaim_locks():

    http://lxr.free-electrons.com/source/fs/nfs/nfs4state.c#L1184


---
Thanks,
Vitaliy
