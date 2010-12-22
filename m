Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52422 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751717Ab0LVDgm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Dec 2010 22:36:42 -0500
Received: from tang.cn.fujitsu.com (tang.cn.fujitsu.com [10.167.250.3])
	by song.cn.fujitsu.com (Postfix) with ESMTP id 7E1C117070B
	for <linux-nfs@vger.kernel.org>; Wed, 22 Dec 2010 11:36:40 +0800 (CST)
Received: from mailserver.fnst.cn.fujitus.com (tang.cn.fujitsu.com [127.0.0.1])
	by tang.cn.fujitsu.com (8.14.3/8.13.1) with ESMTP id oBM3VjPP008615
	for <linux-nfs@vger.kernel.org>; Wed, 22 Dec 2010 11:31:47 +0800
Message-ID: <4D11E4B0.3020302@cn.fujitsu.com>
Date: Wed, 22 Dec 2010 19:44:48 +0800
From: fuliankun <fuliankun@cn.fujitsu.com>
To: linux-nfs@vger.kernel.org
Subject: nfsv4 read delegation issue
Content-Type: text/plain; charset=GB2312
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Open read delegation and file locks implementation in the kernel 
2.6.37-rc1 are not consistent with the RFC3530.

In the kernel 2.6.37-rc1:
1.NFS client mount NFS filesytem with nfsv4.
2.The client open a NFS file with O_RDONLY,then the server may return
  a read delegation to the client.
3.for some reasons, the network between client and server is partition.
4.the client lock the opened file with F_RDLCK again.If the client has 
  the read delegation at the step 2,it will return ture.In fact,the
  client doesn't send the read lock request to the NFS service.It does
  operate the request at local.

But the RFC3530 descripts as:
9.4.2.  Open Delegation and File Locks

   When a client holds a write open delegation, lock operations may be
   performed locally.  This includes those required for mandatory file
   locking.  This can be done since the delegation implies that there
   can be no conflicting locks.  Similarly, all of the revalidations
   that would normally be associated with obtaining locks and the
   flushing of data associated with the releasing of locks need not be
   done.

   When a client holds a read open delegation, lock operations are not
   performed locally.  All lock operations, including those requesting
   non-exclusive locks, are sent to the server for resolution.

Is this a bug or  the kernel have other considerations When it implements
this function?
