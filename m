Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail01-md.ns.itscom.net ([175.177.155.111]:48037 "EHLO
        mail01-md.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935559AbcIERUA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2016 13:20:00 -0400
From: "J. R. Okajima" <hooanon05g@gmail.com>
Subject: 4.8-rcN nfs, access(W_OK) on an immutable inode
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
In-Reply-To: <3647.1472877116@jrobl>
References: <3647.1472877116@jrobl>
Date: Tue, 06 Sep 2016 02:19:57 +0900
Message-ID: <24930.1473095997@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hello again,

linux-v4.8-rcN has a commit
	337684a 2016-08-07 fs: return EPERM on immutable inode

I am afraid NFS should follow the same behaviour. In other words,
fs/nfs/dir.c:nfs_do_access() should return -EPERM when MAY_WRITE on an
immutable inode. Currently it returns EACCES.


J. R. Okajima
