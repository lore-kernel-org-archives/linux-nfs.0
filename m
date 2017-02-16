Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41548 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754441AbdBPN3i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Feb 2017 08:29:38 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: sleeping in async RPC task's rpc_call_ops
Date: Thu, 16 Feb 2017 08:29:35 -0500
Message-ID: <7DDA58DD-BA8F-4BCA-8535-C78782B54FD0@redhat.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

I understand that it is considered bad form for async tasks to sleep, but I
do not understand why.  Aren't async tasks running as scheduled work, and thus
allowed to sleep?  My understanding is that a workqueue can detect a
sleeping worker and add another, if needed.

The context is that I am coming back around to the problem of having an
unlock wait for I/O to complete in the face of the waiting process catching
a fatal signal, and I wondering why we cannot (for v4) wait on the iocounter
in the async unlock's rpc_call_prepare.

This question is asked in leiu of sending detestable patches.

Ben
