Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:16480 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753191Ab0I2MC2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Sep 2010 08:02:28 -0400
Message-ID: <4CA32AB4.2090808@parallels.com>
Date: Wed, 29 Sep 2010 16:01:56 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/9] sunrpc: Create sockets in namespaces
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

v3 changes:
Moved the generic xprt alloc/free code to xprt.c.
Got David's ack on the 8th patch :)

v2 changes:
Fixed comments from Chuck and Trond.
Added one patch, that factors out rpc_xprt allocation as well.

v1:
This set implements pulling the net * argument down to the existing
sock_create_kern calls in the sunrpc layer and creating the sockets
in the given net.

Thanks,
Pavel
