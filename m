Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:17708 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753749Ab0I1PPE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Sep 2010 11:15:04 -0400
Message-ID: <4CA20651.4070605@parallels.com>
Date: Tue, 28 Sep 2010 19:14:25 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/7] sunrpc: Preparations to create sockets in namespaces
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Fixed comments from Chuck and Trond.
Added one patch, that factors out rpc_xprt allocation as well.

Patches, that were #7 and #8 await for Dave's approval :)

Thanks,
Pavel
