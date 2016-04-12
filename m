Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38763 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753400AbcDLTcZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Apr 2016 15:32:25 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: server commit commit 9d11b51ce7c1
Date: Tue, 12 Apr 2016 15:32:18 -0400
Message-Id: <6023A91E-B305-403D-8982-BF29265AEC2B@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Bruce Fields <bfields@fieldses.org>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Would it be appropriate to request that

commit 9d11b51ce7c150a69e761e30518f294fc73d55ff
Author:     Chuck Lever <chuck.lever@oracle.com>
AuthorDate: Thu Jul 9 16:45:18 2015 -0400
Commit:     J. Bruce Fields <bfields@redhat.com>
CommitDate: Mon Jul 20 14:58:47 2015 -0400

    svcrdma: Fix send_reply() scatter/gather set-up

be applied to stable kernels? It is a small patch
that fixes a bug that has been in the NFS/RDMA
code since 2010.

--
Chuck Lever



